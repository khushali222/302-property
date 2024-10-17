import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/Model/applicant_summery_model.dart';

import 'package:three_zero_two_property/constant/constant.dart';

import '../../../../repository/applicant_summery_repo.dart';
import 'ApplicantContent.dart';
import 'ApprovedContenct.dart';
import 'RejectedContent.dart';
import 'SummaryContent.dart';
import 'package:three_zero_two_property/screens/Leasing/RentalRoll/newAddLease.dart';

import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';
// import 'package:three_zero_two_property/repository/properties_summery.dart';
import '../../../../widgets/appbar.dart';

import '../../../../widgets/drawer_tiles.dart';
import '../../../../widgets/custom_drawer.dart';

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
  String? _selectedValue = "Select";
  TabController? _tabController;
  List<String> items = ["Select", "Approved", "Rejected"];
  @override
  void initState() {
    // TODO: implement initState
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        print(result);
        _connectivityResult = result;
      });
    });
    checkInternet();
    print(widget.applicant_id);
    futureLeaseSummary =
        ApplicantSummeryRepository.getApplicantSummary(widget.applicant_id!);
    _tabController = TabController(length: 4, vsync: this);
    print('end init');
    super.initState();
  }
  ConnectivityResult? _connectivityResult ;
  void checkInternet()async{

    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });

  }

  Future<bool> updateApplicantStatus(
      String applicantId, String status, String rentalId, String unitId) async {
    print(status);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final body = jsonEncode({
      "statusUpdatedBy": "Admin",
      "status": status,
      "rental_id": rentalId,
      "unit_id": unitId,
    });

    try {
      final response = await http.put(
        Uri.parse('$Api_url/api/applicant/applicant/$applicantId/status'),
        headers: {
          'Content-Type': 'application/json',
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
        body: body,
      );

      var responseData = jsonDecode(response.body);
      print(responseData);

      if (response.statusCode == 200) {
        if (responseData['statusCode'] == 200) {
          print('Status update successful: ${responseData['data']}');
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Status updated successfully');

          return true;
        } else {
          print('Failed to update status: ${responseData}');
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Failed to update status');
          return false;
        }
      } else {
        print('Failed to update status: ${responseData}');
        Fluttertoast.showToast(
            msg: responseData['message'] ?? 'Failed to update status');
        return false;
      }
    } catch (error) {
      print('Exception occurred: $error');
      Fluttertoast.showToast(msg: 'An error occurred');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
      // appBar: widget302.,
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Applicants",
        dropdown: true,
      ),
      body: _connectivityResult != ConnectivityResult.none ?
      FutureBuilder<applicant_summery_details>(
          future: futureLeaseSummary,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SpinKitSpinningLines(
                  color: Colors.black,
                  size: 55.0,
                ),
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No data found.'));
            } else {
              final applicantSummary = snapshot.data!;
              if (snapshot.data!.applicantStatus != null &&
                  snapshot.data!.applicantStatus!.isNotEmpty) {
                final status = snapshot.data!.applicantStatus!.last.status;
                if (status == "Approved" || status == "Rejected") {
                  _selectedValue = status;
                } else {
                  _selectedValue = 'Select';
                }
              } else {
                _selectedValue = 'Select';
              }

              print('Move in is: ${applicantSummary.isMovedin ?? 'Unknown'}');
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
                              style:  TextStyle(
                                  color: blueColor,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(
                            height: 5,
                          ),
                          Text('${snapshot.data!.leaseData!.rentalAdress}',
                              style: const TextStyle(
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
                                decoration:  BoxDecoration(
                                  color: blueColor,
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
                            onChanged: snapshot.data!.isMovedin!
                                ? null
                                : (value) async {
                                    setState(() {
                                      _selectedValue = value;
                                    });
                                    if (value != null) {
                                      final rentalId =
                                          snapshot.data!.leaseData!.rentalId;
                                      final unitId =
                                          snapshot.data!.leaseData!.unitId;

                                      // Call the API to update the applicant status
                                      bool success =
                                          await updateApplicantStatus(
                                              widget.applicant_id!,
                                              value,
                                              rentalId!,
                                              unitId!);

                                      if (success) {
                                        print('Status update successful');
                                        Navigator.pop(context);
                                      } else {
                                        print('Status update failed');
                                      }
                                    }
                                  },
                            buttonStyleData: ButtonStyleData(
                              height: MediaQuery.of(context).size.width < 500
                                  ? 40
                                  : 50,
                              width: MediaQuery.of(context).size.width < 500
                                  ? MediaQuery.of(context).size.width * .35
                                  : MediaQuery.of(context).size.width * .4,
                              padding:
                                  const EdgeInsets.only(left: 14, right: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(
                                  color: snapshot.data!.isMovedin!
                                      ? Colors.grey
                                      : Color(0xFF8A95A8),
                                ),
                                color: snapshot.data!.isMovedin!
                                    ? Colors.grey.shade300
                                    : Colors.white,
                              ),
                              elevation: 0,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
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
                      _selectedValue == 'Rejected'
                          ? Container()
                          : ElevatedButton(
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(3),
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    if (states
                                        .contains(MaterialState.disabled)) {
                                      return Colors.grey; // Disabled color
                                    }
                                    return blueColor


; // Enabled color
                                  },
                                ),
                                shape: MaterialStateProperty.all(
                                  const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                  ),
                                ),
                                minimumSize: MaterialStateProperty.all(
                                    const Size(80, 40)),
                              ),
                              onPressed: snapshot.data!.isMovedin!
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => addLease3(
                                            applicantId: widget.applicant_id,
                                            rentalId: snapshot
                                                .data!.leaseData!.rentalId,
                                            unitId: snapshot
                                                .data!.leaseData!.unitId,
                                          ),
                                        ),
                                      );
                                    },
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
                          color:blueColor),
                      // color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      indicatorWeight: 5,
                      //indicatorPadding: EdgeInsets.symmetric(horizontal: 1),
                      indicatorColor:blueColor,
                      labelColor:blueColor,
                      unselectedLabelColor:blueColor,
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
                        SummaryContent(
                          applicant_id: widget.applicant_id!,
                          summery: snapshot.data!,
                        ),
                        ApplicantContent(
                          applicant_id: widget.applicant_id!,
                          applicantDetail: snapshot.data!,
                        ),
                        ApprovedContent(
                          applicantId: widget.applicant_id!,
                          applicantDetail: snapshot.data!,
                        ),
                        RejectedContent(
                          applicantId: widget.applicant_id!,
                          applicantDetail: snapshot.data!,
                        ),
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
          }): SizedBox(
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
            Text(
              'No Internet',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Check your internet connection',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Summery_page(applicant_summery_details summery) {
    applicantChecklist = List<String>.from(summery.applicantCheckedChecklist!);
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
                        activeColor: blueColor,
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
                        activeColor: blueColor,
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
                          child: const Icon(
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
                      decoration: const InputDecoration(
                          hintText: "Enter Value",
                          border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(
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
                      child: const Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(
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
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(
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
                    //color: blueColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add),
                      Center(
                          child: Text(
                        "Add Checklist",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: blueColor),
                      )),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color:blueColor),
                ),
                //width: ,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                     Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "Updates",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: blueColor),
                      ),
                    ),
                    DataTable(
                      headingRowHeight: 10,
                      columnSpacing: 20,
                      dataRowHeight:
                          80, // Adjust spacing between columns as needed
                      columns: [
                        const DataColumn(label: Text('')),
                        const DataColumn(label: Text('')),
                        const DataColumn(label: Text('')),
                      ],
                      rows: summery.applicantStatus!.map((status) {
                        final statusMessage =
                            '${status.status} by ${status.statusUpdatedBy} at ${status.updateAt}';
                        return DataRow(cells: [
                          DataCell(Text(status.status!)),
                          const DataCell(
                              Text("The New Rental Application Status")),
                          DataCell(Text(statusMessage)),
                        ]);
                      }).toList(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color:blueColor),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('View More'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color:blueColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 16, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${summery.applicantFirstName} ${summery.applicantLastName}',
                          style:  TextStyle(
                              fontSize: 16,
                              color: blueColor,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(
                        height: 5,
                      ),
                       Text('Applicant',
                          style: TextStyle(
                              color: blueColor,
                              fontWeight: FontWeight.normal)),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.home,
                            color: Color.fromRGBO(138, 149, 168, 1),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "${summery.applicantHomeNumber}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(138, 149, 168, 1),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.business_center_outlined,
                            color: Color.fromRGBO(138, 149, 168, 1),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "${summery.applicantBusinessNumber}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(138, 149, 168, 1),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.mobile,
                            color: Color.fromRGBO(138, 149, 168, 1),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "${summery.applicantPhoneNumber}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(138, 149, 168, 1),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.mail,
                            color: Color.fromRGBO(138, 149, 168, 1),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "${summery.applicantEmail}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(138, 149, 168, 1),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
