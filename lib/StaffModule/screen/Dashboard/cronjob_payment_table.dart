import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';
import '../../../Model/Dashbord_table/Payment_refund_model.dart';
import '../../../Model/Dashbord_table/cronjob_payment_table.dart';
import '../../../Model/tenants.dart' as tenant_model;
import '../../../constant/constant.dart';
import '../../../provider/dateProvider.dart';
import '../../../widgets/CustomTableShimmer.dart';
import '../../repository/Payment_cronjob/Payment_cronjob_repo.dart';
import '../../repository/Payment_cronjob/cronjob_payment_table.dart';
import '../../repository/tenants.dart';
import '../Rental/Tenants/Tenant_summary.dart';
import '../Leasing/RentalRoll/SummeryPageLease.dart';

class Cronjob_payment_table extends StatefulWidget {
  @override
  _Cronjob_payment_tableState createState() => _Cronjob_payment_tableState();
}

class _Cronjob_payment_tableState extends State<Cronjob_payment_table> {
  int totalrecords = 0;
  Future<LeaseResponse>? futurecronjobpayment;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  int currentPage = 1;
  int itemsPerPage = 5;
  List<int> itemsPerPageOptions = [
    5,
    10,
    25,
  ]; // Options for items per page

  int? expandedIndex;
  Set<int> expandedIndices = {};
  late bool isExpanded;
  bool sorting1 = false;
  bool sorting2 = false;
  bool sorting3 = false;
  bool ascending1 = false;
  bool ascending2 = false;
  bool ascending3 = false;

