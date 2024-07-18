import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/Model/tenants.dart';

import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/lease.dart';

import 'package:three_zero_two_property/screens/Leasing/RentalRoll/newModel.dart';
// import 'package:three_zero_two_property/repository/properties_summery.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../../Model/RentalOwnersData.dart';

import '../../../../Model/lease.dart';
import '../../../../repository/Rental_ownersData.dart';
import '../../../../repository/properties_summery.dart';
import '../../../../widgets/drawer_tiles.dart';
import '../../../Model/applicant_summery.dart';
import '../../../Model/LeaseSummary.dart';
import '../../../repository/applicant_summery.dart';

class applicant_summery extends StatefulWidget {
  String? applicant_id;
  applicant_summery({super.key, this.applicant_id});

  @override
  State<applicant_summery> createState() => _applicant_summeryState();
}

class _applicant_summeryState extends State<applicant_summery>
    with SingleTickerProviderStateMixin {
  List<String> applicantCheckedChecklist = [
    "CreditCheck",
    "EmploymentVerification",
    "ApplicationFee",
    "IncomeVerification",
    "LandlordVerification"
  ];
  List<String> applicantChecklist = [];
  final Map<String, String> displayNames = {
    "CreditCheck": "Credit and background check",
    "EmploymentVerification": "Employment verification",
    "ApplicationFee": "Application fee collected",
    "IncomeVerification": "Income verification",
    "LandlordVerification": "Landlord verification",
  };

  bool addcheckbox = false;
  TextEditingController startdateController = TextEditingController();
  TextEditingController enddateController = TextEditingController();
  TextEditingController checkvalue = TextEditingController();
  List formDataRecurringList = [];
  late Future<applicant_summery_details> futureLeaseSummary;
  String? _selectedValue;
  TabController? _tabController;
  List<String> items = ["Approved", "Rejected"];
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
      body: FutureBuilder<applicant_summery_details>(
          future: futureLeaseSummary,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SpinKitFadingCircle(
                  color: Colors.black,
                  size: 55.0,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('No data found.'));
            } else {
              _selectedValue = snapshot.data!.applicantStatus!.last!.status;
              return Column(
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Applicant : ${snapshot.data!.applicantFirstName} ${snapshot.data!.applicantLastName}',
                              style: TextStyle(
                                  color: Color.fromRGBO(21, 43, 81, 1),
                                  fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 5,
                          ),
                          Text('${snapshot.data!.leaseData!.rentalAdress}',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
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
                                      color: Colors.white),
                                )),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      DropdownButtonHideUnderline(
                        child: Material(
                          elevation: 3,
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: const Row(
                              children: [
                                SizedBox(
                                  width: 4,
                                ),
                                Expanded(
                                  child: Text(
                                    '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      // fontWeight: FontWeight.bold,
                                      color: Color(0xFF8A95A8),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            items: items
                                .map((String item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                                .toList(),
                            value: _selectedValue,
                            onChanged: (value) {
                              setState(() {
                                _selectedValue = value;
                              });
                            },
                            buttonStyleData: ButtonStyleData(
                              height: MediaQuery.of(context).size.width < 500
                                  ? 40
                                  : 50,
                              // width: 180,
                              width: MediaQuery.of(context).size.width < 500
                                  ? MediaQuery.of(context).size.width * .35
                                  : MediaQuery.of(context).size.width * .4,
                              padding:
                                  const EdgeInsets.only(left: 14, right: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(
                                  // color: Colors.black26,
                                  color: Color(0xFF8A95A8),
                                ),
                                color: Colors.white,
                              ),
                              elevation: 0,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                //color: Colors.redAccent,
                              ),
                              offset: const Offset(-20, 0),
                              scrollbarTheme: ScrollbarThemeData(
                                radius: const Radius.circular(40),
                                thickness: MaterialStateProperty.all(6),
                                thumbVisibility:
                                    MaterialStateProperty.all(true),
                              ),
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 40,
                              padding: EdgeInsets.only(left: 14, right: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
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
                                  color: Colors.white),
                            )),
                          ),
                        ),
                      ),
                    ],
                  ),
                  /* Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                          '${determineStatus(snapshot.data!.data!.startDate, snapshot.data!.data!.endDate)}',
                          style: TextStyle(
                              color: Color(0xFF8A95A8),
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ],
                  ),*/
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    height: 60,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromRGBO(21, 43, 81, 1)),
                      // color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      indicatorWeight: 5,
                      //indicatorPadding: EdgeInsets.symmetric(horizontal: 1),
                      indicatorColor: const Color.fromRGBO(21, 43, 81, 1),
                      labelColor: const Color.fromRGBO(21, 43, 81, 1),
                      unselectedLabelColor: const Color.fromRGBO(21, 43, 81, 1),
                      tabs: [
                        const Tab(text: 'Summary'),
                        const Tab(
                          text: 'Application',
                        ),
                        const Tab(
                          text: 'Approved',
                        ),
                        StatefulBuilder(
                          builder: (BuildContext context,
                              void Function(void Function()) setState) {
                            return const Tab(text: 'Rejected');
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Summery_page(snapshot.data!),
                        Summery_page(snapshot.data!),
                        Summery_page(snapshot.data!),
                        Summery_page(snapshot.data!),
                        /*  SummaryPage(),
                        FinancialTable(
                            leaseId: widget.leaseId,
                            status:
                            '${determineStatus(snapshot.data!.data!.startDate, snapshot.data!.data!.endDate).toString()}'),
                        Tenant(context),*/
                      ],
                    ),
                  ),
                ],
              );
            }
          }),
    );
  }

  Summery_page(applicant_summery_details summery) {
    applicantChecklist = List<String>.from(summery.applicantCheckedChecklist!);
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: applicantCheckedChecklist.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: Color.fromRGBO(21, 43, 83, 1),
                        value:
                            summery.applicantCheckedChecklist!.contains(item),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value != false) {
                              summery.applicantCheckedChecklist!.add(item);
                              applicantChecklist.add(item);
                            } else {
                              summery.applicantCheckedChecklist!.remove(item);
                              applicantChecklist.remove(item);
                            }
                          });
                          updatecheckBox();
                        },
                      ),
                      Text(displayNames[item].toString()),
                    ],
                  ),
                );
              }).toList(),
            ),
            Column(
              children: summery.applicantChecklist!.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: Color.fromRGBO(21, 43, 83, 1),
                        value:
                            summery.applicantCheckedChecklist!.contains(item),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value != false) {
                              summery.applicantCheckedChecklist!.add(item);
                              applicantChecklist.add(item);
                            } else {
                              summery.applicantCheckedChecklist!.remove(item);
                              applicantChecklist.remove(item);
                            }
                          });
                          updatecheckBox();
                        },
                      ),
                      Text(item),
                      InkWell(
                          onTap: () {
                            summery.applicantChecklist!.remove(item);
                            updatecheckBoxnew(summery.applicantChecklist!);
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.grey,
                          )),
                    ],
                  ),
                );
              }).toList(),
            ),
            if (addcheckbox)
              Row(
                children: [
                  SizedBox(
                    height: 50,
                    width: 150,
                    child: TextFormField(
                      controller: checkvalue,
                      decoration: InputDecoration(
                          hintText: "Enter Value",
                          border: OutlineInputBorder()),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        summery.applicantChecklist!.add(checkvalue.text);
                        checkvalue.text = "";
                        addcheckbox = false;
                      });
                      updatecheckBoxnew(summery.applicantChecklist!);
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.green)),
                      child: Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        checkvalue.text = "";
                      });
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.red)),
                      child: Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  addcheckbox = !addcheckbox;
                });
                //  Navigator.pop(context);
              },
              child: Material(
                elevation: 3,
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
                child: Container(
                  height: 40,
                  width: 150,
                  decoration: const BoxDecoration(
                    //color: Color.fromRGBO(21, 43, 81, 1),
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add),
                      Center(
                          child: Text(
                        "Add Checklist",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(21, 43, 83, 1)),
                      )),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Updates",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Color.fromRGBO(21, 43, 83, 1)),
              ),
            ),
            Container(
              //width: ,
              child: DataTable(
                headingRowHeight: 10,
                columnSpacing: 20,
                  dataRowHeight:80,// Adjust spacing between columns as needed
                columns: [
                  DataColumn(label: Text('')),
                  DataColumn(label: Text('')),
                  DataColumn(label: Text('')),
                ],
                rows: summery.applicantStatus!.map((status) {
                  final statusMessage =
                      '${status.status} by ${status.statusUpdatedBy} at ${status.updateAt}';
                  return DataRow(cells: [
                    DataCell(Text(status.status!)),
                    DataCell(Text("The New Rental Application Status")),
                    DataCell(Text(statusMessage)),
                  ]);
                }).toList(),
              ),
            ),

            Container(
              child: Column(
                children: [
                  Text(
                      '${summery.applicantFirstName} ${summery.applicantLastName}',
                      style: TextStyle(
                          color: Color.fromRGBO(21, 43, 81, 1),
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 10,),
                  Text(
                      'Applicant',
                      style: TextStyle(
                          color: Color.fromRGBO(21, 43, 81, 1),
                          fontWeight: FontWeight.normal)),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Icon(Icons.home),
                      SizedBox(width: 10,),
                      Text("${summery.applicantHomeNumber}")

                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.business_center_outlined),
                      SizedBox(width: 10,),
                      Text("${summery.applicantBusinessNumber}")

                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.home),
                      SizedBox(width: 10,),
                      Text("${summery.applicantHomeNumber}")

                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  updatecheckBox() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    var checkvalue = {"applicant_checkedChecklist": applicantChecklist};
    final response = await http.put(
      Uri.parse('$Api_url/api/applicant/applicant/${widget.applicant_id}'),
      headers: <String, String>{
        "id": "CRM $id",
        "authorization": "CRM $token",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(checkvalue),
    );
    if (response.statusCode == 200) {
      // Fluttertoast.showToast(msg: 'Applicant Updated Successfully');

      setState(() {});
    } else {
      // Log the response body for debugging
      print('Failed to update data: ${response.body}');
      throw Exception('Failed to update applicant data');
    }
  }

  updatecheckBoxnew(List applicant) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    var checkvalue = {"applicant_checklist": applicant};
    final response = await http.put(
      Uri.parse(
          '$Api_url/api/applicant/applicant/${widget.applicant_id}/checklist'),
      headers: <String, String>{
        "id": "CRM $id",
        "authorization": "CRM $token",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(checkvalue),
    );
    if (response.statusCode == 200) {
      // Fluttertoast.showToast(msg: 'Applicant Updated Successfully');

      setState(() {});
    } else {
      // Log the response body for debugging
      print('Failed to update data: ${response.body}');
      throw Exception('Failed to update applicant data');
    }
  }
}
