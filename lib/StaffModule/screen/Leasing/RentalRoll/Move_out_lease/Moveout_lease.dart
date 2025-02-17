import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/screens/Rental/Properties/moveout/repository.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import '../../../../../model/LeaseSummary.dart';
import '../../../../model/LeaseSummary.dart';
import '../../../../repository/lease.dart';
import '../../../../widgets/appbar.dart';
import '../../../../widgets/custom_drawer.dart';

class MoveoutScreen extends StatefulWidget {
  final LeaseTenant tenant;
  String enddate;
  String moveOutDate;
  String leaseId;

  final List<LeaseTenant> tenants;

  MoveoutScreen({required this.tenant, required this.tenants,required this.enddate,required this.moveOutDate,required this.leaseId});

  @override
  State<MoveoutScreen> createState() => _MoveoutScreenState();
}

class _MoveoutScreenState extends State<MoveoutScreen> {
  TextEditingController startdateController = TextEditingController();
  TextEditingController enddateController = TextEditingController();
  late Future<List<LeaseTenant>> futureLeasetenant;
  bool isMovedOut = false;
  bool isLoading = false;
  @override
  void initState() {
    futureLeasetenant = LeaseRepository.fetchLeaseTenants(widget.leaseId);

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Rent Roll",
        dropdown: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 25,
            ),
            titleBar(
              width: MediaQuery.of(context).size.width * .95,
              title: 'Move Out Tenants',
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
                child: buildMoveout(widget.tenant, tenants: widget.tenants),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget buildMoveout(LeaseTenant tenant, {List<LeaseTenant>? tenants}) {
    // moveOutDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    // moveOutDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.enddate!));

    // Convert to stateful list to track selection changes
    Map<String, TextEditingController> startDateControllers = {};
    Map<String, TextEditingController> moveoutDateControllers = {};
    Map<String, String> moveOutDates = {};

    List<LeaseTenant> selectedTenants =
    tenants!.where((t) => t.moveoutDate == "").toList();

    for (var t in selectedTenants!) {
      if (!startDateControllers.containsKey(t.tenantId)) {
        startDateControllers[t.tenantId!] = TextEditingController();
      }
      if (!moveoutDateControllers.containsKey(t.tenantId)) {
        moveoutDateControllers[t.tenantId!] = TextEditingController();
      }

      // Set default values for each tenant
      startDateControllers[t.tenantId!]!.text =
          DateFormat('dd-MM-yyyy').format(DateTime.now());
      moveoutDateControllers[t.tenantId!]!.text = formatDate(t.endDate!);

      // Set default selection
      t!.isSelected = (t.tenantId == tenant.tenantId);
    }

    widget.moveOutDate = formatDate(widget.enddate!); // Store the original format
    print(formatDate(widget.enddate!));
    //startdateController.text = moveOutDate;
    startdateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    return StatefulBuilder(builder: (context, setState) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Move out Tenants",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: blueColor,
                  fontSize: MediaQuery.of(context).size.width < 500 ? 18 : 22),
            ),
            SizedBox(height: 13),
            Text(
              "Select tenants to move out. If everyone is moving, the lease will end on the last move-out date. If some tenants are staying, you’ll need to renew the lease. Note: Renters insurance policies will be permanently deleted upon move-out.",
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: MediaQuery.of(context).size.width < 500 ? 14 : 18,
                color: Color(0xFF8A95A8),
              ),
            ),
            SizedBox(height: 15),
            Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Property Details',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                          MediaQuery.of(context).size.width < 500 ? 16 : 20,
                          color: blueColor),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: blueColor),
                  ),
                  child: Table(
                    //border: TableBorder.all(color:blueColor),
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: blueColor,
                        width: 1.0,
                      ),
                    ),
                    columnWidths: {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(3),
                    },
                    children: [
                      TableRow(
                        children: [
                          buildTableCell(Text(
                            'Address/Unit',
                            style: TextStyle(
                              color: blueColor,
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width < 500
                                  ? 15
                                  : 17,
                            ),
                          )),
                          buildTableCell(Text('${tenant.rentalAddress}')),
                        ],
                      ),
                      TableRow(
                        children: [
                          buildTableCell(Text('Lease Type',
                              style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width < 500
                                    ? 15
                                    : 17,
                              ))),
                          buildTableCell(Text('${tenant.leaseType}')),
                        ],
                      ),
                      TableRow(
                        children: [
                          buildTableCell(Text('Start End',
                              style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width < 500
                                    ? 15
                                    : 17,
                              ))),
                          buildTableCell(
                              Text('${tenant.startDate} ${tenant.endDate}')),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      'Tenant Details',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                          MediaQuery.of(context).size.width < 500 ? 16 : 20,
                          color: blueColor),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Column(
                  children: selectedTenants.map((tenant) {
                    return Column(
                      children: [
                        Container(
                          //color: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 0.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: Checkbox(
                                  value: tenant!.isSelected ?? false,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      tenant!.isSelected = value ?? false;
                                    });
                                  },
                                  activeColor: blueColor,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "${tenant.tenantFirstName} ${tenant.tenantLastName}",
                                style: TextStyle(
                                    color: blueColor,
                                    fontWeight: FontWeight.bold,fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        // if (tenant!.isSelected!)
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Table(
                            border: TableBorder.all(color: blueColor),
                            columnWidths: {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(3),
                            },
                            children: [
                              TableRow(
                                children: [
                                  buildTableCell(Text('Tenants',
                                      style: TextStyle(
                                        color: blueColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context)
                                            .size
                                            .width <
                                            500
                                            ? 15
                                            : 17,
                                      ))),
                                  buildTableCell(Text(
                                      '${tenant.tenantFirstName} ${tenant.tenantLastName}',style: TextStyle(),)),
                                ],
                              ),
                              TableRow(
                                children: [
                                  buildTableCell(Text('Notice Given Date',
                                      style: TextStyle(
                                        color: blueColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context)
                                            .size
                                            .width <
                                            500
                                            ? 15
                                            : 17,
                                      ))),
                                  buildTableCell(buildDateField(
                                    startDateControllers[tenant.tenantId]!,
                                    enabled: tenant.isSelected!,
                                  )),
                                ],
                              ),
                              TableRow(
                                children: [
                                  buildTableCell(Text('Move-Out Date',
                                      style: TextStyle(
                                        color: blueColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context)
                                            .size
                                            .width <
                                            500
                                            ? 15
                                            : 17,
                                      ))),
                                  buildTableCell(buildDateField(
                                    moveoutDateControllers[tenant.tenantId]!,
                                    enabled: tenant.isSelected!,
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Material(
                    elevation: 3,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    child: Container(
                      height: MediaQuery.of(context).size.width < 500 ? 40 : 50,
                      width: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Center(
                          child: Text(
                            "Close",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: MediaQuery.of(context).size.width < 500
                                    ? 15
                                    : 18,
                                color: blueColor),
                          )),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                InkWell(
                  onTap: () async {
                    String? tenantId =
                    tenant.tenantId != null ? tenant.tenantId! : null;
                    SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                    String? id = prefs.getString("adminId");
                    List<Map<String, dynamic>> multipletenant = [];
                    for (tenant in selectedTenants) {
                      if (tenant.isSelected!) {
                        String moveoutNoticeGivenDate =
                            startDateControllers[tenant.tenantId!]!.text;
                        String moveoutdate =
                            moveoutDateControllers[tenant.tenantId!]!.text;
                        multipletenant.add({
                          'admin_id': id,
                          'tenant_id': tenant.tenantId!,
                          'lease_id': tenant.leaseId,
                          'moveout_notice_given_date':
                          reverseFormatDate(moveoutNoticeGivenDate!),
                          'moveout_date': reverseFormatDate(moveoutdate!),
                        });
                      }
                    }
                    print(multipletenant);

                    await LeaseMoveoutRepository()
                        .addMoveoutTenant(
                        adminId: id!,
                        tenantId: tenantId,
                        leaseId: tenant.leaseId,
                        moveoutDate: widget.moveOutDate,
                        moveoutNoticeGivenDate: startdateController.text,
                        multitenantdata: multipletenant)
                        .then((value) {
                      setState(() {
                        futureLeasetenant =
                            LeaseRepository.fetchLeaseTenants(widget.leaseId);

                        isLoading = false;
                        isMovedOut = true;
                      });
                      print(' moved out after  ${widget.moveOutDate!}');
                      print(' notice out after ${startdateController.text}');
                      reload_screen();
                      Navigator.pop(context, true);
                    }).catchError((e) {
                      setState(() {
                        isLoading = false;
                      });
                    });
                  },
                  child: Material(
                    elevation: 3,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    child: Container(
                      height: MediaQuery.of(context).size.width < 500 ? 40 : 50,
                      width:
                      MediaQuery.of(context).size.width < 500 ? 100 : 130,
                      decoration: BoxDecoration(
                        color: blueColor,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Center(
                          child: Text(
                            "Move Out",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize:
                              MediaQuery.of(context).size.width < 500 ? 15 : 17,
                            ),
                          )),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
          ],
        ),
      );
    });
  }
  Widget buildTableCell(Widget child) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }

  reload_screen() {
    setState(() {});
  }

  Widget buildDateField(TextEditingController controller,
      {bool enabled = false}) {
    return Padding(
      padding: EdgeInsets.only(left: 5, right: 2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(5),
          // border: Border.all(color: grey),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 5),
            child: TextField(
              controller: controller,
              enabled: enabled,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Select Date',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color.fromRGBO(
                                  21, 43, 83, 1), // header background color
                              onPrimary: Colors.white, // header text color
                              onSurface: Color.fromRGBO(
                                  21, 43, 83, 1), // body text color
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color.fromRGBO(
                                    21, 43, 83, 1), // button text color
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null) {
                      // setState(() {
                      controller.text = widget.moveOutDate!;
                      controller.text =
                          DateFormat('dd-MM-yyyy').format(pickedDate);
                      //  });
                    }
                  },
                ),
              ),
              readOnly: true,
            ),
          ),
        ),
      ),
    );
  }
}