  final TextEditingController startDateController = TextEditingController();
  DateTime? _startDate;
  final TextEditingController endDateController = TextEditingController();
  Widget _buildHeaders(List<LeaseDatacronjob> policyList) {
    var width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        // Title with border and rounded corners
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: blueColor, // Background color
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(13),
              topRight: Radius.circular(13),
            ),
          ),
          child: Center(
            child: Text(
              "Payments Last 7 Days",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
        if (policyList.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(0),
                right: Radius.circular(0),
              ),
              border: Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              // leading: Container(
              //   child: Icon(
              //     Icons.expand_less,
              //     color: Colors.transparent,
              //   ),
              // ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Icon(
                      Icons.expand_less,
                      color: Colors.transparent,
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (sorting1 == true) {
                            sorting2 = false;
                            sorting3 = false;
                            ascending1 = sorting1 ? !ascending1 : true;
                            ascending2 = false;
                            ascending3 = false;
                          } else {
                            sorting1 = !sorting1;
                            sorting2 = false;
                            sorting3 = false;
                            ascending1 = sorting1 ? !ascending1 : true;
                            ascending2 = false;
                            ascending3 = false;
                          }

                          // Sorting logic here
                        });
                      },
                      child: Row(
                        children: [
                          width < 400
                              ? Text("  Rental\n Address",
                                  style: TextStyle(
                                    color: Color.fromRGBO(50, 75, 119, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ))
                              : Text("  Rental\n Address",
                                  style: TextStyle(
                                    color: Color.fromRGBO(50, 75, 119, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  )),
                          // Text("Property", style: TextStyle(color: Colors.white)),
                          SizedBox(width: 3),
                          // ascending1
                          //     ? Padding(
                          //         padding: const EdgeInsets.only(top: 7, left: 2),
                          //         child: FaIcon(
                          //           FontAwesomeIcons.sortUp,
                          //           size: 20,
                          //           color: Colors.white,
                          //         ),
                          //       )
                          //     : Padding(
                          //         padding: const EdgeInsets.only(bottom: 7, left: 2),
                          //         child: FaIcon(
                          //           FontAwesomeIcons.sortDown,
                          //           size: 20,
                          //           color: Colors.white,
                          //         ),
                          //       ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (sorting2) {
                            sorting1 = false;
                            sorting2 = sorting2;
                            sorting3 = false;
                            ascending2 = sorting2 ? !ascending2 : true;
                            ascending1 = false;
                            ascending3 = false;
                          } else {
                            sorting1 = false;
                            sorting2 = !sorting2;
                            sorting3 = false;
                            ascending2 = sorting2 ? !ascending2 : true;
                            ascending1 = false;
                            ascending3 = false;
                          }
                          // Sorting logic here
                        });
                      },
                      child: Row(
                        children: [
                          Text("     Tenant\n      Name",
                              style: TextStyle(
                                color: Color.fromRGBO(50, 75, 119, 1),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              )),
                          // SizedBox(width: 5),
                          // ascending2
                          //     ? Padding(
                          //         padding: const EdgeInsets.only(top: 7, left: 2),
                          //         child: FaIcon(
                          //           FontAwesomeIcons.sortUp,
                          //           size: 20,
                          //           color: Colors.white,
                          //         ),
                          //       )
                          //     : Padding(
                          //         padding: const EdgeInsets.only(bottom: 7, left: 2),
                          //         child: FaIcon(
                          //           FontAwesomeIcons.sortDown,
                          //           size: 20,
                          //           color: Colors.white,
                          //         ),
                          //       ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (sorting3) {
                            sorting1 = false;
                            sorting2 = false;
                            sorting3 = sorting3;
                            ascending3 = sorting3 ? !ascending3 : true;
                            ascending2 = false;
                            ascending1 = false;
                          } else {
                            sorting1 = false;
                            sorting2 = false;
                            sorting3 = !sorting3;
                            ascending3 = sorting3 ? !ascending3 : true;
                            ascending2 = false;
                            ascending1 = false;
                          }

                          // Sorting logic here
                        });
                      },
                      child: Row(
                        children: [
                          Text("      Response",
                              style: TextStyle(
                                color: Color.fromRGBO(50, 75, 119, 1),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              )),
                          SizedBox(width: 5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (policyList.isEmpty)
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade300, // Background color
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(13),
                bottomRight: Radius.circular(13),
              ),
            ),
            child: Center(
              child: Text(
                "No failed payment data found.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: blueColor,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget paymentCard(
    String name,
    String address,
    String amount,
    bool isExpanded,
    VoidCallback onExpandTap,
    LeaseDatacronjob data,
  ) {
    final dateProvider = Provider.of<DateProvider>(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onExpandTap,
                child: Container(
                  width: 20,
                  height: 20,
                  child: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: blueColor,
                  ),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // Fetch tenant data first using the tenantId
                        if (data.tenant?.tenantId != null) {
                          List<tenant_model.Tenant> tenantData =
                              await TenantsRepository().fetchTenantsummery(
                                      data.tenant!.tenantId!) ??
                                  [];
                          if (tenantData.isNotEmpty) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ResponsiveTenantSummary(
                                            tenants: tenantData.first,
                                            tenantId: data.tenant!.tenantId!)));
                          }
                        }
                      },
                      child: Text(name, style: cardTextStyle),
                    ),
                    // SizedBox(height: 2),
                    // GestureDetector(
                    //   onTap: () {
                    //     if (data.leaseId != null) {
                    //       Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //               builder: (context) => SummeryPageLease(
                    //                     leaseId: data.leaseId!,
                    //                     enddate:
                    //                         null, // You can pass the end date if available
                    //                   )));
                    //     }
                    //   },
                    //   child: Text(
                    //     address,
                    //     style: cardTextStyle.copyWith(
                    //       fontSize: 14,
                    //       color: blueColor.withOpacity(0.8),
                    //       decoration: TextDecoration.underline,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              Text('\$$amount', style: cardTextStyle)
            ],
          ),
          if (isExpanded)
            Column(
              children: [
                Divider(
                  thickness: 2,
                ),
                const SizedBox(height: 4),
                // First row: Date & Response
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date: ',
                            style: subTextStyle.copyWith(
                              color: blueColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            dateProvider
                                .formatCurrentDate('${data.date ?? "-"}'),
                            style: subTextStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Response: ',
                            style: subTextStyle.copyWith(
                              color: blueColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            data.response ?? "-",
                            style: subTextStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Second row: Type & Description
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Type: ',
                            style: subTextStyle.copyWith(
                              color: blueColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            data.paymenttype ?? "-",
                            style: subTextStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Description: ',
                            style: subTextStyle.copyWith(
                              color: blueColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            data.responseText?.isNotEmpty == true
                                ? ' ${data.responseText}'
                                : 'N/A',
                            style: subTextStyle,
                            // overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Rental Address & Action header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (data.leaseId != null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SummeryPageLease(
                                        leaseId: data.leaseId!,
                                        enddate:
                                            null, // You can pass the end date if available
                                      )));
                        }
                      },
                      child: Text(
                        'Rental Address',
                        style: subTextStyle.copyWith(
                          color: blueColor,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Text(
                      'Action',
                      style: subTextStyle.copyWith(
                        color: blueColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Rental Address & Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (data.leaseId != null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SummeryPageLease(
                                        leaseId: data.leaseId!,
                                        enddate:
                                            null, // You can pass the end date if available
                                      )));
                        }
                      },
                      child: Text(
                        address,
                        style: subTextStyle.copyWith(
                          decoration: TextDecoration.underline,
                          color: blueColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                    if (data.response == "FAILURE")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (data.id != null) {
                                _showAlertAcknowledgement(
                                    context, data.id!, failureacknowledged);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              height: 30,
                              width: 30,
                              child: Icon(Icons.check, color: blueColor),
                            ),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              if (data.id != null) {
                                _showAlertRetry(context, data.id!);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              height: 30,
                              width: 30,
                              child: Icon(Icons.recycling_outlined,
                                  color: blueColor),
                            ),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              if (data.id != null) {
                                _showAlertSchedule(context, data.id!);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              height: 30,
                              width: 30,
                              child: Icon(Icons.calendar_month_outlined,
                                  color: blueColor),
                            ),
                          ),
                        ],
                      ),
                    if (data.response == "SUCCESS" && data.state == "settled")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (data.id != null) {
                                _showAlertRefund(context, data.id!);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              height: 30,
                              width: 30,
                              child: FaIcon(
                                FontAwesomeIcons.reply,
                                size: 15,
                                color: blueColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    if (data.response == "SUCCESS" && data.state == "settling")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (data.id != null) {
                                _showAlertvoid(context, data.id!);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              height: 30,
                              width: 30,
                              child: Icon(
                                Icons.money_off,
                                size: 20,
                                weight: 30,
                                color: blueColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
        ],
      ),
    );
  }

  final List<String> items = ['Residential', "Commercial", "All"];
  String? selectedValue;
  String searchvalue = "";
  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectivityResult = result;
        if (_connectivityResult != ConnectivityResult.none)
          futurecronjobpayment = cronjob_payment_tableService()
              .fetchCronjob_payment(limit: 5, page: 1);
      });
    });
    checkInternet();
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });

    if (_connectivityResult != ConnectivityResult.none)
      futurecronjobpayment =
          cronjob_payment_tableService().fetchCronjob_payment();
  }

  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  void _changeRowsPerPage(int selectedRowsPerPage) {
    setState(() {
      _rowsPerPage = selectedRowsPerPage;
      _currentPage = 0; // Reset to the first page when changing rows per page
    });
  }

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(LeaseDatacronjob d)? getField) {
    return TableCell(
      child: InkWell(
        // onTap: getField != null
        //     ? () {
        //         _sort(getField, columnIndex, !_sortAscending);
        //       }
        //     : null,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              Text(text,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              if (_sortColumnIndex == columnIndex)
                Icon(_sortAscending
                    ? Icons.arrow_drop_down_outlined
                    : Icons.arrow_drop_up_outlined),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 16),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  ConnectivityResult? _connectivityResult;
  final _scrollController = ScrollController();
  bool failureacknowledged = true;
  void _showAlertAcknowledgement(
    BuildContext context,
    String id,
    bool failureacknowledged,
  ) {
    TextEditingController reason = TextEditingController();
    Alert(
      context: context,
      type: AlertType.warning,
      title: null,
      desc: null,
      style: AlertStyle(
        backgroundColor: Colors.white,
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15),
          Text(
            "Payment Acknowledgement",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 15),
          Text(
            "Are you sure you want to acknowledge this payment as Failed?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Confirm",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            Navigator.pop(context);
            var data = await PaymentCronjobRepository().Paymentacknowledge(
                paymentid: id,
                failureacknowledged: failureacknowledged,
                context: context);
            // Add your delete logic here
            if (data != null)
              setState(() {
                futurecronjobpayment = cronjob_payment_tableService()
                    .fetchCronjob_payment(limit: itemsPerPage);
              });
          },
          color: blueColor,
        ),
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(
                color: blueColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
          radius: BorderRadius.circular(8), // Rounded corners
          border: Border.all(
            color: blueColor, // Blue border
            width: 1.5,
          ),
        ),
      ],
    ).show();
  }

  void _showAlertRetry(BuildContext context, String id) {
    TextEditingController retrydate = TextEditingController();
    Alert(
      context: context,
      type: AlertType.warning,
      title: null,
      desc: null,
      style: AlertStyle(
        backgroundColor: Colors.white,
      ),
      content: Column(
        children: [
          SizedBox(height: 15),
          Text(
            "Payment Retry",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 15),
          Text(
            "Retry this payment now?",
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Yes",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          // onPressed: (){},
          onPressed: () async {
            Navigator.pop(context);
            var data = await PaymentCronjobRepository().PaymentRetry(
              retryDate: retrydate.text,
              paymentid: id,
              context: context,
            );
            // Add your delete logic here
            if (data != null)
              setState(() {
                futurecronjobpayment = cronjob_payment_tableService()
                    .fetchCronjob_payment(limit: itemsPerPage);
              });
            // Navigator.pop(context);
          },
          color: blueColor,
        ),
        DialogButton(
          child: Text(
            "No",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.grey,
        ),
      ],
    ).show();
  }

  void _showAlertSchedule(BuildContext context, String id) {
    TextEditingController retrydate = TextEditingController();
    Alert(
      context: context,
      type: AlertType.warning,
      title: null,
      desc: null,
      content: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 15),
          Text(
            "Reschedule Payment",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Please select a payment date to retry. The date must be tomorrow or later:",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: CustomTextField(
              onTap: () async {
                DateTime now = DateTime.now();
                DateTime tomorrow = now.add(Duration(days: 1));
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: tomorrow,
                  firstDate: tomorrow,
                  lastDate: DateTime(2101),
                  locale: const Locale('en', 'US'),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: ColorScheme.light(
                          primary: blueColor,
                          onPrimary: Colors.white,
                          onSurface: blueColor,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: blueColor,
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (pickedDate != null) {
                  setState(() {
                    retrydate.text =
                        pickedDate.toLocal().toString().split(' ')[0];
                  });
                }
              },
              readOnnly: true,
              suffixIcon: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.date_range_rounded),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select end date';
                }
                return null;
              },
              optional: true,
              keyboardType: TextInputType.text,
              hintText: 'Select a date',
              controller: retrydate,
            ),
          ),
        ],
      ),
      style: AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Confirm",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          // onPressed: (){},
          onPressed: () async {
            if (retrydate.text.isEmpty) {
              // setState(() {
              //  _errorText == true;
              // });
              Fluttertoast.showToast(msg: "Please select the retry date");
            } else {
              Navigator.pop(context);
              var data = await PaymentCronjobRepository().PaymentReSchedule(
                retryDate: retrydate.text,
                paymentid: id,
                context: context,
              );
              // Add your delete logic here
              if (data != null)
                setState(() {
                  futurecronjobpayment = cronjob_payment_tableService()
                      .fetchCronjob_payment(limit: itemsPerPage);
                });
              // Navigator.pop(context);
            }
          },
          color: blueColor,
        ),
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(
                color: blueColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
          radius: BorderRadius.circular(8), // Rounded corners
          border: Border.all(
            color: blueColor, // Blue border
            width: 1.5,
          ),
        ),
      ],
    ).show();
  }

  final cardTextStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: blueColor);
  final subTextStyle = TextStyle(
      color: Colors.grey[700], fontWeight: FontWeight.bold, fontSize: 14);
  Future<void> _showAlertRefund(BuildContext context, String id) async {
    TextEditingController retrydate = TextEditingController();
    TextEditingController amount = TextEditingController();
    TextEditingController memo = TextEditingController();
    List<PaymentRefund> refunds =
        await PaymentCronjobRepository().fetchPaymentRefunds(id);
    PaymentRefund? refund = refunds.isNotEmpty ? refunds.first : null;

    if (refund != null) {
      if (refund.entry != null && refund.entry!.isNotEmpty) {
        retrydate.text = refund.entry!.first.date ?? "";
      }
      amount.text = refund.totalAmount?.toString() ?? "0.0";
      print(" r ${refund.entry}");
    }

    Alert(
      context: context,
      content: Column(
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: Container(
                  // height: 50.0,
                  height: (MediaQuery.of(context).size.width < 500) ? 50 : 60,
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.width < 500 ? 9 : 5,
                      left: 10),
                  margin: const EdgeInsets.only(bottom: 6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: blueColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0),
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: Text(
                    "Make Refund",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Text(
                "Date",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: blueColor),
              ),
            ],
          ),
          SizedBox(
            height: 4,
          ),
          SizedBox(
            height: 60,
            child: CustomTextField(
              onTap: () async {
                DateTime now = DateTime.now();
                DateTime tomorrow = now.add(Duration(days: 1));
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: tomorrow,
                  firstDate: DateTime(
                      2000), // Restrict selection to tomorrow and future dates
                  lastDate: DateTime(2101),
                  locale: const Locale('en', 'US'),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: ColorScheme.light(
                          primary: blueColor, // header background color
                          onPrimary: Colors.white, // header text color
                          onSurface: blueColor, // body text color
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: blueColor, // button text color
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (pickedDate != null) {
                  setState(() {
                    retrydate.text =
                        pickedDate.toLocal().toString().split(' ')[0];
                    // This ensures the date appears as selected in yyyy-MM-dd format
                  });
                }
              },
              readOnnly: true,
              suffixIcon: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.date_range_rounded),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select end date';
                }
                return null;
              },
              optional: true,
              keyboardType: TextInputType.text,
              hintText: 'Select a date',
              controller: retrydate,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Text(
                "Refund Amount*",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: blueColor),
              ),
            ],
          ),
          SizedBox(
            height: 4,
          ),
          SizedBox(
            height: 45,
            child: TextField(
              controller: amount,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter reason for void',
                contentPadding: EdgeInsets.only(top: 8, left: 15),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Text(
                "Memo",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: blueColor),
              ),
            ],
          ),
          SizedBox(
            height: 4,
          ),
          SizedBox(
            height: 45,
            child: TextField(
              controller: memo,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "if left blank , will show'Payment'",
                contentPadding: EdgeInsets.only(top: 8, left: 15),
              ),
            ),
          ),
        ],
      ),
      style: AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Confirm",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            if (retrydate.text.isEmpty) {
              Fluttertoast.showToast(msg: "Please select the refund date");
              return;
            }

            if (amount.text.isEmpty || double.tryParse(amount.text) == null) {
              Fluttertoast.showToast(msg: "Please enter a valid refund amount");
              return;
            }

            Navigator.pop(context);

            var response = await PaymentCronjobRepository().confirmRefund(
              paymentId: id,
              paymentType: refund?.paymentType ?? "",
              transactionId: refund?.transactionId ?? "",
              refundAmount: double.parse(amount.text),
              refundDate: retrydate.text,
              memo: memo.text,
              tenantFirstName: refund?.tenantData?.tenantFirstName ?? "",
              tenantLastName: refund?.tenantData?.tenantLastName ?? "",
              tenantEmail: refund?.tenantData?.tenantEmail ?? "",
              tenantId: refund?.tenantData?.tenantId ?? "",
              leaseId: refund?.leaseData?.leaseId ?? "",
              customerVaultId: refund?.customerVaultId.toString() ?? "",
              billingId: refund?.billingId.toString() ?? "",
              context: context,
              entry: (refund?.entry ?? [])
                  .map((item) => {
                        "amount": item.amount,
                        "account": item.account,
                        "date": item.date,
                        "memo": item.memo,
                      })
                  .toList(),
            );

            if (response != null) {
              setState(() {
                futurecronjobpayment = cronjob_payment_tableService()
                    .fetchCronjob_payment(limit: itemsPerPage);
              });
              Alert(
                context: context,
                type: AlertType.success,
                title: "Success",
                desc: "Refund Done Successfully",
                style: AlertStyle(
                  backgroundColor: Colors.white,
                ),
                buttons: [
                  DialogButton(
                    child: Text(
                      "Ok",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    onPressed: () => Navigator.pop(context),
                    color: blueColor,
                  ),
                ],
              ).show();
              //Fluttertoast.showToast(msg: "Refund Done Successfully");
            } else {
              Fluttertoast.showToast(msg: "Failed to process refund");
            }
          },
          // onPressed: () async {
          //   if (retrydate.text.isEmpty) {
          //     // setState(() {
          //     //  _errorText == true;
          //     // });
          //     Fluttertoast.showToast(msg: "Please select the retry date");
          //   } else {
          //     Navigator.pop(context);
          //     var data = await PaymentCronjobRepository().PaymentReSchedule(
          //       retryDate: retrydate.text,
          //       paymentid: id,
          //       context: context,
          //     );
          //     // Add your delete logic here
          //     if (data != null)
          //       setState(() {
          //         futurecronjobpayment = cronjob_payment_tableService()
          //             .fetchCronjob_payment(limit: itemsPerPage);
          //       });
          //     // Navigator.pop(context);
          //   }
          // },

          color: blueColor,
        ),
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(
                color: blueColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
          radius: BorderRadius.circular(8), // Rounded corners
          border: Border.all(
            color: blueColor, // Blue border
            width: 1.5,
          ),
        ),
      ],
    ).show();
  }

  void _showAlertvoid(BuildContext context, String id) {
    TextEditingController reason = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // prevent dismiss on outside tap
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isReasonEntered = reason.text.trim().isNotEmpty;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange, width: 3),
                    ),
                    child: const Center(
                      child: Text(
                        '!',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Are you sure you want to void this payment?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "A void can be issued on this payment until it is settled",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reason,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Enter reason for void',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isReasonEntered
                              ? () async {
                                  Navigator.pop(context);
                                  var data =
                                      await PaymentCronjobRepository().VoidCron(
                                    pay_id: id,
                                    void_reason: reason.text.trim(),
                                    context: context,
                                  );
                                  if (data != null) {
                                    // refresh data
                                    futurecronjobpayment =
                                        cronjob_payment_tableService()
                                            .fetchCronjob_payment(
                                                limit: itemsPerPage);
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isReasonEntered ? blueColor : Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Void",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DialogButton(
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                                color: blueColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Alert(
                              type: AlertType.warning,
                              title: "Void Cancelled",
                              context: context,
                              buttons: [
                                DialogButton(
                                  child: Text(
                                    "Ok",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                    Navigator.pop(context);
                                  },
                                  color: blueColor,
                                ),
                              ],
                            ).show();
                          },
                          color: Colors.white,
                          radius: BorderRadius.circular(8), // Rounded corners
                          border: Border.all(
                            color: blueColor, // Blue border
                            width: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    //final themeProvider = Provider.of<ThemeProvider>(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          //SizedBox(height: 20),
          //Text("Renter's Insurance Policies Expiring Within 90 days",style: TextStyle(fontWeight: FontWeight.bold,color: blueColor),),
          if (MediaQuery.of(context).size.width < 500)
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: FutureBuilder<LeaseResponse>(
                future: futurecronjobpayment,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ColabShimmerLoadingWidget();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData ||
                      snapshot.data?.data?.isEmpty != false) {
                    return Container(
                      child: Center(
                        child: Column(
                          children: [
                            _buildHeaders([]),
                            // Container(
                            //   padding: EdgeInsets.all(10),
                            //   decoration: BoxDecoration(
                            //     color: Colors.grey.shade300, // Background color
                            //     borderRadius: BorderRadius.only(
                            //       bottomLeft: Radius.circular(13),
                            //       bottomRight: Radius.circular(13),
                            //     ),
                            //   ),
                            //   child: Center(
                            //     child: Text(
                            //       "No policies are expiring within 90 days.",
                            //       textAlign: TextAlign.center,
                            //       style: TextStyle(
                            //         fontWeight: FontWeight.bold,
                            //         color: blueColor,
                            //         fontSize: 14,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    var data = snapshot.data?.data ?? [];
                    print("data ${data.length}");
                    // if (selectedValue == null && searchvalue!.isEmpty) {
                    //   data = snapshot.data!;
                    // } else if (selectedValue == "All") {
                    //   data = snapshot.data!;
                    // } else if (searchvalue!.isNotEmpty) {
                    //   data = snapshot.data!
                    //       .where((property) => property.rentalAddress!
                    //           .toLowerCase()
                    //           .contains(searchvalue!.toLowerCase()))
                    //       .toList();
                    // } else {
                    //   data = snapshot.data!
                    //       .where((property) =>
                    //           property.rentalAddress == selectedValue)
                    //       .toList();
                    // }
                    // if (data.isEmpty) {
                    //   return Center(
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       crossAxisAlignment: CrossAxisAlignment.center,
                    //       children: [
                    //         Image.asset(
                    //           "assets/images/no_data.jpg",
                    //           height: 200,
                    //           width: 200,
                    //         ),
                    //         SizedBox(
                    //           height: 10,
                    //         ),
                    //         Text(
                    //           "No Data Available",
                    //           style: TextStyle(
                    //               fontWeight: FontWeight.bold,
                    //               color: blueColor,
                    //               fontSize: 16),
                    //         )
                    //       ],
                    //     ),
                    //   );
                    // }
                    //sortData(data);
                    final totalPages =
                        ((snapshot.data?.metadata?.total ?? 0) / itemsPerPage)
                            .ceil();

                    // final currentPageData = data
                    //     .skip(currentPage * itemsPerPage)
                    //     .take(itemsPerPage)
                    //     .toList();
                    final currentPageData = data;
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Text("Payments Last 7 Days",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: blueColor)),
                          // _buildHeaders(data),
                          SizedBox(height: 1),
                          Container(
                            // decoration: BoxDecoration(
                            //     border: Border.all(
                            //         color: Color.fromRGBO(152, 162, 179, .5))),
                            // decoration: BoxDecoration(
                            //     border: Border.all(color: blueColor)),
                            child: Column(
                              children:
                                  currentPageData.asMap().entries.map((entry) {
                                int index = entry.key;
                                bool isExpanded = expandedIndex == index;
                                LeaseDatacronjob Propertytype = entry.value;

                                return Container(
                                  child: paymentCard(
                                    Propertytype.tenant?.tenantName ??
                                        "Unknown Tenant",
                                    Propertytype.rentalAddress ??
                                        "Unknown Address",
                                    Propertytype.totalAmount
                                            ?.toStringAsFixed(2) ??
                                        "0.00",
                                    isExpanded,
                                    () {
                                      setState(() {
                                        expandedIndex =
                                            isExpanded ? null : index;
                                      });
                                    },
                                    Propertytype,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: 20),
                          if (data.length > 5)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    // Text('Rows per page:'),
                                    SizedBox(width: 10),
                                    Material(
                                      elevation: 3,
                                      child: Container(
                                        height: 40,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12.0),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            value: itemsPerPage,
                                            items: itemsPerPageOptions
                                                .map((int value) {
                                              return DropdownMenuItem<int>(
                                                value: value,
                                                child: Text(value.toString()),
                                              );
                                            }).toList(),
                                            onChanged: (snapshot.data?.metadata
                                                            ?.total ??
                                                        0) >
                                                    itemsPerPageOptions
                                                        .first // Condition to check if dropdown should be enabled
                                                ? (newValue) {
                                                    setState(() {
                                                      itemsPerPage = newValue ??
                                                          itemsPerPage;
                                                      currentPage =
                                                          1; // Reset to first page when items per page change
                                                      futurecronjobpayment =
                                                          cronjob_payment_tableService()
                                                              .fetchCronjob_payment(
                                                                  limit:
                                                                      itemsPerPage,
                                                                  page:
                                                                      currentPage);
                                                    });
                                                  }
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: FaIcon(
                                        FontAwesomeIcons.circleChevronLeft,
                                        color: currentPage == 1
                                            ? Colors.grey
                                            : blueColor,
                                      ),
                                      onPressed: currentPage == 1
                                          ? null
                                          : () {
                                              setState(() {
                                                currentPage--;
                                                futurecronjobpayment =
                                                    cronjob_payment_tableService()
                                                        .fetchCronjob_payment(
                                                            limit: itemsPerPage,
                                                            page: currentPage);
                                              });
                                            },
                                    ),
                                    Text('Page ${currentPage} of $totalPages'),
                                    IconButton(
                                      icon: FaIcon(
                                        FontAwesomeIcons.circleChevronRight,
                                        color: currentPage < totalPages
                                            ? blueColor
                                            : Colors.grey,
                                      ),
                                      onPressed: currentPage < totalPages
                                          ? () {
                                              setState(() {
                                                currentPage++;
                                                futurecronjobpayment =
                                                    cronjob_payment_tableService()
                                                        .fetchCronjob_payment(
                                                            limit: itemsPerPage,
                                                            page: currentPage);
                                              });
                                            }
                                          : null,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          // if (MediaQuery.of(context).size.width > 500)
          //   FutureBuilder<LeaseResponse>(
          //     future: futurecronjobpayment,
          //     builder: (context, snapshot) {
          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return ShimmerTabletTable();
          //       } else if (snapshot.hasError) {
          //         return Center(child: Text('Error: ${snapshot.error}'));
          //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          //         return Container(
          //           height: MediaQuery.of(context).size.height * .5,
          //           child: Center(
          //             child: Column(
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               crossAxisAlignment: CrossAxisAlignment.center,
          //               children: [
          //                 Image.asset(
          //                   "assets/images/no_data.jpg",
          //                   height: 200,
          //                   width: 200,
          //                 ),
          //                 SizedBox(
          //                   height: 10,
          //                 ),
          //                 Text(
          //                   "No Data Available",
          //                   style: TextStyle(
          //                       fontWeight: FontWeight.bold,
          //                       color: blueColor,
          //                       fontSize: 16),
          //                 )
          //               ],
          //             ),
          //           ),
          //         );
          //       } else {
          //         _tableData = snapshot.data!;
          //         if (selectedValue == null && searchvalue.isEmpty) {
          //           _tableData = snapshot.data!;
          //         } else if (selectedValue == "All") {
          //           _tableData = snapshot.data!;
          //         } else if (searchvalue.isNotEmpty) {
          //           _tableData = snapshot.data!
          //               .where((property) => property.rentalAddress!
          //                   .toLowerCase()
          //                   .contains(searchvalue.toLowerCase()))
          //               .toList();
          //         } else {
          //           _tableData = snapshot.data!
          //               .where((property) =>
          //                   property.rentalAddress == selectedValue)
          //               .toList();
          //         }
          //         totalrecords = _tableData.length;
          //         return SingleChildScrollView(
          //           child: Column(
          //             children: [
          //               Container(
          //                 child: Padding(
          //                   padding: const EdgeInsets.symmetric(
          //                       horizontal: 24.0, vertical: 5),
          //                   child: Column(
          //                     children: [
          //                       SingleChildScrollView(
          //                         scrollDirection: Axis.horizontal,
          //                         child: Container(
          //                           width:
          //                               MediaQuery.of(context).size.width * .91,
          //                           child: Table(
          //                             defaultColumnWidth:
          //                                 IntrinsicColumnWidth(),
          //                             children: [
          //                               TableRow(
          //                                 decoration: BoxDecoration(
          //                                   border: Border.all(
          //                                       // color: blueColor
          //                                       ),
          //                                 ),
          //                                 children: [
          //
          //                                   _buildHeader(
          //                                       'Main Type',
          //                                       0,
          //                                       (property) => property
          //                                           .tenant!.tenantName!),
          //                                   _buildHeader(
          //                                       'Subtype',
          //                                       1,
          //                                       (property) =>
          //                                           property.rentalAddress!),
          //                                   _buildHeader('Created At', 2,
          //                                       (property) => property.date!),
          //                                 ],
          //                               ),
          //                               TableRow(
          //                                 decoration: BoxDecoration(
          //                                   border: Border.symmetric(
          //                                       horizontal: BorderSide.none),
          //                                 ),
          //                                 children: List.generate(
          //                                     3,
          //                                     (index) => TableCell(
          //                                         child:
          //                                             Container(height: 20))),
          //                               ),
          //                               for (var i = 0;
          //                                   i < _pagedData.length;
          //                                   i++)
          //                                 TableRow(
          //                                   decoration: BoxDecoration(
          //                                     border: Border(
          //                                       left: BorderSide(
          //                                           color: blueColor),
          //                                       right: BorderSide(
          //                                           color: blueColor),
          //                                       top: BorderSide(
          //                                           color: blueColor),
          //                                       bottom:
          //                                           i == _pagedData.length - 1
          //                                               ? BorderSide(
          //                                                   color: blueColor)
          //                                               : BorderSide.none,
          //                                     ),
          //                                   ),
          //                                   children: [
          //                                     _buildDataCell(_pagedData[i]
          //                                         .tenant!
          //                                         .tenantName!),
          //                                     _buildDataCell(
          //                                         _pagedData[i].rentalAddress!),
          //                                     _buildDataCell(
          //                                       formatDate(_pagedData[i].date!),
          //                                     ),
          //                                   ],
          //                                 ),
          //                             ],
          //                           ),
          //                         ),
          //                       ),
          //                       SizedBox(height: 25),
          //                       _buildPaginationControls(),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //               SizedBox(height: 25),
          //             ],
          //           ),
          //         );
          //       }
          //     },
          //   ),
        ],
      ),
    );
  }
}
