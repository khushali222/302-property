import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'package:three_zero_two_property/Model/tenants.dart';

import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/lease.dart';

import 'package:three_zero_two_property/screens/Leasing/RentalRoll/newModel.dart';
// import 'package:three_zero_two_property/repository/properties_summery.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../../../Model/RentalOwnersData.dart';

import '../../../../model/lease.dart';
import '../../../../repository/Rental_ownersData.dart';
import '../../../../repository/properties_summery.dart';
import '../../../../widgets/drawer_tiles.dart';

import '../../../model/LeaseSummary.dart';
import '../../../model/applicant_summery_model.dart';
import '../../../repository/applicant_summery_repo.dart';


class applicant_summery extends StatefulWidget {
  String? applicant_id;
  applicant_summery({super.key, this.applicant_id});

  @override
  State<applicant_summery> createState() => _applicant_summeryState();
}

class _applicant_summeryState extends State<applicant_summery>
    with SingleTickerProviderStateMixin {
  TextEditingController startdateController = TextEditingController();
  TextEditingController enddateController = TextEditingController();
  List formDataRecurringList = [];
  late Future<applicant_summery_details> futureLeaseSummary;
  String? _selectedValue;
  TabController? _tabController;
  List<String> items = ["Approved","Rejected"];
  @override
  void initState() {
    print(widget.applicant_id);
    // TODO: implement initState
    futureLeaseSummary =
        ApplicantSummeryRepository.getApplicantSummary(widget.applicant_id!);
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: widget302.,
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
                    CupertinoIcons.house,
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
                  ["Properties", "RentalOwner", "Tenants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.thumbsUp,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Leasing",
                  ["Rent Roll", "Applicants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"],
                  selectedSubtopic: "Properties"),
            ],
          ),
        ),
      ),
      // body:
      // FutureBuilder<applicant_summery_details>(
      //   future: futureLeaseSummary,
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Center(
      //         child: SpinKitFadingCircle(
      //           color: Colors.black,
      //           size: 55.0,
      //         ),
      //       );
      //     } else if (snapshot.hasError) {
      //       return Center(child: Text('Error: ${snapshot.error}'));
      //     } else if (!snapshot.hasData || snapshot.data == null) {
      //       return Center(child: Text('No data found.'));
      //     } else {
      //       _selectedValue = snapshot.data!.applicantStatus!.last!.status;
      //       return SingleChildScrollView(
      //         child: Column(
      //           children: <Widget>[
      //             const SizedBox(height: 20),
      //             Row(
      //               children: [
      //                 const SizedBox(width: 10),
      //                 Column(
      //                   mainAxisAlignment: MainAxisAlignment.start,
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     Text(
      //                       'Applicant: ${snapshot.data!.applicantFirstName} ${snapshot.data!.applicantLastName}',
      //                       style: TextStyle(
      //                         color: Color.fromRGBO(21, 43, 81, 1),
      //                         fontWeight: FontWeight.bold,
      //                       ),
      //                     ),
      //                     SizedBox(height: 5),
      //                     Text(
      //                       '${snapshot.data!.leaseData!.rentalAdress}',
      //                       style: TextStyle(
      //                         color: Colors.grey,
      //                         fontWeight: FontWeight.bold,
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //                 const Spacer(),
      //                 Row(
      //                   children: [
      //                     GestureDetector(
      //                       onTap: () {
      //                         Navigator.pop(context);
      //                       },
      //                       child: Material(
      //                         elevation: 3,
      //                         borderRadius: const BorderRadius.all(
      //                           Radius.circular(5),
      //                         ),
      //                         child: Container(
      //                           height: 40,
      //                           width: 80,
      //                           decoration: const BoxDecoration(
      //                             color: Color.fromRGBO(21, 43, 81, 1),
      //                             borderRadius: BorderRadius.all(
      //                               Radius.circular(5),
      //                             ),
      //                           ),
      //                           child: const Center(
      //                             child: Text(
      //                               "Back",
      //                               style: TextStyle(
      //                                 fontWeight: FontWeight.w500,
      //                                 color: Colors.white,
      //                               ),
      //                             ),
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //                 const SizedBox(width: 10),
      //               ],
      //             ),
      //             const SizedBox(height: 10),
      //             Row(
      //               children: [
      //                 const SizedBox(width: 10),
      //                 DropdownButtonHideUnderline(
      //                   child: Material(
      //                     elevation: 3,
      //                     child: DropdownButton2<String>(
      //                       isExpanded: true,
      //                       hint: const Row(
      //                         children: [
      //                           SizedBox(width: 4),
      //                           Expanded(
      //                             child: Text(
      //                               '',
      //                               style: TextStyle(
      //                                 fontSize: 14,
      //                                 color: Color(0xFF8A95A8),
      //                               ),
      //                               overflow: TextOverflow.ellipsis,
      //                             ),
      //                           ),
      //                         ],
      //                       ),
      //                       items: items.map((String item) {
      //                         return DropdownMenuItem<String>(
      //                           value: item,
      //                           child: Text(
      //                             item,
      //                             style: const TextStyle(
      //                               fontSize: 14,
      //                               fontWeight: FontWeight.bold,
      //                               color: Colors.black,
      //                             ),
      //                             overflow: TextOverflow.ellipsis,
      //                           ),
      //                         );
      //                       }).toList(),
      //                       value: _selectedValue,
      //                       onChanged: (value) {
      //                         setState(() {
      //                           _selectedValue = value;
      //                         });
      //                       },
      //                       buttonStyleData: ButtonStyleData(
      //                         height: MediaQuery.of(context).size.width < 500
      //                             ? 40
      //                             : 50,
      //                         width: MediaQuery.of(context).size.width < 500
      //                             ? MediaQuery.of(context).size.width * .35
      //                             : MediaQuery.of(context).size.width * .4,
      //                         padding: const EdgeInsets.only(left: 14, right: 14),
      //                         decoration: BoxDecoration(
      //                           borderRadius: BorderRadius.circular(2),
      //                           border: Border.all(
      //                             color: Color(0xFF8A95A8),
      //                           ),
      //                           color: Colors.white,
      //                         ),
      //                         elevation: 0,
      //                       ),
      //                       dropdownStyleData: DropdownStyleData(
      //                         maxHeight: 200,
      //                         width: 200,
      //                         decoration: BoxDecoration(
      //                           borderRadius: BorderRadius.circular(14),
      //                         ),
      //                         offset: const Offset(-20, 0),
      //                         scrollbarTheme: ScrollbarThemeData(
      //                           radius: const Radius.circular(40),
      //                           thickness: MaterialStateProperty.all(6),
      //                           thumbVisibility: MaterialStateProperty.all(true),
      //                         ),
      //                       ),
      //                       menuItemStyleData: const MenuItemStyleData(
      //                         height: 40,
      //                         padding: EdgeInsets.only(left: 14, right: 14),
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //                 const SizedBox(width: 20),
      //                 GestureDetector(
      //                   onTap: () {
      //                     Navigator.pop(context);
      //                   },
      //                   child: Material(
      //                     elevation: 3,
      //                     borderRadius: const BorderRadius.all(
      //                       Radius.circular(5),
      //                     ),
      //                     child: Container(
      //                       height: 40,
      //                       width: 80,
      //                       decoration: const BoxDecoration(
      //                         color: Color.fromRGBO(21, 43, 81, 1),
      //                         borderRadius: BorderRadius.all(
      //                           Radius.circular(5),
      //                         ),
      //                       ),
      //                       child: const Center(
      //                         child: Text(
      //                           "MOVE IN",
      //                           style: TextStyle(
      //                             fontWeight: FontWeight.w500,
      //                             color: Colors.white,
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //               ],
      //             ),
      //             const SizedBox(height: 20),
      //             Container(
      //               margin: const EdgeInsets.symmetric(horizontal: 10),
      //               height: 60,
      //               padding: const EdgeInsets.all(10),
      //               decoration: BoxDecoration(
      //                 border: Border.all(color: const Color.fromRGBO(21, 43, 81, 1)),
      //                 borderRadius: BorderRadius.circular(10),
      //               ),
      //               child: TabBar(
      //                 controller: _tabController,
      //                 dividerColor: Colors.transparent,
      //                 indicatorWeight: 5,
      //                 indicatorColor: const Color.fromRGBO(21, 43, 81, 1),
      //                 labelColor: const Color.fromRGBO(21, 43, 81, 1),
      //                 unselectedLabelColor: const Color.fromRGBO(21, 43, 81, 1),
      //                 tabs: [
      //                    Tab(text: 'Summary'),
      //                    Tab(text: 'Application'),
      //                    Tab(text: 'Approved'),
      //                    Tab(text: 'Rejected'),
      //                 ],
      //               ),
      //             ),
      //         // Expanded(
      //         //                 child: TabBarView(
      //         //                   controller: _tabController,
      //         //                   children: [
      //         //                  Summery_page(snapshot.data!),
      //         //                    /* Summery_page(snapshot.data!),
      //         //                     Summery_page(snapshot.data!),
      //         //                     Summery_page(snapshot.data!),*/
      //         //                   /*  SummaryPage(),
      //         //                     FinancialTable(
      //         //                         leaseId: widget.leaseId,
      //         //                         status:
      //         //                         '${determineStatus(snapshot.data!.data!.startDate, snapshot.data!.data!.endDate).toString()}'),
      //         //                     Tenant(context),*/
      //         //                   ],
      //         //                 ),
      //         //               ),
      //             SizedBox(
      //               height: MediaQuery.of(context).size.height,
      //               child: TabBarView(
      //                 controller: _tabController,
      //                 children: [
      //                  // Summery_page(snapshot.data!),
      //                   // You can add more TabBarView children as needed
      //                   // Tab(text: 'Summary',),
      //                   Text("data"),
      //                   Tab(text: 'Summary'),
      //                   Tab(text: 'Summary'),
      //                   Tab(text: 'Summary'),
      //
      //                 ],
      //               ),
      //             ),
      //             SizedBox(height: 10,),
      //           ],
      //         ),
      //       );
      //     }
      //   },
      // ),
      body: FutureBuilder<applicant_summery_details>(
        future: futureLeaseSummary,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data found.'));
          } else {
            _selectedValue = 'Default Value'; // Example assignment from snapshot data
            return LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: <Widget>[
                    SizedBox(height: 20),
                    Row(
                      children: [
                        SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Applicant: ${snapshot.data!.applicantFirstName} ${snapshot.data!.applicantLastName}',
                              style: TextStyle(
                                color: Color.fromRGBO(21, 43, 81, 1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '${snapshot.data!.applicantFirstName}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Material(
                            elevation: 3,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                            child: Container(
                              height: 40,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(21, 43, 81, 1),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Back",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(width: 10),
                        // Expanded(
                        //   child: DropdownButtonHideUnderline(
                        //     child: Material(
                        //       elevation: 3,
                        //       child: DropdownButton<String>(
                        //         isExpanded: true,
                        //         hint: Row(
                        //           children: [
                        //             SizedBox(width: 4),
                        //             Expanded(
                        //               child: Text(
                        //                 'Select Option',
                        //                 style: TextStyle(
                        //                   fontSize: 14,
                        //                   color: Color(0xFF8A95A8),
                        //                 ),
                        //                 overflow: TextOverflow.ellipsis,
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //         items: items.map((String item) {
                        //           return DropdownMenuItem<String>(
                        //             value: item,
                        //             child: Text(
                        //               item,
                        //               style: TextStyle(
                        //                 fontSize: 14,
                        //                 fontWeight: FontWeight.bold,
                        //                 color: Colors.black,
                        //               ),
                        //               overflow: TextOverflow.ellipsis,
                        //             ),
                        //           );
                        //         }).toList(),
                        //         value: _selectedValue,
                        //         onChanged: (value) {
                        //           setState(() {
                        //             _selectedValue = value!;
                        //           });
                        //         },
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            // Implement move-in action
                          },
                          child: Material(
                            elevation: 3,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                            child: Container(
                              height: 40,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(21, 43, 81, 1),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "MOVE IN",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      height: 60,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorWeight: 5,
                        indicatorColor: Color.fromRGBO(21, 43, 81, 1),
                        labelColor: Color.fromRGBO(21, 43, 81, 1),
                        unselectedLabelColor: Color.fromRGBO(21, 43, 81, 1),
                        tabs: [
                          Tab(text: 'Summary'),
                          Tab(text: 'Application'),
                          Tab(text: 'Approved'),
                          Tab(text: 'Rejected'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          Container(
                            height: constraints.maxHeight,
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Summary content"),
                                Column(
                                  children: <Widget>[
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        const SizedBox(width: 10),

                                        const Spacer(),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Material(
                                                elevation: 3,
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                                child: Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(
                                                    color: Color.fromRGBO(21, 43, 81, 1),
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "Back",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        // DropdownButtonHideUnderline(
                                        //   child: Material(
                                        //     elevation: 3,
                                        //     child: DropdownButton2<String>(
                                        //       isExpanded: true,
                                        //       hint: const Row(
                                        //         children: [
                                        //           SizedBox(width: 4),
                                        //           Expanded(
                                        //             child: Text(
                                        //               '',
                                        //               style: TextStyle(
                                        //                 fontSize: 14,
                                        //                 color: Color(0xFF8A95A8),
                                        //               ),
                                        //               overflow: TextOverflow.ellipsis,
                                        //             ),
                                        //           ),
                                        //         ],
                                        //       ),
                                        //       items: items.map((String item) {
                                        //         return DropdownMenuItem<String>(
                                        //           value: item,
                                        //           child: Text(
                                        //             item,
                                        //             style: const TextStyle(
                                        //               fontSize: 14,
                                        //               fontWeight: FontWeight.bold,
                                        //               color: Colors.black,
                                        //             ),
                                        //             overflow: TextOverflow.ellipsis,
                                        //           ),
                                        //         );
                                        //       }).toList(),
                                        //       value: _selectedValue,
                                        //       onChanged: (value) {
                                        //         setState(() {
                                        //           _selectedValue = value;
                                        //         });
                                        //       },
                                        //       buttonStyleData: ButtonStyleData(
                                        //         height: MediaQuery.of(context).size.width < 500
                                        //             ? 40
                                        //             : 50,
                                        //         width: MediaQuery.of(context).size.width < 500
                                        //             ? MediaQuery.of(context).size.width * .35
                                        //             : MediaQuery.of(context).size.width * .4,
                                        //         padding: const EdgeInsets.only(left: 14, right: 14),
                                        //         decoration: BoxDecoration(
                                        //           borderRadius: BorderRadius.circular(2),
                                        //           border: Border.all(
                                        //             color: Color(0xFF8A95A8),
                                        //           ),
                                        //           color: Colors.white,
                                        //         ),
                                        //         elevation: 0,
                                        //       ),
                                        //       dropdownStyleData: DropdownStyleData(
                                        //         maxHeight: 200,
                                        //         width: 200,
                                        //         decoration: BoxDecoration(
                                        //           borderRadius: BorderRadius.circular(14),
                                        //         ),
                                        //         offset: const Offset(-20, 0),
                                        //         scrollbarTheme: ScrollbarThemeData(
                                        //           radius: const Radius.circular(40),
                                        //           thickness: MaterialStateProperty.all(6),
                                        //           thumbVisibility: MaterialStateProperty.all(true),
                                        //         ),
                                        //       ),
                                        //       menuItemStyleData: const MenuItemStyleData(
                                        //         height: 40,
                                        //         padding: EdgeInsets.only(left: 14, right: 14),
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        const SizedBox(width: 20),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Material(
                                            elevation: 3,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(5),
                                            ),
                                            child: Container(
                                              height: 40,
                                              width: 80,
                                              decoration: const BoxDecoration(
                                                color: Color.fromRGBO(21, 43, 81, 1),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  "MOVE IN",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        const SizedBox(width: 10),

                                        const Spacer(),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Material(
                                                elevation: 3,
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                                child: Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(
                                                    color: Color.fromRGBO(21, 43, 81, 1),
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "Back",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        // DropdownButtonHideUnderline(
                                        //   child: Material(
                                        //     elevation: 3,
                                        //     child: DropdownButton2<String>(
                                        //       isExpanded: true,
                                        //       hint: const Row(
                                        //         children: [
                                        //           SizedBox(width: 4),
                                        //           Expanded(
                                        //             child: Text(
                                        //               '',
                                        //               style: TextStyle(
                                        //                 fontSize: 14,
                                        //                 color: Color(0xFF8A95A8),
                                        //               ),
                                        //               overflow: TextOverflow.ellipsis,
                                        //             ),
                                        //           ),
                                        //         ],
                                        //       ),
                                        //       items: items.map((String item) {
                                        //         return DropdownMenuItem<String>(
                                        //           value: item,
                                        //           child: Text(
                                        //             item,
                                        //             style: const TextStyle(
                                        //               fontSize: 14,
                                        //               fontWeight: FontWeight.bold,
                                        //               color: Colors.black,
                                        //             ),
                                        //             overflow: TextOverflow.ellipsis,
                                        //           ),
                                        //         );
                                        //       }).toList(),
                                        //       value: _selectedValue,
                                        //       onChanged: (value) {
                                        //         setState(() {
                                        //           _selectedValue = value;
                                        //         });
                                        //       },
                                        //       buttonStyleData: ButtonStyleData(
                                        //         height: MediaQuery.of(context).size.width < 500
                                        //             ? 40
                                        //             : 50,
                                        //         width: MediaQuery.of(context).size.width < 500
                                        //             ? MediaQuery.of(context).size.width * .35
                                        //             : MediaQuery.of(context).size.width * .4,
                                        //         padding: const EdgeInsets.only(left: 14, right: 14),
                                        //         decoration: BoxDecoration(
                                        //           borderRadius: BorderRadius.circular(2),
                                        //           border: Border.all(
                                        //             color: Color(0xFF8A95A8),
                                        //           ),
                                        //           color: Colors.white,
                                        //         ),
                                        //         elevation: 0,
                                        //       ),
                                        //       dropdownStyleData: DropdownStyleData(
                                        //         maxHeight: 200,
                                        //         width: 200,
                                        //         decoration: BoxDecoration(
                                        //           borderRadius: BorderRadius.circular(14),
                                        //         ),
                                        //         offset: const Offset(-20, 0),
                                        //         scrollbarTheme: ScrollbarThemeData(
                                        //           radius: const Radius.circular(40),
                                        //           thickness: MaterialStateProperty.all(6),
                                        //           thumbVisibility: MaterialStateProperty.all(true),
                                        //         ),
                                        //       ),
                                        //       menuItemStyleData: const MenuItemStyleData(
                                        //         height: 40,
                                        //         padding: EdgeInsets.only(left: 14, right: 14),
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        const SizedBox(width: 20),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Material(
                                            elevation: 3,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(5),
                                            ),
                                            child: Container(
                                              height: 40,
                                              width: 80,
                                              decoration: const BoxDecoration(
                                                color: Color.fromRGBO(21, 43, 81, 1),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  "MOVE IN",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        const SizedBox(width: 10),

                                        const Spacer(),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Material(
                                                elevation: 3,
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                                child: Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(
                                                    color: Color.fromRGBO(21, 43, 81, 1),
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "Back",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        // DropdownButtonHideUnderline(
                                        //   child: Material(
                                        //     elevation: 3,
                                        //     child: DropdownButton2<String>(
                                        //       isExpanded: true,
                                        //       hint: const Row(
                                        //         children: [
                                        //           SizedBox(width: 4),
                                        //           Expanded(
                                        //             child: Text(
                                        //               '',
                                        //               style: TextStyle(
                                        //                 fontSize: 14,
                                        //                 color: Color(0xFF8A95A8),
                                        //               ),
                                        //               overflow: TextOverflow.ellipsis,
                                        //             ),
                                        //           ),
                                        //         ],
                                        //       ),
                                        //       items: items.map((String item) {
                                        //         return DropdownMenuItem<String>(
                                        //           value: item,
                                        //           child: Text(
                                        //             item,
                                        //             style: const TextStyle(
                                        //               fontSize: 14,
                                        //               fontWeight: FontWeight.bold,
                                        //               color: Colors.black,
                                        //             ),
                                        //             overflow: TextOverflow.ellipsis,
                                        //           ),
                                        //         );
                                        //       }).toList(),
                                        //       value: _selectedValue,
                                        //       onChanged: (value) {
                                        //         setState(() {
                                        //           _selectedValue = value;
                                        //         });
                                        //       },
                                        //       buttonStyleData: ButtonStyleData(
                                        //         height: MediaQuery.of(context).size.width < 500
                                        //             ? 40
                                        //             : 50,
                                        //         width: MediaQuery.of(context).size.width < 500
                                        //             ? MediaQuery.of(context).size.width * .35
                                        //             : MediaQuery.of(context).size.width * .4,
                                        //         padding: const EdgeInsets.only(left: 14, right: 14),
                                        //         decoration: BoxDecoration(
                                        //           borderRadius: BorderRadius.circular(2),
                                        //           border: Border.all(
                                        //             color: Color(0xFF8A95A8),
                                        //           ),
                                        //           color: Colors.white,
                                        //         ),
                                        //         elevation: 0,
                                        //       ),
                                        //       dropdownStyleData: DropdownStyleData(
                                        //         maxHeight: 200,
                                        //         width: 200,
                                        //         decoration: BoxDecoration(
                                        //           borderRadius: BorderRadius.circular(14),
                                        //         ),
                                        //         offset: const Offset(-20, 0),
                                        //         scrollbarTheme: ScrollbarThemeData(
                                        //           radius: const Radius.circular(40),
                                        //           thickness: MaterialStateProperty.all(6),
                                        //           thumbVisibility: MaterialStateProperty.all(true),
                                        //         ),
                                        //       ),
                                        //       menuItemStyleData: const MenuItemStyleData(
                                        //         height: 40,
                                        //         padding: EdgeInsets.only(left: 14, right: 14),
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        const SizedBox(width: 20),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Material(
                                            elevation: 3,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(5),
                                            ),
                                            child: Container(
                                              height: 40,
                                              width: 80,
                                              decoration: const BoxDecoration(
                                                color: Color.fromRGBO(21, 43, 81, 1),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  "MOVE IN",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        const SizedBox(width: 10),

                                        const Spacer(),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Material(
                                                elevation: 3,
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                                child: Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(
                                                    color: Color.fromRGBO(21, 43, 81, 1),
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "Back",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        // DropdownButtonHideUnderline(
                                        //   child: Material(
                                        //     elevation: 3,
                                        //     child: DropdownButton2<String>(
                                        //       isExpanded: true,
                                        //       hint: const Row(
                                        //         children: [
                                        //           SizedBox(width: 4),
                                        //           Expanded(
                                        //             child: Text(
                                        //               '',
                                        //               style: TextStyle(
                                        //                 fontSize: 14,
                                        //                 color: Color(0xFF8A95A8),
                                        //               ),
                                        //               overflow: TextOverflow.ellipsis,
                                        //             ),
                                        //           ),
                                        //         ],
                                        //       ),
                                        //       items: items.map((String item) {
                                        //         return DropdownMenuItem<String>(
                                        //           value: item,
                                        //           child: Text(
                                        //             item,
                                        //             style: const TextStyle(
                                        //               fontSize: 14,
                                        //               fontWeight: FontWeight.bold,
                                        //               color: Colors.black,
                                        //             ),
                                        //             overflow: TextOverflow.ellipsis,
                                        //           ),
                                        //         );
                                        //       }).toList(),
                                        //       value: _selectedValue,
                                        //       onChanged: (value) {
                                        //         setState(() {
                                        //           _selectedValue = value;
                                        //         });
                                        //       },
                                        //       buttonStyleData: ButtonStyleData(
                                        //         height: MediaQuery.of(context).size.width < 500
                                        //             ? 40
                                        //             : 50,
                                        //         width: MediaQuery.of(context).size.width < 500
                                        //             ? MediaQuery.of(context).size.width * .35
                                        //             : MediaQuery.of(context).size.width * .4,
                                        //         padding: const EdgeInsets.only(left: 14, right: 14),
                                        //         decoration: BoxDecoration(
                                        //           borderRadius: BorderRadius.circular(2),
                                        //           border: Border.all(
                                        //             color: Color(0xFF8A95A8),
                                        //           ),
                                        //           color: Colors.white,
                                        //         ),
                                        //         elevation: 0,
                                        //       ),
                                        //       dropdownStyleData: DropdownStyleData(
                                        //         maxHeight: 200,
                                        //         width: 200,
                                        //         decoration: BoxDecoration(
                                        //           borderRadius: BorderRadius.circular(14),
                                        //         ),
                                        //         offset: const Offset(-20, 0),
                                        //         scrollbarTheme: ScrollbarThemeData(
                                        //           radius: const Radius.circular(40),
                                        //           thickness: MaterialStateProperty.all(6),
                                        //           thumbVisibility: MaterialStateProperty.all(true),
                                        //         ),
                                        //       ),
                                        //       menuItemStyleData: const MenuItemStyleData(
                                        //         height: 40,
                                        //         padding: EdgeInsets.only(left: 14, right: 14),
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        const SizedBox(width: 20),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Material(
                                            elevation: 3,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(5),
                                            ),
                                            child: Container(
                                              height: 40,
                                              width: 80,
                                              decoration: const BoxDecoration(
                                                color: Color.fromRGBO(21, 43, 81, 1),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  "MOVE IN",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        const SizedBox(width: 10),

                                        const Spacer(),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Material(
                                                elevation: 3,
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                                child: Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(
                                                    color: Color.fromRGBO(21, 43, 81, 1),
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "Back",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        // DropdownButtonHideUnderline(
                                        //   child: Material(
                                        //     elevation: 3,
                                        //     child: DropdownButton2<String>(
                                        //       isExpanded: true,
                                        //       hint: const Row(
                                        //         children: [
                                        //           SizedBox(width: 4),
                                        //           Expanded(
                                        //             child: Text(
                                        //               '',
                                        //               style: TextStyle(
                                        //                 fontSize: 14,
                                        //                 color: Color(0xFF8A95A8),
                                        //               ),
                                        //               overflow: TextOverflow.ellipsis,
                                        //             ),
                                        //           ),
                                        //         ],
                                        //       ),
                                        //       items: items.map((String item) {
                                        //         return DropdownMenuItem<String>(
                                        //           value: item,
                                        //           child: Text(
                                        //             item,
                                        //             style: const TextStyle(
                                        //               fontSize: 14,
                                        //               fontWeight: FontWeight.bold,
                                        //               color: Colors.black,
                                        //             ),
                                        //             overflow: TextOverflow.ellipsis,
                                        //           ),
                                        //         );
                                        //       }).toList(),
                                        //       value: _selectedValue,
                                        //       onChanged: (value) {
                                        //         setState(() {
                                        //           _selectedValue = value;
                                        //         });
                                        //       },
                                        //       buttonStyleData: ButtonStyleData(
                                        //         height: MediaQuery.of(context).size.width < 500
                                        //             ? 40
                                        //             : 50,
                                        //         width: MediaQuery.of(context).size.width < 500
                                        //             ? MediaQuery.of(context).size.width * .35
                                        //             : MediaQuery.of(context).size.width * .4,
                                        //         padding: const EdgeInsets.only(left: 14, right: 14),
                                        //         decoration: BoxDecoration(
                                        //           borderRadius: BorderRadius.circular(2),
                                        //           border: Border.all(
                                        //             color: Color(0xFF8A95A8),
                                        //           ),
                                        //           color: Colors.white,
                                        //         ),
                                        //         elevation: 0,
                                        //       ),
                                        //       dropdownStyleData: DropdownStyleData(
                                        //         maxHeight: 200,
                                        //         width: 200,
                                        //         decoration: BoxDecoration(
                                        //           borderRadius: BorderRadius.circular(14),
                                        //         ),
                                        //         offset: const Offset(-20, 0),
                                        //         scrollbarTheme: ScrollbarThemeData(
                                        //           radius: const Radius.circular(40),
                                        //           thickness: MaterialStateProperty.all(6),
                                        //           thumbVisibility: MaterialStateProperty.all(true),
                                        //         ),
                                        //       ),
                                        //       menuItemStyleData: const MenuItemStyleData(
                                        //         height: 40,
                                        //         padding: EdgeInsets.only(left: 14, right: 14),
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        const SizedBox(width: 20),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Material(
                                            elevation: 3,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(5),
                                            ),
                                            child: Container(
                                              height: 40,
                                              width: 80,
                                              decoration: const BoxDecoration(
                                                color: Color.fromRGBO(21, 43, 81, 1),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  "MOVE IN",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: constraints.maxHeight,
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Application content"),
                              ],
                            ),
                          ),
                          Container(
                            height: constraints.maxHeight,
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Approved content"),
                              ],
                            ),
                          ),
                          Container(
                            height: constraints.maxHeight,
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Rejected content"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),


    );
  }
  Summery_page(applicant_summery_details summery){
    return Container(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: summery.applicantCheckedChecklist!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            activeColor: Color.fromRGBO(21, 43, 83, 1),
                            value: true,
                            onChanged: (bool? value) {
                              setState(() {
                                summery.applicantCheckedChecklist![index].isChecked = value ?? false;
                              });
                            },
                          ),
                          Text(summery.applicantCheckedChecklist![index]),
                        ],
                      ),

                    ],
                  ),
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}
