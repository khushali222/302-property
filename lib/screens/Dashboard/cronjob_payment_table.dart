import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../Model/Dashbord_table/Payment_refund_model.dart';
import '../../Model/Dashbord_table/cronjob_payment_table.dart';
import '../../Model/tenants.dart' as tenant_model;

import '../../constant/constant.dart';

import '../../provider/dateProvider.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';
import '../../repository/Payment_cronjob/Payment_cronjob_repo.dart';
import '../../repository/dashboard_table_repo/cronjob_payment_table.dart';
import '../../repository/tenants.dart';
import '../../widgets/CustomTableShimmer.dart';
import '../../widgets/titleBar.dart';
import '../Leasing/RentalRoll/SummeryPageLease.dart';
import '../Rental/Tenants/Tenant_summary.dart';

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
  int failedCurrentPage = 1;
  int failedItemsPerPage = 5;
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
  int? expandedFailedIndex; // For failed payments expansion
  Set<int> expandedIndices = {};
  late bool isExpanded;
  // Checkbox selection for failed payments
  Set<String> selectedFailedPayments = {}; // Store payment IDs
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: blueColor, // Background color
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(13),
              topRight: Radius.circular(13),
            ),
          ),
          child: const Center(
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
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(0),
                right: Radius.circular(0),
              ),
              border:
                  Border.all(color: const Color.fromRGBO(152, 162, 179, .5)),
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
                    child: const Icon(
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
                              ? const Text("  Rental\n Address",
                                  style: TextStyle(
                                    color: Color.fromRGBO(50, 75, 119, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ))
                              : const Text("  Rental\n Address",
                                  style: TextStyle(
                                    color: Color.fromRGBO(50, 75, 119, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  )),
                          // Text("Property", style: TextStyle(color: Colors.white)),
                          const SizedBox(width: 3),
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
                      child: const Row(
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
                      child: const Row(
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade300, // Background color
              borderRadius: const BorderRadius.only(
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
      title: null,
      desc: null,
      style: const AlertStyle(
        backgroundColor: Colors.white,
      ),
      content: const Column(
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
          child: const Text(
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
      style: const AlertStyle(
        backgroundColor: Colors.white,
      ),
      content: const Column(
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
          child: const Text(
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
          child: const Text(
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
          const SizedBox(height: 15),
          const Text(
            "Reschedule Payment",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Please select a payment date to retry. The date must be tomorrow or later:",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: CustomTextField(
              onTap: () async {
                DateTime now = DateTime.now();
                DateTime tomorrow = now.add(const Duration(days: 1));
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
                onPressed: () async {
                  DateTime now = DateTime.now();
                  DateTime tomorrow = now.add(const Duration(days: 1));
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
      style: const AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
        DialogButton(
          child: const Text(
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

  TextStyle cardTextStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  TextStyle subTextStyle = const TextStyle(
    fontSize: 14,
  );
  Widget paymentCard(
    String name,
    String address,
    String amount,
    bool isExpanded,
    VoidCallback onExpandTap,
    LeaseDatacronjob data,
  ) {
    return _buildPaymentCard(
        name, address, amount, isExpanded, onExpandTap, data, null, null);
  }

  Widget failedPaymentCard(
    String name,
    String address,
    String amount,
    bool isExpanded,
    VoidCallback onExpandTap,
    LeaseDatacronjob data,
    bool? isSelected,
    VoidCallback? onCheckboxTap,
  ) {
    return _buildPaymentCard(name, address, amount, isExpanded, onExpandTap,
        data, isSelected, onCheckboxTap,
        isFailedSection: true);
  }

  Widget _buildPaymentCard(
    String name,
    String address,
    String amount,
    bool isExpanded,
    VoidCallback onExpandTap,
    LeaseDatacronjob data,
    bool? isSelected,
    VoidCallback? onCheckboxTap, {
    bool isFailedSection = false,
  }) {
    final dateProvider = Provider.of<DateProvider>(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          const BoxShadow(
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
              // Checkbox for failed payments or expand icon for successful payments
              if (isSelected != null && onCheckboxTap != null)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      onCheckboxTap();
                    },
                    activeColor: blueColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                )
              else
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
              // Expand icon for failed payments (if checkbox is present)
              if (isSelected != null && onCheckboxTap != null)
                GestureDetector(
                  onTap: onExpandTap,
                  child: Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(left: 8),
                    child: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: blueColor,
                    ),
                  ),
                ),
              const SizedBox(width: 5),
              GestureDetector(
                  onTap: () async {
                    // Fetch tenant data first using the tenantId
                    if (data.tenant?.tenantId != null) {
                      List<tenant_model.Tenant> tenantData =
                          await TenantsRepository()
                                  .fetchTenantsummery(data.tenant!.tenantId!) ??
                              [];
                      if (tenantData.isNotEmpty) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ResponsiveTenantSummary(
                                    tenants: tenantData
                                        .first, // Pass the fetched tenant data here
                                    tenantId: data.tenant!.tenantId!)));
                      }
                    }
                  },
                  child: Text(name, style: cardTextStyle)),
              const Spacer(),
              Text('\$$amount', style: cardTextStyle)
            ],
          ),
          if (isExpanded)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                const Divider(
                    thickness: 1, height: 1, color: Color(0xFFEAECEF)),
                // Date
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: subTextStyle.copyWith(
                            color: greyColor, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          dateProvider
                              .formatCurrentDate('${data.date ?? "-"}'),
                          textAlign: TextAlign.right,
                          style: subTextStyle.copyWith(
                              color: blueColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                    thickness: 1, height: 1, color: Color(0xFFEAECEF)),
                // Response
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Response',
                        style: subTextStyle.copyWith(
                            color: greyColor, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          data.response ?? "-",
                          textAlign: TextAlign.right,
                          style: subTextStyle.copyWith(
                            // Match web: green for SUCCESS/Approved (or ACH
                            // settling/settled), red for FAILURE, else navy.
                            color: (data.response == "SUCCESS" ||
                                    data.response == "Approved" ||
                                    (data.paymenttype == "ACH" &&
                                        (data.state == "settling" ||
                                            data.state == "settled")))
                                ? const Color(0xFF12B76A)
                                : (data.response == "FAILURE")
                                    ? const Color(0xFFD92D20)
                                    : blueColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                    thickness: 1, height: 1, color: Color(0xFFEAECEF)),
                // Type
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type',
                        style: subTextStyle.copyWith(
                            color: greyColor, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          data.paymenttype ?? "-",
                          textAlign: TextAlign.right,
                          style: subTextStyle.copyWith(
                              color: blueColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                    thickness: 1, height: 1, color: Color(0xFFEAECEF)),
                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: subTextStyle.copyWith(
                            color: greyColor, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data.responseText?.isNotEmpty == true
                            ? data.responseText!
                            : 'N/A',
                        style: subTextStyle.copyWith(
                            color: blueColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Divider(
                    thickness: 1, height: 1, color: Color(0xFFEAECEF)),
                // Rental Address
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rental Address',
                        style: subTextStyle.copyWith(
                            color: greyColor, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
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
                            color: blueColor,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                    thickness: 1, height: 1, color: Color(0xFFEAECEF)),
                // Action
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        'Action',
                        style: subTextStyle.copyWith(
                            color: greyColor, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      // Failed Payments section (web FailedPaymentsTable.jsx):
                      // only Ignore + Reprocess. "Payments Last 7 Days" keeps
                      // its own buttons (isFailedSection stays false there).
                      if (isFailedSection) ...[
                        GestureDetector(
                          onTap: () {
                            if (data.id != null) {
                              _showAlertAcknowledgement(
                                  context, data.id!, failureacknowledged);
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF1F4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 40,
                            width: 44,
                            child: Icon(Icons.close, color: blueColor),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            if (data.id != null) {
                              _showAlertRetry(context, data.id!);
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF1F4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 40,
                            width: 44,
                            child: Icon(Icons.recycling_outlined,
                                color: blueColor),
                          ),
                        ),
                      ] else ...[
                        if (data.response == "FAILURE")
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (data.id != null) {
                                    _showAlertAcknowledgement(context,
                                        data.id!, failureacknowledged);
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE7F6EC),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  height: 40,
                                  width: 44,
                                  child: const Icon(Icons.check,
                                      color: Color(0xFF12B76A)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  if (data.id != null) {
                                    _showAlertRetry(context, data.id!);
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF1F4),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  height: 40,
                                  width: 44,
                                  child: Icon(Icons.recycling_outlined,
                                      color: blueColor),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  if (data.id != null) {
                                    _showAlertSchedule(context, data.id!);
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF1F4),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  height: 40,
                                  width: 44,
                                  child: Icon(Icons.calendar_month_outlined,
                                      color: blueColor),
                                ),
                              ),
                            ],
                          ),
                        if (data.response == "SUCCESS" &&
                            data.state == "settled")
                          GestureDetector(
                            onTap: () {
                              if (data.id != null) {
                                _showAlertRefund(context, data.id!);
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF1F4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 40,
                              width: 44,
                              child: FaIcon(
                                FontAwesomeIcons.reply,
                                size: 15,
                                color: blueColor,
                              ),
                            ),
                          ),
                        if (data.response == "SUCCESS" &&
                            data.state == "settling")
                          GestureDetector(
                            onTap: () {
                              if (data.id != null) {
                                _showAlertvoid(context, data.id!);
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF1F4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 40,
                              width: 44,
                              child: Icon(
                                Icons.money_off,
                                size: 20,
                                weight: 30,
                                color: blueColor,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

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
                      const BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0),
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: const Text(
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
          const SizedBox(
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
          const SizedBox(
            height: 4,
          ),
          SizedBox(
            height: 60,
            child: CustomTextField(
              onTap: () async {
                DateTime now = DateTime.now();
                DateTime tomorrow = now.add(const Duration(days: 1));
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
          const SizedBox(
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
          const SizedBox(
            height: 4,
          ),
          SizedBox(
            height: 45,
            child: TextField(
              controller: amount,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter reason for void',
                contentPadding: EdgeInsets.only(top: 8, left: 15),
              ),
            ),
          ),
          const SizedBox(
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
          const SizedBox(
            height: 4,
          ),
          SizedBox(
            height: 45,
            child: TextField(
              controller: memo,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "if left blank , will show'Payment'",
                contentPadding: EdgeInsets.only(top: 8, left: 15),
              ),
            ),
          ),
        ],
      ),
      style: const AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
        DialogButton(
          child: const Text(
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
                style: const AlertStyle(
                  backgroundColor: Colors.white,
                ),
                buttons: [
                  DialogButton(
                    child: const Text(
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

  // void _showAlertvoid(BuildContext context, String id) {
  //   print("calling");
  //   TextEditingController reason = TextEditingController();
  //   Alert(
  //     context: context,
  //     type: AlertType.warning,
  //     title: "Are you sure you want to void this payment?",
  //     desc: "A void can be issued on this payment until it is settled",
  //     content: Column(
  //       children: <Widget>[
  //         SizedBox(
  //           height: 10,
  //         ),
  //         SizedBox(
  //           height: 45,
  //           child: TextField(
  //             controller: reason,
  //             decoration: InputDecoration(
  //               border: OutlineInputBorder(),
  //               hintText: 'Enter reason for void',
  //               contentPadding: EdgeInsets.only(top: 8, left: 15),
  //             ),
  //           ),
  //         ),
  //         // if (_errorText)
  //         //   Text(
  //         //     "Please fill in all fields correctly.",
  //         //     style: TextStyle(color: Colors.redAccent),
  //         //   ),
  //       ],
  //     ),
  //     style: AlertStyle(
  //       backgroundColor: Colors.white,
  //     ),
  //     buttons: [
  //       DialogButton(
  //         child: Text(
  //           "Void",
  //           style: TextStyle(color: Colors.white, fontSize: 18),
  //         ),
  //         onPressed: () async {
  //           if (reason.text.isEmpty) {
  //             // setState(() {
  //             //  _errorText == true;
  //             // });
  //             Fluttertoast.showToast(msg: "Please enter a reason for deletion");
  //           } else {
  //             Navigator.pop(context);
  //             var data = await PaymentCronjobRepository().VoidCron(
  //                 pay_id: id, void_reason: reason.text, context: context);
  //             // Add your delete logic here
  //             if (data != null)
  //               setState(() {
  //                 futurecronjobpayment = cronjob_payment_tableService()
  //                     .fetchCronjob_payment(limit: itemsPerPage);
  //               });
  //           }
  //         },
  //         color: blueColor,
  //       ),
  //       DialogButton(
  //         child: Text(
  //           "Cancel",
  //           style: TextStyle(color: Colors.white, fontSize: 18),
  //         ),
  //         onPressed: () {
  //           Alert(
  //             type: AlertType.warning,
  //             title: "Void Cancelled",
  //             context: context,
  //             buttons: [
  //               DialogButton(
  //                 child: Text(
  //                   "Ok",
  //                   style: TextStyle(color: Colors.white, fontSize: 18),
  //                 ),
  //                 onPressed: () {
  //                   Navigator.pop(context); // Close dialog
  //                   Navigator.pop(context);
  //                 },
  //                 color: blueColor,
  //               ),
  //             ],
  //           ).show();
  //         },
  //         color: Colors.grey,
  //       ),
  //     ],
  //   ).show();
  // }
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
                  const SizedBox(height: 12),
                  const Text(
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
                            backgroundColor: isReasonEntered
                                ? blueColor
                                : Colors.grey.shade300,
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
                                  child: const Text(
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

  void _handleBulkIgnore() async {
    if (selectedFailedPayments.isEmpty) return;

    final selectedCount = selectedFailedPayments.length;
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Ignore Selected Payments",
      desc:
          "Are you sure you want to acknowledge $selectedCount failed payment(s) as ignored?",
      style: const AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
        DialogButton(
          child: const Text(
            "Confirm",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            Navigator.pop(context);
            final selectedIds = List<String>.from(selectedFailedPayments);

            try {
              final response = await PaymentCronjobRepository().bulkAcknowledge(
                context: context,
                paymentIds: selectedIds,
              );

              if (response != null && response['statusCode'] == 200) {
                final results = response['results'] ?? {};
                final successful =
                    (results['successful'] as List?)?.length ?? 0;
                final failed = (results['failed'] as List?)?.length ?? 0;
                final message = response['message'] ?? '';

                setState(() {
                  selectedFailedPayments.clear();
                  futurecronjobpayment = cronjob_payment_tableService()
                      .fetchCronjob_payment(limit: itemsPerPage);
                });

                // Show success/error dialog
                _showBulkResultDialog(
                  title: "Success",
                  message: message,
                  successful: successful,
                  failed: failed,
                );
              } else {
                _showBulkResultDialog(
                  title: "Error",
                  message:
                      response?['message'] ?? 'Failed to acknowledge payments',
                  successful: 0,
                  failed: selectedIds.length,
                );
              }
            } catch (e) {
              _showBulkResultDialog(
                title: "Error",
                message: 'An error occurred: ${e.toString()}',
                successful: 0,
                failed: selectedIds.length,
              );
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
          radius: BorderRadius.circular(8),
          border: Border.all(color: blueColor, width: 1.5),
        ),
      ],
    ).show();
  }

  void _handleBulkReprocess() async {
    if (selectedFailedPayments.isEmpty) return;

    final selectedCount = selectedFailedPayments.length;
    final isMobile = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.all(isMobile ? 16 : 24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              Container(
                width: isMobile ? 56 : 64,
                height: isMobile ? 56 : 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange, width: 2),
                  color: Colors.orange.shade50,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: isMobile ? 32 : 36,
                ),
              ),
              SizedBox(height: isMobile ? 16 : 20),
              // Title
              Text(
                "Reprocess $selectedCount Failed Payment${selectedCount > 1 ? 's' : ''}?",
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF101828),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 10 : 12),
              // Subtitle
              Text(
                "Choose how to reprocess these payments:",
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 20 : 24),
              // Buttons - Side by side, compact
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 10 : 10,
                          horizontal: isMobile ? 8 : 12,
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: isMobile ? 13 : 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Schedule Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleBulkSchedule();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blueColor,
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 10 : 10,
                          horizontal: isMobile ? 8 : 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Schedule",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 13 : 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Process Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleBulkProcessNow();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blueColor,
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 10 : 10,
                          horizontal: isMobile ? 8 : 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Process",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 13 : 13,
                          fontWeight: FontWeight.w600,
                        ),
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
  }

  void _handleBulkProcessNow() async {
    if (selectedFailedPayments.isEmpty) return;

    final selectedIds = List<String>.from(selectedFailedPayments);

    try {
      final response = await PaymentCronjobRepository().bulkRetry(
        context: context,
        paymentIds: selectedIds,
      );

      if (response != null && response['statusCode'] == 200) {
        final results = response['results'] ?? {};
        final successful = (results['successful'] as List?)?.length ?? 0;
        final failed = (results['failed'] as List?)?.length ?? 0;
        final message = response['message'] ?? '';

        setState(() {
          selectedFailedPayments.clear();
          futurecronjobpayment = cronjob_payment_tableService()
              .fetchCronjob_payment(limit: itemsPerPage);
        });

        // Show success/error dialog
        _showBulkResultDialog(
          title: "Success",
          message: message,
          successful: successful,
          failed: failed,
        );
      } else {
        _showBulkResultDialog(
          title: "Error",
          message: response?['message'] ?? 'Failed to process payments',
          successful: 0,
          failed: selectedIds.length,
        );
      }
    } catch (e) {
      _showBulkResultDialog(
        title: "Error",
        message: 'An error occurred: ${e.toString()}',
        successful: 0,
        failed: selectedIds.length,
      );
    }
  }

  void _handleBulkSchedule() async {
    if (selectedFailedPayments.isEmpty) return;

    final selectedCount = selectedFailedPayments.length;
    final dateController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isMobile = MediaQuery.of(context).size.width < 600;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: EdgeInsets.all(isMobile ? 16 : 24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Warning Icon
                  Container(
                    width: isMobile ? 56 : 64,
                    height: isMobile ? 56 : 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange, width: 2),
                      color: Colors.orange.shade50,
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: isMobile ? 32 : 36,
                    ),
                  ),
                  SizedBox(height: isMobile ? 16 : 20),
                  // Title
                  Text(
                    "Schedule $selectedCount Failed Payment${selectedCount > 1 ? 's' : ''}?",
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF101828),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isMobile ? 10 : 12),
                  // Subtitle
                  Text(
                    "Select a date to reschedule these payments:",
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isMobile ? 20 : 24),
                  // Date Text Field
                  Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      height: isMobile ? 50 : 55,
                      padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12.0 : 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: dateController,
                        readOnly: true,
                        style: TextStyle(fontSize: isMobile ? 14 : 15),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
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
                          if (picked != null) {
                            setDialogState(() {
                              selectedDate = picked;
                              dateController.text =
                                  "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                            });
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Select Date",
                          hintStyle: TextStyle(
                            fontSize: isMobile ? 13 : 14,
                            color: Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.calendar_today,
                              color: blueColor,
                              size: isMobile ? 18 : 20,
                            ),
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
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
                              if (picked != null) {
                                setDialogState(() {
                                  selectedDate = picked;
                                  dateController.text =
                                      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 20 : 24),
                  // Buttons - Side by side, compact
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Cancel Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: isMobile ? 10 : 10,
                              horizontal: isMobile ? 8 : 12,
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: isMobile ? 13 : 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Schedule Button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: selectedDate == null
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  _processBulkSchedule(selectedDate!);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedDate == null
                                ? Colors.grey.shade300
                                : blueColor,
                            disabledBackgroundColor: Colors.grey.shade300,
                            padding: EdgeInsets.symmetric(
                              vertical: isMobile ? 10 : 10,
                              horizontal: isMobile ? 8 : 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Schedule",
                            style: TextStyle(
                              color: selectedDate == null
                                  ? Colors.grey.shade600
                                  : Colors.white,
                              fontSize: isMobile ? 13 : 13,
                              fontWeight: FontWeight.w600,
                            ),
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

  void _processBulkSchedule(DateTime selectedDate) async {
    final retryDate =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
    final selectedIds = List<String>.from(selectedFailedPayments);

    try {
      final response = await PaymentCronjobRepository().bulkReschedule(
        context: context,
        paymentIds: selectedIds,
        retryDate: retryDate,
      );

      if (response != null && response['statusCode'] == 200) {
        final results = response['results'] ?? {};
        final successful = (results['successful'] as List?)?.length ?? 0;
        final failed = (results['failed'] as List?)?.length ?? 0;
        final message = response['message'] ?? '';

        setState(() {
          selectedFailedPayments.clear();
          futurecronjobpayment = cronjob_payment_tableService()
              .fetchCronjob_payment(limit: itemsPerPage);
        });

        // Show success dialog
        _showBulkResultDialog(
          title: "Success",
          message: message,
          successful: successful,
          failed: failed,
        );
      } else {
        _showBulkResultDialog(
          title: "Error",
          message: response?['message'] ?? 'Failed to schedule payments',
          successful: 0,
          failed: selectedIds.length,
        );
      }
    } catch (e) {
      _showBulkResultDialog(
        title: "Error",
        message: 'An error occurred: ${e.toString()}',
        successful: 0,
        failed: selectedIds.length,
      );
    }
  }

  void _showBulkResultDialog({
    required String title,
    required String message,
    required int successful,
    required int failed,
  }) {
    final isSuccess = successful > 0 && failed == 0;

    Alert(
      context: context,
      type: isSuccess ? AlertType.success : AlertType.info,
      title: title,
      desc: message,
      style: const AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
        DialogButton(
          child: const Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: blueColor,
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
          // if (MediaQuery.of(context).size.width < 500)
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: FutureBuilder<LeaseResponse>(
              future: futurecronjobpayment,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ColabShimmerLoadingWidget();
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData ||
                    ((snapshot.data?.data?.isEmpty ?? true) &&
                        (snapshot.data?.failedPayments?.isEmpty ?? true))) {
                  return Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              "Payments Last 7 Days",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: blueColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: const Color(0xFFDBE0E5))),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/icons/Nodata.png',
                                  height: 20,
                                  width: 20,
                                  color: const Color(0xFF101828),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Center(
                                  child: Text(
                                    "No data available",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF101828),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Image.asset(
                          //   "assets/images/no_data.jpg", // Make sure this image exists in your assets
                          //   height: 200,
                          //   width: 200,
                          // ),
                          // SizedBox(height: 10),
                          // Text(
                          //   "No data available",
                          //   style: TextStyle(
                          //     fontWeight: FontWeight.bold,
                          //     color: blueColor,
                          //     fontSize: 16,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  );
                } else {
                  var data = snapshot.data?.data ?? [];
                  var failedData = snapshot.data?.failedPayments ?? [];
                  print("data ${data.length}");
                  print("failedData ${failedData.length}");

                  final totalPages =
                      ((snapshot.data?.metadata?.total ?? 0) / itemsPerPage)
                          .ceil();
                  final currentPageData = data;

                  // Pagination for failed payments
                  final failedTotalPages = failedData.isEmpty
                      ? 1
                      : ((failedData.length / failedItemsPerPage).ceil());
                  final failedStartIndex =
                      (failedCurrentPage - 1) * failedItemsPerPage;
                  final failedEndIndex =
                      (failedStartIndex + failedItemsPerPage) >
                              failedData.length
                          ? failedData.length
                          : (failedStartIndex + failedItemsPerPage);
                  final failedPageData = failedData.isEmpty
                      ? []
                      : failedData.sublist(failedStartIndex, failedEndIndex);

                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Successful Payments Section
                        const SizedBox(height: 10),
                        Text(
                          "Payments Last 7 Days",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: blueColor),
                        ),
                        const SizedBox(height: 10),
                        if (currentPageData.isEmpty)
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: const Color(0xFFDBE0E5))),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/icons/Nodata.png',
                                  height: 20,
                                  width: 20,
                                  color: const Color(0xFF101828),
                                ),
                                const SizedBox(width: 10),
                                const Center(
                                  child: Text(
                                    "No data available",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF101828),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children:
                                currentPageData.asMap().entries.map((entry) {
                              int index = entry.key;
                              bool isExpanded = expandedIndex == index;
                              LeaseDatacronjob Propertytype = entry.value;

                              return Container(
                                  child: paymentCard(
                                      Propertytype.tenant?.tenantName ??
                                          "External Source",
                                      Propertytype.rentalAddress ??
                                          "Unknown Address",
                                      Propertytype.totalAmount
                                              ?.toStringAsFixed(2) ??
                                          "0.00",
                                      isExpanded, () {
                                setState(() {
                                  expandedIndex = isExpanded ? null : index;
                                });
                              }, Propertytype));
                            }).toList(),
                          ),
                        if (data.length > 5) const SizedBox(height: 20),
                        if (data.length > 5)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 10),
                                  Material(
                                    elevation: 3,
                                    child: Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
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
                                          onChanged: (snapshot.data?.metadata
                                                          ?.total ??
                                                      0) >
                                                  itemsPerPageOptions.first
                                              ? (newValue) {
                                                  setState(() {
                                                    itemsPerPage = newValue ??
                                                        itemsPerPage;
                                                    currentPage = 1;
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

                        // Failed Payments Section
                        const SizedBox(height: 30),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isMobile = constraints.maxWidth < 600;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with Select All - No container
                                Row(
                                  children: [
                                    // Only show checkbox if more than 1 payment
                                    if (failedPageData.length > 1)
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: Checkbox(
                                          value: failedPageData.isNotEmpty &&
                                              selectedFailedPayments.length ==
                                                  failedPageData.length,
                                          onChanged: failedPageData.isEmpty
                                              ? null
                                              : (bool? value) {
                                                  setState(() {
                                                    if (value == true) {
                                                      selectedFailedPayments =
                                                          failedPageData
                                                              .where((p) =>
                                                                  p.id != null)
                                                              .map((p) => p.id!)
                                                              .toSet()
                                                              .cast<String>();
                                                    } else {
                                                      selectedFailedPayments
                                                          .clear();
                                                    }
                                                  });
                                                },
                                          activeColor: blueColor,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    if (failedPageData.length > 1)
                                      const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Failed Payments Last 7 Days",
                                        style: TextStyle(
                                            fontSize: isMobile ? 15 : 16,
                                            fontWeight: FontWeight.bold,
                                            color: blueColor),
                                      ),
                                    ),
                                  ],
                                ),
                                // Selection controls below title
                                if (selectedFailedPayments.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: isMobile ? 6 : 8,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: isMobile ? 10 : 12,
                                            vertical: isMobile ? 6 : 7),
                                        decoration: BoxDecoration(
                                          color: blueColor,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              "${selectedFailedPayments.length} selected",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isMobile ? 13 : 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedFailedPayments.clear();
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(6),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: isMobile ? 10 : 12,
                                              vertical: isMobile ? 6 : 7),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                                color: Colors.grey.shade300,
                                                width: 1),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.close,
                                                color: Colors.grey.shade700,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                "CLEAR",
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontSize: isMobile ? 12 : 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        offset: const Offset(0,
                                            15), // Open downward with more space to show under button
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: isMobile ? 10 : 12,
                                              vertical: isMobile ? 6 : 7),
                                          decoration: BoxDecoration(
                                            color: blueColor,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.more_vert,
                                                color: Colors.white,
                                                size: isMobile ? 16 : 18,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                "Bulk Actions",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: isMobile ? 13 : 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.arrow_drop_down,
                                                color: Colors.white,
                                                size: isMobile ? 18 : 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                        itemBuilder: (BuildContext context) => [
                                          PopupMenuItem<String>(
                                            value: 'ignore',
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.red,
                                                    size: 18,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                const Text(
                                                  'Ignore Selected',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'reprocess',
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: blueColor
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Icon(
                                                    Icons.recycling_outlined,
                                                    color: blueColor,
                                                    size: 18,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                const Text(
                                                  'Reprocess Selected',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        onSelected: (String value) {
                                          if (value == 'ignore') {
                                            _handleBulkIgnore();
                                          } else if (value == 'reprocess') {
                                            _handleBulkReprocess();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        if (failedPageData.isEmpty)
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: const Color(0xFFDBE0E5))),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/icons/Nodata.png',
                                  height: 20,
                                  width: 20,
                                  color: const Color(0xFF101828),
                                ),
                                const SizedBox(width: 10),
                                const Center(
                                  child: Text(
                                    "No failed payments",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF101828),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children:
                                failedPageData.asMap().entries.map((entry) {
                              int index = entry.key;
                              bool isExpanded = expandedFailedIndex == index;
                              LeaseDatacronjob Propertytype = entry.value;
                              // Only show checkbox if more than 1 payment
                              bool isSelected = failedPageData.length > 1 &&
                                  Propertytype.id != null &&
                                  selectedFailedPayments
                                      .contains(Propertytype.id);

                              return failedPaymentCard(
                                  Propertytype.tenant?.tenantName ??
                                      "External Source",
                                  Propertytype.rentalAddress ??
                                      "Unknown Address",
                                  Propertytype.totalAmount
                                          ?.toStringAsFixed(2) ??
                                      "0.00",
                                  isExpanded, () {
                                setState(() {
                                  expandedFailedIndex =
                                      isExpanded ? null : index;
                                });
                              },
                                  Propertytype,
                                  // Only pass checkbox params if more than 1 payment
                                  failedPageData.length > 1 ? isSelected : null,
                                  failedPageData.length > 1
                                      ? () {
                                          setState(() {
                                            if (Propertytype.id != null) {
                                              if (isSelected) {
                                                selectedFailedPayments
                                                    .remove(Propertytype.id!);
                                              } else {
                                                selectedFailedPayments
                                                    .add(Propertytype.id!);
                                              }
                                            }
                                          });
                                        }
                                      : null);
                            }).toList(),
                          ),
                        // Pagination for Failed Payments
                        if (failedData.isNotEmpty &&
                            failedData.length >= 5) ...[
                          const SizedBox(height: 20),
                          // Pagination - Side by side layout
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Left side: Rows per page dropdown
                              Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                                child: Container(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: failedItemsPerPage,
                                      isExpanded: false,
                                      items:
                                          itemsPerPageOptions.map((int value) {
                                        return DropdownMenuItem<int>(
                                          value: value,
                                          child: Text(
                                            value.toString(),
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: failedData.length >= 5
                                          ? (newValue) {
                                              setState(() {
                                                failedItemsPerPage = newValue ??
                                                    failedItemsPerPage;
                                                failedCurrentPage = 1;
                                              });
                                            }
                                          : null,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: blueColor,
                                        size: 24,
                                      ),
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                      dropdownColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Page navigation
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: FaIcon(
                                      FontAwesomeIcons.circleChevronLeft,
                                      color: failedCurrentPage == 1
                                          ? Colors.grey
                                          : blueColor,
                                    ),
                                    onPressed: failedCurrentPage == 1
                                        ? null
                                        : () {
                                            setState(() {
                                              failedCurrentPage--;
                                            });
                                          },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0),
                                    child: Text(
                                      'Page ${failedCurrentPage} of $failedTotalPages',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  IconButton(
                                    icon: FaIcon(
                                      FontAwesomeIcons.circleChevronRight,
                                      color:
                                          failedCurrentPage < failedTotalPages
                                              ? blueColor
                                              : Colors.grey,
                                    ),
                                    onPressed:
                                        failedCurrentPage < failedTotalPages
                                            ? () {
                                                setState(() {
                                                  failedCurrentPage++;
                                                });
                                              }
                                            : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
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
          //                   "No data available",
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
