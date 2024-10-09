import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/StaffModule/screen/Leasing/Applicants/Applicants_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Maintenance/Vendor/Vendor_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Maintenance/Workorder/Workorder_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Rental/Properties/Properties_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Rental/Tenants/Tenants_table.dart';
import 'package:three_zero_two_property/widgets/pie_chart.dart';
import 'package:three_zero_two_property/screens/Rental/Properties/properties.dart';
import '../model/staffpermission.dart';
import '../repository/staffpermission_provider.dart';
import '../widgets/appbar.dart';
import 'package:http/http.dart' as http;
import '../../constant/constant.dart';
import '../widgets/drawer_tiles.dart';
import '../widgets/custom_drawer.dart';
import '../../widgets/barchart.dart';
import '../widgets/chart.dart';

import 'profile.dart';
class DashboardData {
  // int tenantCount = 0;
  // int rentalCount = 0;
  // int vendorCount = 0;
  // int applicantCount = 0;
  // int workOrderCount = 0;

  List<int> countList = [];
  List<int> amountList = [];

  List<String> icons = [
    "assets/images/Properti-icon.svg",
    "assets/images/tenant-icon.svg",
    "assets/images/applicant-icon.svg",
    "assets/images/vendor-icon.svg",
    "assets/images/workorder-icon.svg"
  ];

  List<String> titles = [
    "Properties",
    "Tenants",
    "Applicants",
    "Vendors",
    "Work Orders"
  ];



  List<Color> colorc = [
   blueColor,
    const Color.fromRGBO(40, 60, 95, 1),
    const Color.fromRGBO(50, 75, 119, 1),
    const Color.fromRGBO(60, 89, 142, 1),
    const Color.fromRGBO(90, 134, 213, 1),
  ];

  List<Color> colors = [
   blueColor,
    const Color.fromRGBO(40, 60, 95, 1),
    const Color.fromRGBO(50, 75, 119, 1),
    const Color.fromRGBO(60, 89, 142, 1),
    const Color.fromRGBO(90, 134, 213, 1),
  ];


  DashboardData({required this.countList, required this.amountList});
}

class Dashboard_staff extends StatefulWidget {
  Dashboard_staff({super.key});

  @override
  State<Dashboard_staff> createState() => _Dashboard_staffState();
}

