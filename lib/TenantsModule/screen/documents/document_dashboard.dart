import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../../widgets/appbar.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import 'documents_table.dart';
import 'lease_table.dart';

class ReportsMainScreen extends StatefulWidget {
  @override
  State<ReportsMainScreen> createState() => _ReportsMainScreenState();
}

class _ReportsMainScreenState extends State<ReportsMainScreen> {
  GlobalKey<ScaffoldState> key =  GlobalKey<ScaffoldState>();
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      backgroundColor: Colors.white,
      drawer:  CustomDrawer(currentpage: 'Documents',),
      appBar: widget_302.App_Bar(context: context,onDrawerIconPressed: (){
        key.currentState!.openDrawer();
      }),
      body: Column(
        children: [
          SizedBox(height: 20,),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 500) {
                return WideScreenLayout();
              } else {
                return NarrowScreenLayout();
              }
            },
          ),
        ],
      ),
    );
  }
}

class WideScreenLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: [
          titleBar(
            title: 'Documents',
            width: MediaQuery.of(context).size.width * .91,
          ),
          Row(
            children: [
              Expanded(
                child: ReportCard(
                  title: "Tenant's Insurance",
                  description: "Produces a list of all insured units",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DocumentsInsuranceTable(),),
                    );
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ReportCard(
                  title: "Tenant's Leases",
                  description: "Produces a list of leases",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>Lease_Table(),),
                    );
                    // Navigate to the appropriate screen
                  },
                ),
              ),
            ],
          ),
         /* SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ReportCard(
                  title: "Delinquent Tenants",
                  description:
                  "Tenants with an outstanding ledger balance as of a specific date",
                  onTap: () {
                   *//* Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DelinquentTenants()),
                    );*//*
                    // Navigate to the appropriate screen
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ReportCard(
                  title: "Open Work Orders",
                  description:
                  "Report of all Work Orders not yet in a complete state",
                  onTap: () {
                  *//*  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OpenWorkOrders()),
                    );*//*
                    // Navigate to the appropriate screen
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ReportCard(
            title: "Completed Work Orders",
            description: "Report of all completed Work Orders",
            onTap: () {
            *//*  Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CompletedWorkOrders()),
              );*//*
              // Navigate to the appropriate screen
            },
          ),*/
        ],
      ),
    );
  }
}

// class NarrowScreenLayout extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             titleBar(
//               title: 'Reports',
//               width: MediaQuery.of(context).size.width * .91,
//             ),
// ReportCard(
//   title: "Renter's Insurance",
//   description: "Produces a list of all insured units",
//   onTap: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => RentersInsurance()),
//     );
//   },
// ),
// SizedBox(height: 16),
// ReportCard(
//   title: "Expiring Leases",
//   description:
//       "Lists all leases that will end during a specified timeframe",
//   onTap: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => ExpiringLeases()),
//     );
//     // Navigate to the appropriate screen
//   },
// ),
// SizedBox(height: 16),
// ReportCard(
//   title: "Delinquent Tenants",
//   description:
//       "Tenants with an outstanding ledger balance as of a specific date",
//   onTap: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => DelinquentTenants()),
//     );
//     // Navigate to the appropriate screen
//   },
// ),
// SizedBox(height: 16),
// ReportCard(
//   title: "Open Work Orders",
//   description:
//       "Report of all Work Orders not yet in a complete state",
//   onTap: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => OpenWorkOrders()),
//     );
//     // Navigate to the appropriate screen
//   },
// ),
// SizedBox(height: 16),
// ReportCard(
//   title: "Completed Work Orders",
//   description: "Report of all completed Work Orders",
//   onTap: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//           builder: (context) => CompletedWorkOrders()),
//     );
//     // Navigate to the appropriate screen
//   },
// ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class NarrowScreenLayout extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     int crossAxisCount = screenWidth > 600 ? 3 : 2;
//     return Column(
//       children: [
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: GridView(
//               scrollDirection: Axis.horizontal,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: crossAxisCount,
//                 childAspectRatio: 0.7, // Adjust the aspect ratio as needed
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//               ),
//               children: [
//                 ReportCard(
//                   title: "Renter's Insurance",
//                   description: "Produces a list of all insured units",
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => RentersInsurance()),
//                     );
//                   },
//                 ),
//                 SizedBox(height: 16),
//                 ReportCard(
//                   title: "Expiring Leases",
//                   description:
//                       "Lists all leases that will end during a specified timeframe",
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => ExpiringLeases()),
//                     );
//                     // Navigate to the appropriate screen
//                   },
//                 ),
//                 SizedBox(height: 16),
//                 ReportCard(
//                   title: "Delinquent Tenants",
//                   description:
//                       "Tenants with an outstanding ledger balance as of a specific date",
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => DelinquentTenants()),
//                     );
//                     // Navigate to the appropriate screen
//                   },
//                 ),
//                 SizedBox(height: 16),
//                 ReportCard(
//                   title: "Open Work Orders",
//                   description:
//                       "Report of all Work Orders not yet in a complete state",
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => OpenWorkOrders()),
//                     );
//                     // Navigate to the appropriate screen
//                   },
//                 ),
//                 SizedBox(height: 16),
//                 ReportCard(
//                   title: "Completed Work Orders",
//                   description: "Report of all completed Work Orders",
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => CompletedWorkOrders()),
//                     );
//                     // Navigate to the appropriate screen
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class ReportCard extends StatelessWidget {
//   final String title;
//   final String description;
//   final VoidCallback onTap;

//   ReportCard(
//       {required this.title, required this.description, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15.0),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Container(
//               height: 50,
//               decoration: BoxDecoration(
//                 color: blueColor,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(12.0),
//                   topRight: Radius.circular(12.0),
//                 ),
//               ),
//               padding: EdgeInsets.all(17.0),
//               child: Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 description,
//                 style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w500,
//                     color: blueColor),
//                 textAlign: TextAlign.start,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class NarrowScreenLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Column(
      children: [
        titleBar(
          title: 'Documents',
          width: MediaQuery.of(context).size.width * .89,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 2.5, // Adjust the aspect ratio as needed
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,

            ),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: reportCards.length,
            itemBuilder: (context, index) {
              return ReportCard(
                title: reportCards[index].title,
                description: reportCards[index].description,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => reportCards[index].destination!,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class ReportCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  ReportCard(
      {required this.title, required this.description, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: blueColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
              ),
              //padding: EdgeInsets.all(17.0),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: blueColor,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportCardModel {
  final String title;
  final String description;
  final Widget? destination;

  ReportCardModel(
      {required this.title,
        required this.description,
         this.destination});
}

List<ReportCardModel> reportCards = [
  ReportCardModel(
    title: "Tenant's Insurance",
    description: "Produces a list of all insured units",
    destination: DocumentsInsuranceTable(),
  ),
  ReportCardModel(
    title: "Tenant's Leases",
    description: "Produces a list of leases",
    destination: Lease_Table(),
  ),
  /*ReportCardModel(
    title: "Delinquent Tenants",
    description:
    "Tenants with an outstanding ledger balance as of a specific date",
   // destination: DelinquentTenants(),
  ),
  ReportCardModel(
    title: "Open Work Orders",
    description: "Report of all Work Orders not yet in a complete state",
 //   destination: OpenWorkOrders(),
  ),
  ReportCardModel(
    title: "Completed Work Orders",
    description: "Report of all completed Work Orders",
   // destination: CompletedWorkOrders(),
  ),*/
];
