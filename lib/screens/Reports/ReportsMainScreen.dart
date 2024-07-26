import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/screens/Reports/ReportScreens/CompletedWorkOrders.dart';
import 'package:three_zero_two_property/screens/Reports/ReportScreens/DelinquentTenants.dart';
import 'package:three_zero_two_property/screens/Reports/ReportScreens/ExpiringLeases.dart';
import 'package:three_zero_two_property/screens/Reports/ReportScreens/OpenWorkOrders.dart';
import 'package:three_zero_two_property/screens/Reports/ReportScreens/RentersInsurance.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

class ReportsMainScreen extends StatefulWidget {
  @override
  State<ReportsMainScreen> createState() => _ReportsMainScreenState();
}

class _ReportsMainScreenState extends State<ReportsMainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    CupertinoIcons.home,
                    color: Colors.black,
                  ),
                  "Add Property Type",
                  false),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.person_add,
                    color: Colors.black,
                  ),
                  "Add Staff Member",
                  false),
              buildDropdownListTile(
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
                  ["Vendor", "Work Order"]),
              buildListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.letterboxd,
                    color: Colors.white,
                  ),
                  "Reports",
                  true),
            ],
          ),
        ),
      ),
      appBar: widget_302.App_Bar(context: context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 500) {
            return WideScreenLayout();
          } else {
            return NarrowScreenLayout();
          }
        },
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
            title: 'Reports',
            width: MediaQuery.of(context).size.width * .91,
          ),
          Row(
            children: [
              Expanded(
                child: ReportCard(
                  title: "Renter's Insurance",
                  description: "Produces a list of all insured units",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RentersInsurance()),
                    );
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ReportCard(
                  title: "Expiring Leases",
                  description:
                      "Lists all leases that will end during a specified timeframe",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ExpiringLeases()),
                    );
                    // Navigate to the appropriate screen
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ReportCard(
                  title: "Delinquent Tenants",
                  description:
                      "Tenants with an outstanding ledger balance as of a specific date",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DelinquentTenants()),
                    );
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OpenWorkOrders()),
                    );
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CompletedWorkOrders()),
              );
              // Navigate to the appropriate screen
            },
          ),
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
//                 color: Color.fromRGBO(21, 43, 81, 1),
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

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.0, // Adjust the aspect ratio as needed
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: reportCards.length,
          itemBuilder: (context, index) {
            return ReportCard(
              title: reportCards[index].title,
              description: reportCards[index].description,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => reportCards[index].destination,
                  ),
                );
              },
            );
          },
        ),
      ),
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
                color: Color.fromRGBO(21, 43, 81, 1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
              ),
              padding: EdgeInsets.all(17.0),
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
            Padding(
              padding: const EdgeInsets.all(16.0),
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
          ],
        ),
      ),
    );
  }
}

class ReportCardModel {
  final String title;
  final String description;
  final Widget destination;

  ReportCardModel(
      {required this.title,
      required this.description,
      required this.destination});
}

List<ReportCardModel> reportCards = [
  ReportCardModel(
    title: "Renter's Insurance",
    description: "Produces a list of all insured units",
    destination: RentersInsurance(),
  ),
  ReportCardModel(
    title: "Expiring Leases",
    description: "Lists all leases that will end during a specified timeframe",
    destination: ExpiringLeases(),
  ),
  ReportCardModel(
    title: "Delinquent Tenants",
    description:
        "Tenants with an outstanding ledger balance as of a specific date",
    destination: DelinquentTenants(),
  ),
  ReportCardModel(
    title: "Open Work Orders",
    description: "Report of all Work Orders not yet in a complete state",
    destination: OpenWorkOrders(),
  ),
  ReportCardModel(
    title: "Completed Work Orders",
    description: "Report of all completed Work Orders",
    destination: CompletedWorkOrders(),
  ),
];