class _Dashboard_staffState extends State<Dashboard_staff> {
  String firstname = '';
  String lastname = '';
  bool loading = false;
  final List<Widget> pages = [
    PropertiesTable(),
    Tenants_table(),
    Applicants_table(),
    Vendor_table(),
    Workorder_table(),
  ];
  StaffPermission? permissions;
  Future<void> fetchDatacount() async {
    /*setState(() {
      loading = true;
    });*/
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("staff_id");
      String? admin_id = prefs.getString("adminId");
      String? token = prefs.getString('token');

      final response =
      await http.get(
          Uri.parse('${Api_url}/api/staffmember/count/${id!}/${admin_id}'),
          headers: {
           "id":"CRM $id",
           "authorization": "CRM $token",
            "Content-Type": "application/json"
          }

      );
      print(response.body);
      final jsonData = json.decode(response.body);
      if (jsonData["statusCode"] == 200) {
        setState(() {
          countList[0] = jsonData['property_staffMember'];
          countList[1] = jsonData['tenant_staffMember'];
          countList[2] = jsonData['applicant_staffMember'];
          countList[3] = jsonData['vendor_staffMember'];
          countList[4] = jsonData['workorder_staffMember'];
          loading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }
  int newworkorder = 0;
  int overdueworkorder = 0;
  double currentMonthRentDue = 0.0;
  double lastMonthRentDue = 0.0;
  double currentMonthRentPaid = 0.0;
  double lastMonthRentPaid = 0.0;
  double totalRentPastDue = 0.0;

  Future<void> fetchData() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("staff_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    print(admin_id);
    final response =
    await http.get(
        Uri.parse('${Api_url}/api/staffmember/dashboard_workorder/$id/$admin_id'),
        headers: {
          "authorization": "CRM $token",
          "id":"CRM $id",
          "Content-Type": "application/json"
        }
    );
   //print('${Api_url}/api/payment/admin_balance/$id');
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print(jsonData);
      if (jsonData["statusCode"] == 200) {
        final data = jsonData["data"];
        setState(() {
         List newwork = data["new_workorder"];
         List overdue = data["overdue_workorder"];
         print(newwork.length);
         newworkorder = newwork.length;
         overdueworkorder = overdue.length;
         print(data);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  late DashboardData dashboardData;
  List<int> countList = List.filled(5, 0);
  List<int> amountList = List.filled(5, 0);

  @override
  void initState() {
    super.initState();
    dashboardData =
        DashboardData(countList: [0, 0], amountList: [0, 0]);
    fetchDatacount();
    fetchData();
    _loadName();
  }

  Future<void> _loadName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      firstname = prefs.getString('first_name') ?? '';
      lastname = prefs.getString('last_name') ?? '';
    });
  }

  var appBarHeight = AppBar().preferredSize.height;
  @override
  Widget build(BuildContext context) {
    final permissionProvider = Provider.of<StaffPermissionProvider>(context);
    permissions = permissionProvider.permissions;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: CustomDrawer(currentpage: 'Dashboard',dropdown: false,),
      appBar: widget_302.App_Bar(context: context),
      body: Center(
          child: loading
              ? const SpinKitFadingCircle(
            color: Colors.black,
            size: 50.0,
          )
              : SingleChildScrollView(
                child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                // Material(
                //   elevation: 3,
                //   child: Divider(
                //     height: 1,
                //     color: Colors.transparent,
                //   ),
                // ),
                // SizedBox(
                //     height: MediaQuery.of(context).size.height * 0.01),
                //welcome
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Row(
                      children: [
                        SizedBox(width: width * 0.05),
                        Container(
                          color: Color.fromRGBO(2, 121, 210, 1),
                          margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.012,),
                          width: 3,
                          child: Column(
                            children: [
                
                              Container(
                                height: MediaQuery.of(context).size.height * 0.012 +
                                    MediaQuery.of(context).size.width * 0.04 +
                                    3 +
                                    16,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.012),
                            Row(
                              children: [
                                SizedBox(width: width * 0.05),
                                Text(
                                  "Hello $firstname $lastname, Welcome back",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: MediaQuery.of(context).size.width > 500?MediaQuery.of(context).size.width * 0.03 : MediaQuery.of(context).size.width * 0.04,
                                  ),
                                ),
                              ],
                            ),
                            //   SizedBox(height: 3),
                            // My Dashboard
                            Row(
                              children: [
                                SizedBox(width: width * 0.05),
                                Text(
                                  "My Dashboard",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.of(context).size.width > 500?MediaQuery.of(context).size.width * 0.03 : MediaQuery.of(context).size.width * 0.04,
                
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                //my dashboard
                
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      // Tablet layout - horizontal
                      return Padding(
                        padding: const EdgeInsets.only(left: 35, right: 80, top: 20),
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: MediaQuery.of(context).size.width * 0.02,
                          runSpacing: MediaQuery.of(context).size.width * 0.02,
                          children: List.generate(
                            2,
                                (index) => InkWell(
                                  onTap: (){
                                    if(index  == 0 && permissions!.propertyView!)
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PropertiesTable()));
                                    else if(index ==1 && permissions!.workorderView!)
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Workorder_table()));
                                  },
                                  child: SizedBox(
                                                              width: 180, // Ensure SizedBox has defined width
                                                              height: 180, // Ensure SizedBox has defined height
                                                              child: Material(
                                  elevation: 3,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: dashboardData.colorc[index],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const SizedBox(width: 10),
                                            Material(
                                              elevation: 5,
                                              borderRadius: BorderRadius.circular(20),
                                              child: Container(
                                                height: 50,
                                                width: 50,
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: dashboardData.colors[index],
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: SvgPicture.asset(
                                                  "${dashboardData.icons[index]}",
                                                  fit: BoxFit.cover,
                                                  height: 27,
                                                  width: 27,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 15),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Text(
                                            countList[index].toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Text(
                                            dashboardData.titles[index],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                                              ),
                                                            ),
                                ),
                          ),
                        ),
                      );
                
                    } else {
                      // Phone layout - vertical
                      return Column(
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.width *
                                  0.05),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 25, right: 25),
                            child: GridView.builder(
                              itemCount: 5,
                              gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                2, // Number of items per row
                                crossAxisSpacing:
                                MediaQuery.of(context).size.width *
                                    0.02,
                                mainAxisSpacing:
                                MediaQuery.of(context).size.width *
                                    0.02,
                                childAspectRatio:
                                .99, // Adjust as needed for your design
                              ),
                              itemBuilder: (context, index) {
                                return
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => pages[index]),
                                      );
                                    },
                                    child: Material(
                                      elevation: 3,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: dashboardData.colorc[index],
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 5),
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 15),
                                              Row(
                                                children: [
                                                  const SizedBox(width: 10),
                                                  Material(
                                                    elevation: 5,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        15),
                                                    child: Container(
                                                        height: 50,
                                                        width: 50,
                                                        padding:
                                                        const EdgeInsets
                                                            .all(10),
                                                        decoration:
                                                        BoxDecoration(
                                                          color: dashboardData
                                                              .colors[index],
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(15),
                                                        ),
                                                        child: SvgPicture.asset(
                                                          "${dashboardData.icons[index]}",
                                                          //fit: BoxFit.cover,
                                                          height: 30,
                                                          width: 30,
                                                        )),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    countList[index].toString(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    dashboardData.titles[index],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  SizedBox(width: 5,),
                                                  Icon(Icons.arrow_forward_rounded,color: Colors.white,),

                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                              },
                              shrinkWrap:
                              true, // If you want the GridView to take only the space it needs
                              physics:
                              const NeverScrollableScrollPhysics(), // If you don't want it to scroll
                            ),
                          )
                        ],
                      );
                    }
                  },
                ),
                
                
                
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      // Tablet layout - horizontal
                      return  Padding(
                        padding: const EdgeInsets.only( left: 15),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 150,
                                        margin: EdgeInsets.symmetric(horizontal: width * .025), // Adjusted for equal spacing
                                        decoration:  BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(7)),
                                            border: Border.all(color: blueColor )
                                        ),
                                        child: Material(
                                          //   elevation: 3,
                                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    color: Color.fromRGBO(50, 75, 119, 1),
                                                    borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "New Work Order",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 7,
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            const Text(
                                                              "Total: ",
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.bold,
                                                                color: Color.fromRGBO(90, 134, 213, 1),),
                                                            ),
                                                            Text(
                                                              "${newworkorder}",
                                                              style: const TextStyle(
                                                                  fontSize: 18,
                                                                  color: Color.fromRGBO(90, 134, 213, 1),
                                                                  fontWeight: FontWeight.bold),
                                                            ),
                                                          ],
                                                        ),
                                                        InkWell(
                                                          onTap: (){
                                                           if( permissions!.workorderView!)
                                                              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Workorder_table()));
                                                          },
                                                          child: Container(
                                                            margin: EdgeInsets.symmetric(vertical: 12),
                                                            width: 100,
                                                            height: 30,
                                                            decoration: BoxDecoration(
                                                              color: blueColor,
                                                              borderRadius: BorderRadius.circular(5),
                                                            ),
                                                            child: const Center(
                                                              child: Text(
                                                                "View All",
                                                                style: TextStyle(color: Colors.white),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Container(
                                        height: 150,
                                        margin: EdgeInsets.symmetric(horizontal: width * .025), // Adjusted for equal spacing
                                        decoration:  BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(7)),
                                            border: Border.all(color: Color.fromRGBO(91, 134, 213, 1) )
                                        ),
                                        child: Material(
                                          //  elevation: 3,
                                          borderRadius: const BorderRadius.all(Radius.circular(7)),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    color: Color.fromRGBO(91, 134, 213, 1),
                                                    borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "Overdue Work Order",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 7,
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            const Text(
                                                              "Total: ",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold,
                                                                color: Color.fromRGBO(90, 134, 213, 1),),
                                                            ),
                                                            Text(
                                                              "${overdueworkorder}",
                                                              style: const TextStyle(
                                                                  fontSize: 16,
                                                                  color: Color.fromRGBO(90, 134, 213, 1),
                                                                  fontWeight: FontWeight.bold),
                                                            ),
                                                          ],
                                                        ),
                                                        InkWell(
                                                          onTap: (){
                                                            if( permissions!.workorderView!)
                                                              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Workorder_table()));
                                                          },
                                                          child: Container(
                                                            margin: EdgeInsets.symmetric(vertical: 12),
                                                            width: 100,
                                                            height: 30,
                                                            decoration: BoxDecoration(
                                                              color: Color.fromRGBO(91, 134, 213, 1),
                                                              borderRadius: BorderRadius.circular(5),
                                                            ),
                                                            child: const Center(
                                                              child: Text(
                                                                "View All",
                                                                style: TextStyle(color: Colors.white),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 350,
                                  margin: EdgeInsets.symmetric(horizontal:
                                  width * 0.05,
                                  ),
                
                                  child: Container(
                
                                    child: DonutChart(
                                      newWorkOrders: newworkorder,
                                      overdueWorkOrders: overdueworkorder,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                
                          ],
                        ),
                      );
                    } else {
                      // Phone layout - vertical
                      return Container(
                    //    color: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 150,
                                    margin: EdgeInsets.symmetric(horizontal: width * .025), // Adjusted for equal spacing
                                    decoration:  BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(7)),
                                        border: Border.all(color: blueColor )
                                    ),
                                    child: Material(
                                      //   elevation: 3,
                                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Color.fromRGBO(50, 75, 119, 1),
                                                borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  "New Work Order",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 7,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        const Text(
                                                          "Total: ",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: Color.fromRGBO(90, 134, 213, 1),),
                                                        ),
                                                        Text(
                                                          "${newworkorder}",
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              color: Color.fromRGBO(90, 134, 213, 1),
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                      ],
                                                    ),
                                                    InkWell(
                                                      onTap: (){
                                                        if( permissions!.workorderView!)
                                                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Workorder_table()));
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.symmetric(vertical: 12),
                                                        width: 100,
                                                        height: 30,
                                                        decoration: BoxDecoration(
                                                          color: blueColor,
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                        child: const Center(
                                                          child: Text(
                                                            "View All",
                                                            style: TextStyle(color: Colors.white),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 150,
                                    margin: EdgeInsets.symmetric(horizontal: width * .025), // Adjusted for equal spacing
                                    decoration:  BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(7)),
                                        border: Border.all(color: Color.fromRGBO(91, 134, 213, 1) )
                                    ),
                                    child: Material(
                                      //  elevation: 3,
                                      borderRadius: const BorderRadius.all(Radius.circular(7)),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Color.fromRGBO(91, 134, 213, 1),
                                                borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  "Overdue Work Order",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 7,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        const Text(
                                                          "Total: ",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: Color.fromRGBO(90, 134, 213, 1),),
                                                        ),
                                                        Text(
                                                          "${overdueworkorder}",
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              color: Color.fromRGBO(90, 134, 213, 1),
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                      ],
                                                    ),
                                                    InkWell(
                                                      onTap: (){
                                                        if( permissions!.workorderView!)
                                                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Workorder_table()));
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.symmetric(vertical: 12),
                                                        width: 100,
                                                        height: 30,
                                                        decoration: BoxDecoration(
                                                          color: Color.fromRGBO(91, 134, 213, 1),
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                        child: const Center(
                                                          child: Text(
                                                            "View All",
                                                            style: TextStyle(color: Colors.white),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 220,
                              margin: EdgeInsets.symmetric(horizontal:
                              width * 0.05,
                              ),
                
                              child: Container(
                
                                child: DonutChart(
                                  newWorkOrders: newworkorder,
                                  overdueWorkOrders: overdueworkorder,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      );
                
                    }
                  },
                ),
                
                // SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                // PieCharts(),
                // SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                // Barchart()
                const SizedBox(
                  height: 20,
                ),
                
                         /*     const SizedBox(
                                height: 60,
                              ),*/
                            /*  LayoutBuilder(
                  builder:
                      (BuildContext context, BoxConstraints constraints) {
                    // Check if the device width is less than 600 (considered as phone screen)
                    if (constraints.maxWidth < 500) {
                      // Phone layout
                      return Column(
                        children: [
                          Padding(
                            padding:
                            const EdgeInsets.only(left: 10, right: 10),
                            child: PieCharts(dataMap: {
                              "Properties": countList[0].toDouble(),
                
                              "Work Orders": countList[1].toDouble(),
                            }),
                          ), // Vertical layout for phone
                          SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  0.015),
                          Padding(
                            padding:
                            const EdgeInsets.only(left: 0, right: 8),
                            child: Barchart(),
                          ),
                        ],
                      );
                    } else {
                      // Tablet layout
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 35,
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            PieCharts(dataMap: {
                              "Properties": countList[0].toDouble(),
                
                              "Work Orders": countList[2].toDouble(),
                            }),
                            const SizedBox(
                              width: 10,
                            ),
                            Barchart(),
                          ],
                        ),
                      );
                    }
                  },
                ),*/
                            ],
                          ),
              )),
    );
  }

/* Widget buildListTile(BuildContext context,Widget leadingIcon, String title,bool active) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: active?blueColor:Colors.transparent,
          borderRadius: BorderRadius.circular(10)
      ),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(

        leading: leadingIcon,
        title: Text(title,style: TextStyle(
            color: active?Colors.white:Colors.black
        ),),
      ),
    );
  }*/
/* Widget buildDropdownListTile(
      BuildContext context,Widget leadingIcon, String title, List<String> subTopics) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ExpansionTile(
        leading: leadingIcon,
        title: Text(title),
        children: subTopics.map((subTopic) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              title: Text(subTopic),
              onTap: () {
                // Handle sub-topic selection
                Navigator.pop(
                    context); // Close drawer after selecting a sub-topic
              },
            ),
          );
        }).toList(),
      ),
    );
  }*/
}
