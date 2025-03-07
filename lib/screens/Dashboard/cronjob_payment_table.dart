import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../Model/Dashbord_table/Payment_refund_model.dart';
import '../../Model/Dashbord_table/cronjob_payment_table.dart';

import '../../constant/constant.dart';

import '../../provider/dateProvider.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';
import '../../repository/Payment_cronjob/Payment_cronjob_repo.dart';
import '../../repository/dashboard_table_repo/cronjob_payment_table.dart';
import '../../widgets/CustomTableShimmer.dart';
import '../../widgets/titleBar.dart';

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

  // void sortData(List<LeaseDatacronjob> data) {
  //   if (sorting1) {
  //     data.sort((a, b) => ascending1
  //         ? a.propertyType!.compareTo(b.propertyType!)
  //         : b.propertyType!.compareTo(a.propertyType!));
  //   } else if (sorting2) {
  //     data.sort((a, b) => ascending2
  //         ? a.propertysubType!.compareTo(b.propertysubType!)
  //         : b.propertysubType!.compareTo(a.propertysubType!));
  //   } else if (sorting3) {
  //     data.sort((a, b) => ascending3
  //         ? a.createdAt!.compareTo(b.createdAt!)
  //         : b.createdAt!.compareTo(a.createdAt!));
  //   }
  // }

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
              "Failed Payment Log",
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

  // LeaseResponse get _pagedData {
  //   int startIndex = _currentPage * _rowsPerPage;
  //   int endIndex = startIndex + _rowsPerPage;
  //   return _tableData.sublist(startIndex,
  //       endIndex > _tableData.length ? _tableData.length : endIndex);
  // }

  void _changeRowsPerPage(int selectedRowsPerPage) {
    setState(() {
      _rowsPerPage = selectedRowsPerPage;
      _currentPage = 0; // Reset to the first page when changing rows per page
    });
  }
  //
  // void _sort<T>(Comparable<T> Function(LeaseDatacronjob d) getField,
  //     int columnIndex, bool ascending) {
  //   setState(() {
  //     _sortColumnIndex = columnIndex;
  //     _sortAscending = ascending;
  //     _tableData.sort((a, b) {
  //       final aValue = getField(a);
  //       final bValue = getField(b);
  //       final result = aValue.compareTo(bValue as T);
  //       return _sortAscending ? result : -result;
  //     });
  //   });
  // }

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

  // Widget _buildPaginationControls() {
  //   int numorpages = 1;
  //   numorpages = (totalrecords / _rowsPerPage).ceil();
  //
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.end,
  //     children: [
  //       // Text('Rows per page: '),
  //       // SizedBox(width: 10),
  //       Material(
  //         elevation: 2,
  //         color: Colors.white,
  //         child: Container(
  //           height: 55,
  //           padding: EdgeInsets.symmetric(horizontal: 12.0),
  //           decoration: BoxDecoration(
  //             border: Border.all(color: Colors.grey),
  //             borderRadius: BorderRadius.circular(4.0),
  //           ),
  //           child: DropdownButtonHideUnderline(
  //             child: DropdownButton<int>(
  //               value: _rowsPerPage,
  //               items: [10, 25, 50, 100].map((int value) {
  //                 return DropdownMenuItem<int>(
  //                   value: value,
  //                   child: Text(value.toString()),
  //                 );
  //               }).toList(),
  //               onChanged: (newValue) {
  //                 if (newValue != null) {
  //                   _changeRowsPerPage(newValue);
  //                 }
  //               },
  //               icon: Icon(
  //                 Icons.arrow_drop_down,
  //                 size: 40,
  //               ),
  //               style: TextStyle(color: Colors.black, fontSize: 17),
  //               dropdownColor: Colors.white,
  //             ),
  //           ),
  //         ),
  //       ),
  //       SizedBox(width: 10),
  //       IconButton(
  //         icon: FaIcon(
  //           FontAwesomeIcons.circleChevronLeft,
  //           size: 30,
  //           color: _currentPage == 0 ? Colors.grey : blueColor,
  //         ),
  //         onPressed: _currentPage == 0
  //             ? null
  //             : () {
  //                 setState(() {
  //                   _currentPage--;
  //                 });
  //               },
  //       ),
  //       Text(
  //         'Page ${_currentPage + 1} of $numorpages',
  //         style: TextStyle(fontSize: 18),
  //       ),
  //       IconButton(
  //         icon: FaIcon(
  //           size: 30,
  //           FontAwesomeIcons.circleChevronRight,
  //           color: (_currentPage + 1) * _rowsPerPage >= _tableData.length
  //               ? Colors.grey
  //               : blueColor, // Change color based on availability
  //         ),
  //         onPressed: (_currentPage + 1) * _rowsPerPage >= _tableData.length
  //             ? null
  //             : () {
  //                 setState(() {
  //                   _currentPage++;
  //                 });
  //               },
  //       ),
  //     ],
  //   );
  // }

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
      title: "Payment Acknowledgement",
      desc: "Are you sure you want to acknowledge this payment as Failed?",
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
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.grey,
        ),
      ],
    ).show();
  }

  void _showAlertRetry(BuildContext context, String id) {
    TextEditingController retrydate = TextEditingController();
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Payment Retry",
      desc: "Retry this payment now?",
      style: AlertStyle(
        backgroundColor: Colors.white,
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
      title: "Payment ReSchedule",
      desc:
          "Please select a payment date to retry. The date must be tomorrow or later :",
      content: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
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
                  firstDate:
                      tomorrow, // Restrict selection to tomorrow and future dates
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

          // if (_errorText)
          //   Text(
          //     "Please fill in all fields correctly.",
          //     style: TextStyle(color: Colors.redAccent),
          //   ),
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
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.grey,
        ),
      ],
    ).show();
  }

  Future<void> _showAlertRefund(BuildContext context, String id) async {
    TextEditingController retrydate = TextEditingController();
    TextEditingController amount = TextEditingController();
    TextEditingController memo = TextEditingController();
    List<PaymentRefund> refunds =
        await PaymentCronjobRepository().fetchPaymentRefunds(id);
    PaymentRefund? refund = refunds.isNotEmpty ? refunds.first : null;

    if (refund != null) {
      retrydate.text = refund.entry!.first.date!;
      amount.text = refund.totalAmount!.toString() ?? "0.0";
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
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.grey,
        ),
      ],
    ).show();
  }

  void _showAlertvoid(BuildContext context, String id) {
    print("calling");
    TextEditingController reason = TextEditingController();
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure you want to void this payment?",
      desc: "A void can be issued on this payment until it is settled",
      content: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 45,
            child: TextField(
              controller: reason,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter reason for void',
                contentPadding: EdgeInsets.only(top: 8, left: 15),
              ),
            ),
          ),
          // if (_errorText)
          //   Text(
          //     "Please fill in all fields correctly.",
          //     style: TextStyle(color: Colors.redAccent),
          //   ),
        ],
      ),
      style: AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            if (reason.text.isEmpty) {
              // setState(() {
              //  _errorText == true;
              // });
              Fluttertoast.showToast(msg: "Please enter a reason for deletion");
            } else {
              Navigator.pop(context);
              var data = await PaymentCronjobRepository().VoidCron(
                  pay_id: id, void_reason: reason.text, context: context);
              // Add your delete logic here
              if (data != null)
                setState(() {
                  futurecronjobpayment = cronjob_payment_tableService()
                      .fetchCronjob_payment(limit: itemsPerPage);
                });
            }
          },
          color: blueColor,
        ),
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.grey,
        ),
      ],
    ).show();
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
              padding: const EdgeInsets.all(10.0),
              child: FutureBuilder<LeaseResponse>(
                future: futurecronjobpayment,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ColabShimmerLoadingWidget();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData ||
                      snapshot.data!.data!.isEmpty) {
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
                    var data = snapshot.data!.data!;
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
                        (snapshot.data!.metadata!.total! / itemsPerPage).ceil();

                    // final currentPageData = data
                    //     .skip(currentPage * itemsPerPage)
                    //     .take(itemsPerPage)
                    //     .toList();
                    final currentPageData = data;
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          _buildHeaders(data),
                          SizedBox(height: 1),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromRGBO(152, 162, 179, .5))),
                            // decoration: BoxDecoration(
                            //     border: Border.all(color: blueColor)),
                            child: Column(
                              children:
                                  currentPageData.asMap().entries.map((entry) {
                                int index = entry.key;
                                bool isExpanded = expandedIndex == index;
                                LeaseDatacronjob Propertytype = entry.value;

                                //return CustomExpansionTile(data: Propertytype, index: index);
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    // color: index % 2 != 0
                                    //     ? Colors.white
                                    //     : blueColor.withOpacity(0.09),
                                    border: Border.all(
                                        color:
                                            Color.fromRGBO(152, 162, 179, .5)),
                                  ),
                                  // decoration: BoxDecoration(
                                  //   border: Border.all(color: blueColor),
                                  // ),
                                  child: Column(
                                    children: <Widget>[
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              InkWell(
                                                onTap: () {
                                                  // setState(() {
                                                  //    isExpanded = !isExpanded;
                                                  // //  expandedIndex = !expandedIndex;
                                                  //
                                                  // });
                                                  // setState(() {
                                                  //   if (isExpanded) {
                                                  //     expandedIndex = null;
                                                  //     isExpanded = !isExpanded;
                                                  //   } else {
                                                  //     expandedIndex = index;
                                                  //   }
                                                  // });
                                                  setState(() {
                                                    if (expandedIndex ==
                                                        index) {
                                                      expandedIndex = null;
                                                    } else {
                                                      expandedIndex = index;
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                      left: 5, right: 5),
                                                  padding: !isExpanded
                                                      ? EdgeInsets.only(
                                                          bottom: 10)
                                                      : EdgeInsets.only(
                                                          top: 10),
                                                  child: FaIcon(
                                                    isExpanded
                                                        ? FontAwesomeIcons
                                                            .sortUp
                                                        : FontAwesomeIcons
                                                            .sortDown,
                                                    size: 15,
                                                    color: blueColor,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .02),
                                              Expanded(
                                                flex: 3,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      if (expandedIndex ==
                                                          index) {
                                                        expandedIndex = null;
                                                      } else {
                                                        expandedIndex = index;
                                                      }
                                                    });
                                                  },
                                                  child: Text(
                                                    '${Propertytype.rentalAddress}',
                                                    style: TextStyle(
                                                      color: blueColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .08),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  ' ${Propertytype.tenant?.tenantName}',
                                                  style: TextStyle(
                                                    color: blueColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .08),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  '${Propertytype.response}',
                                                  style: TextStyle(
                                                    color:
                                                        Propertytype.response ==
                                                                "FAILURE"
                                                            ? Colors.red
                                                            : Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .06),
                                              // SizedBox(
                                              //     width: MediaQuery.of(context)
                                              //         .size
                                              //         .width *
                                              //         .01),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (isExpanded)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 2.0),
                                          margin: EdgeInsets.only(bottom: 2),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    FaIcon(
                                                      isExpanded
                                                          ? FontAwesomeIcons
                                                              .sortUp
                                                          : FontAwesomeIcons
                                                              .sortDown,
                                                      size: 45,
                                                      color: Colors.transparent,
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text.rich(
                                                                TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                          'Date : ',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              blueColor), // Bold and black
                                                                    ),
                                                                    TextSpan(
                                                                      // text: formatDate(
                                                                      //     '${Propertytype.updatedAt}'),
                                                                      text: Propertytype.date?.isNotEmpty ==
                                                                              true
                                                                          ? dateProvider
                                                                              .formatCurrentDate('${Propertytype.date}')
                                                                          : 'N/A',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          color:
                                                                              grey), // Light and grey
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Spacer(),
                                                              Text.rich(
                                                                TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                          'Amount : ',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              blueColor), // Bold and black
                                                                    ),
                                                                    TextSpan(
                                                                      text:
                                                                          '\$${Propertytype.totalAmount}',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          color:
                                                                              grey), // Light and grey
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      .04),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text.rich(
                                                            TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      'Type : ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          blueColor), // Bold and black
                                                                ),
                                                                TextSpan(
                                                                  // text: formatDate(
                                                                  //     '${Propertytype.updatedAt}'),
                                                                  text: Propertytype
                                                                              .paymenttype
                                                                              ?.isNotEmpty ==
                                                                          true
                                                                      ? '${Propertytype.paymenttype}'
                                                                      : 'N/A',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color:
                                                                          grey), // Light and grey
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text.rich(
                                                            TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      'Description : ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          blueColor), // Bold and black
                                                                ),
                                                                TextSpan(
                                                                  // text: formatDate(
                                                                  //     '${Propertytype.updatedAt}'),
                                                                  text: Propertytype
                                                                              .responseText
                                                                              ?.isNotEmpty ==
                                                                          true
                                                                      ? ' ${Propertytype.responseText}'
                                                                      : 'N/A',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color:
                                                                          grey), // Light and grey
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .03),
                                                  ],
                                                ),
                                                SizedBox(height: 15),
                                                if (Propertytype.response ==
                                                    "FAILURE")
                                                  Row(
                                                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            _showAlertAcknowledgement(
                                                                context,
                                                                Propertytype
                                                                    .id!,
                                                                failureacknowledged);
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                        .grey[
                                                                    350]), // color:Colors.grey[100],
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                FaIcon(
                                                                  FontAwesomeIcons
                                                                      .check,
                                                                  size: 15,
                                                                  color:
                                                                      blueColor,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            _showAlertRetry(
                                                                context,
                                                                Propertytype
                                                                    .id!);
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                            .grey[
                                                                        350]),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                FaIcon(
                                                                  FontAwesomeIcons
                                                                      .rotateRight,
                                                                  size: 15,
                                                                  color:
                                                                      blueColor,
                                                                ),
                                                                // SizedBox(
                                                                //   width: 10,
                                                                // ),
                                                                // Text(
                                                                //   "Delete",
                                                                //   style: TextStyle(
                                                                //       color:
                                                                //       blueColor,
                                                                //       fontWeight:
                                                                //       FontWeight
                                                                //           .bold),
                                                                // ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            _showAlertSchedule(
                                                                context,
                                                                Propertytype
                                                                    .id!);
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                            .grey[
                                                                        350]),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                FaIcon(
                                                                  FontAwesomeIcons
                                                                      .solidCalendarAlt,
                                                                  size: 15,
                                                                  color:
                                                                      blueColor,
                                                                ),
                                                                // SizedBox(
                                                                //   width: 10,
                                                                // ),
                                                                // Text(
                                                                //   "Delete",
                                                                //   style: TextStyle(
                                                                //       color:
                                                                //       blueColor,
                                                                //       fontWeight:
                                                                //       FontWeight
                                                                //           .bold),
                                                                // ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                if (Propertytype.response ==
                                                        "SUCCESS" &&
                                                    Propertytype.state ==
                                                        "settled")
                                                  Row(
                                                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            _showAlertRefund(
                                                                context,
                                                                Propertytype
                                                                    .id!);
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                        .grey[
                                                                    350]), // color:Colors.grey[100],
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                FaIcon(
                                                                  FontAwesomeIcons
                                                                      .reply,
                                                                  size: 15,
                                                                  color:
                                                                      blueColor,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                if (Propertytype.response ==
                                                        "SUCCESS" &&
                                                    Propertytype.state ==
                                                        "settling")
                                                  Row(
                                                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            print("call");
                                                            _showAlertvoid(
                                                                context,
                                                                Propertytype
                                                                    .id!);
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                        .grey[
                                                                    350]), // color:Colors.grey[100],
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                FaIcon(
                                                                  FontAwesomeIcons
                                                                      .dollarSign,
                                                                  size: 15,
                                                                  color:
                                                                      blueColor,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: 20),
                          // if (data.length > 5)
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
                                        border: Border.all(color: Colors.grey),
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
                                          onChanged: snapshot
                                                      .data!.metadata!.total! >
                                                  itemsPerPageOptions
                                                      .first // Condition to check if dropdown should be enabled
                                              ? (newValue) {
                                                  setState(() {
                                                    itemsPerPage = newValue!;
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
          //                                   // TableCell(child: Text('yash')),
          //                                   // TableCell(child: Text('yash')),
          //                                   // TableCell(child: Text('yash')),
          //                                   // TableCell(child: Text('yash')),
          //                                   // TableCell(child: Text('yash')),
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
