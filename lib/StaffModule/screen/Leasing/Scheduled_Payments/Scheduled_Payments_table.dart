import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../../Model/Scheduled_Payment_model.dart';
import '../../../../constant/constant.dart';
import '../../../../provider/dateProvider.dart';
import '../../../../repository/Scheduled_Payment_repo.dart';
import '../../../../widgets/CustomTableShimmer.dart';
import '../../../../widgets/titleBar.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_drawer.dart';

import '../RentalRoll/SummeryPageLease.dart';

class Scheduled_Payments_table extends StatefulWidget {
  const Scheduled_Payments_table({super.key});

  @override
  State<Scheduled_Payments_table> createState() => _Scheduled_Payments_tableState();
}

class _Scheduled_Payments_tableState extends State<Scheduled_Payments_table> {
  int totalrecords = 0;
  late Future<List<Scheduled_Payment>> futurescheduledpayment;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  int currentPage = 0;
  int itemsPerPage = 10;
  List<int> itemsPerPageOptions = [
    10,
    25,
    50,
    100,
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
  Widget _buildHeaders() {
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFF4F8FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDBE0E5))),
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
              flex: 4,
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
                        ? Text("Property ",
                        style: TextStyle( color: blueColor, fontWeight: FontWeight.bold))
                        : Text("Property",
                        style: TextStyle( color: blueColor, fontWeight: FontWeight.bold)),
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
              flex: 4,
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
                    Text("    Tenant", style: TextStyle( color: blueColor, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
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
                    Text("Amount", style: TextStyle( color: blueColor, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<String> items = ['Residential', "Commercial", "All"];
  String? selectedValue;
  String searchvalue = "";
  ConnectivityResult? _connectivityResult;
  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        print(result);
        _connectivityResult = result;
      });
    });
    checkInternet();
    futurescheduledpayment = Scheduled_Payment_repo().fetchScheduled_Payment();
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  void _showAlert(BuildContext context, String id, Scheduled_Payment payment) {
    TextEditingController reason = TextEditingController();
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      content: Column(
        children: <Widget>[
          Text(
            "You want to delete this scheduled payment for ${payment.tenant!.tenantName} at ${payment.rentalAddress} in the amount of \$${payment.totalAmount} on ${payment.date}?",
            textAlign: TextAlign.justify,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 45,
            child: TextField(
              controller: reason,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter reason for deletion',
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
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            var data =  await Scheduled_Payment_repo().DeleteScheduled_Payment(pro_id:id,reason:reason.text);
              if(data != null)
                setState(() {
                  futurescheduledpayment = Scheduled_Payment_repo().fetchScheduled_Payment();
                });
              Navigator.pop(context);
          },
          color:blueColor,
        ),
         DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: blueColor, fontSize: 18,fontWeight: FontWeight.bold),
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

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    return Scaffold(
      appBar: widget_302_Staff.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawerStaff(
        currentpage: "Scheduled Payment",
        dropdown: true,
      ),
      body: _connectivityResult != ConnectivityResult.none
          ? SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  //add propertytype
                  Padding(
                    padding: const EdgeInsets.only(left: 0, right: 0),
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: titleBar(
                            width: MediaQuery.of(context).size.width * .91,
                            title: 'Scheduled Payment',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  //search
                  Padding(
                    padding: const EdgeInsets.only(left: 11, right: 11),
                    child: Row(
                      children: [
                        if (MediaQuery.of(context).size.width < 500) const SizedBox(width: 1),
                        if (MediaQuery.of(context).size.width > 500) const SizedBox(width: 24),
                        Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            // height: 40,
                            height: MediaQuery.of(context).size.width < 500 ? 45 : 50,
                            width: MediaQuery.of(context).size.width < 500 ? MediaQuery.of(context).size.width * .52 : MediaQuery.of(context).size.width * .49,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                // border: Border.all(color: Colors.grey),
                                border: Border.all(color: const Color(0xFF8A95A8))),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: TextField(
                                    style: TextStyle(fontSize: MediaQuery.of(context).size.width < 500 ? 15 : 14),
                                    // onChanged: (value) {
                                    //   setState(() {
                                    //     cvverror = false;
                                    //   });
                                    // },
                                    // controller: cvv,
                                    onChanged: (value) {
                                      setState(() {
                                        searchvalue = value;
                                        if (currentPage != 0) currentPage = 0;
                                      });
                                    },
                                    cursorColor: blueColor,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Search here...",
                                        hintStyle: TextStyle(
                                          fontSize: MediaQuery.of(context).size.width < 500 ? 14 : 18,
                                          // fontWeight: FontWeight.bold,
                                          color: const Color(0xFF8A95A8),
                                        ),
                                        contentPadding: const EdgeInsets.only(left: 5, bottom: 12, top: 5)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (MediaQuery.of(context).size.width > 500) const SizedBox(height: 25),
                  if (MediaQuery.of(context).size.width < 500)
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FutureBuilder<List<Scheduled_Payment>>(
                        future: futurescheduledpayment,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return ColabShimmerLoadingWidget();
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Container(
                              height: MediaQuery.of(context).size.height * .5,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/images/no_data.jpg",
                                      height: 200,
                                      width: 200,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "No Data Available",
                                      style: TextStyle(fontWeight: FontWeight.bold, color: blueColor, fontSize: 16),
                                    )
                                  ],
                                ),
                              ),
                            );
                          } else {
                            var data = snapshot.data!;
                            if (selectedValue == null && searchvalue.isEmpty) {
                              data = snapshot.data!;
                            } else if (selectedValue == "All") {
                              data = snapshot.data!;
                            } else if (searchvalue.isNotEmpty) {
                              data = snapshot.data!
                                  .where((applicant) =>
                              applicant.rentalAddress!
                                  .toLowerCase()
                                  .contains(searchvalue.toLowerCase()) ||
                                  applicant.rentalAddress!.toString()
                                      .toLowerCase()
                                      .contains(searchvalue.toLowerCase()) ||
                                  applicant.tenant!.tenantName.toString()
                                      .toLowerCase()
                                      .contains(searchvalue.toLowerCase())||
                                  applicant.totalAmount.toString()
                                      .toLowerCase()
                                      .contains(searchvalue.toLowerCase())||
                                  applicant.date.toString()
                                      .toLowerCase()
                                      .contains(searchvalue.toLowerCase())
                              )
                                  .toList();
                            } else {
                              data = snapshot.data!.where((applicant) => applicant.rentalAddress == selectedValue).toList();
                            }
                            if (data.isEmpty) {
                              return Center(
                                child:
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/images/no_data.jpg",
                                      height: 200,
                                      width: 200,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "No Data Available",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: blueColor,
                                          fontSize: 16),
                                    )
                                  ],
                                ),
                              );
                            }
                            /* if (selectedValue == null && searchvalue!.isEmpty) {
                        data = snapshot.data!;
                      } else if (selectedValue == "All") {
                        data = snapshot.data!;
                      } else if (searchvalue!.isNotEmpty) {
                        data = snapshot.data!
                            .where((property) =>
                        property.propertyType!
                            .toLowerCase()
                            .contains(searchvalue!.toLowerCase()) ||
                            property.propertysubType!
                                .toLowerCase()
                                .contains(searchvalue!.toLowerCase()))
                            .toList();
                      } else {
                        data = snapshot.data!
                            .where((property) =>
                        property.propertyType == selectedValue)
                            .toList();
                      }*/
                             //sortData(data);
                            final totalPages = (data.length / itemsPerPage).ceil();
                            final currentPageData = data.skip(currentPage * itemsPerPage).take(itemsPerPage).toList();
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  _buildHeaders(),
                                  const SizedBox(height: 10),
                                  Container(
                                    // decoration: BoxDecoration(border: Border.all(color: Color.fromRGBO(152, 162, 179, .5))),
                                    // decoration: BoxDecoration(
                                    //     border: Border.all(color: blueColor)),
                                    child: Column(
                                      children: currentPageData.asMap().entries.map((entry) {
                                        int index = entry.key;
                                        bool isExpanded = expandedIndex == index;
                                        Scheduled_Payment Propertytype = entry.value;

                                        //return CustomExpansionTile(data: Propertytype, index: index);
                                        return Container(
                                          margin:
                                          const EdgeInsets.symmetric(vertical: 6),
                                          decoration: BoxDecoration(
                                            color: index % 2 != 0
                                                ? const Color(0xFFF4F8FF)
                                                : Colors.white,
                                            border: Border.all(
                                                color: const Color(0xFFDBE0E5)),
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            children: <Widget>[
                                              ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                title: Padding(
                                                  padding: const EdgeInsets.all(2.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                                            if (expandedIndex == index) {
                                                              expandedIndex = null;
                                                            } else {
                                                              expandedIndex = index;
                                                            }
                                                          });
                                                        },
                                                        child: Container(
                                                          margin: const EdgeInsets.only(left: 5, right: 5),
                                                          padding: !isExpanded ? const EdgeInsets.only(bottom: 10) : const EdgeInsets.only(top: 10),
                                                          child: FaIcon(
                                                            isExpanded ? FontAwesomeIcons.sortUp : FontAwesomeIcons.sortDown,
                                                            size: 20,
                                                            color: blueColor,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 4,
                                                        child: InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              if (expandedIndex == index) {
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
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: MediaQuery.of(context).size.width * .03),
                                                      Expanded(
                                                        flex: 4,
                                                        child: Text(
                                                          '${Propertytype.tenant!.tenantName}',
                                                          style: TextStyle(
                                                            color: blueColor,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: MediaQuery.of(context).size.width * .03),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(left: 10.0),
                                                          child: Text(
                                                            // '${widget.data.createdAt}',
                                                          '${Propertytype.totalAmount != null ? '\$${Propertytype.totalAmount}' : 'N/A'}',
                                                            style: TextStyle(
                                                              color: blueColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: MediaQuery.of(context).size.width * .02),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (isExpanded)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                                  margin: const EdgeInsets.only(bottom: 2),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        // if (Propertytype
                                                        //     .isRenewing !=
                                                        //     false)

                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 18.0),
                                                          child: Text.rich(
                                                            TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text: 'Date : ',
                                                                  style: TextStyle(fontWeight: FontWeight.bold, color: blueColor), // Bold and black
                                                                ),
                                                                TextSpan(
                                                                  // text: formatDate(
                                                                  //     '${Propertytype.updatedAt}'),
                                                                  text: Propertytype.date?.isNotEmpty == true ? dateProvider.formatCurrentDate('${Propertytype.date}') : 'N/A',
                                                                  style: TextStyle(fontWeight: FontWeight.w700, color: grey), // Light and grey
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 15,
                                                        ),
                                                        Row(
                                                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: GestureDetector(
                                                                onTap: () async {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => SummeryPageLease(
                                                                            leaseId: Propertytype.leaseId!,
                                                                            enddate: Propertytype.date,
                                                                            isredirectpayment: true,
                                                                          )));
                                                                },
                                                                child:
                                                                Container(
                                                                  height: 40,
                                                                  decoration: BoxDecoration(
                                                                    border: Border.all(color: blueColor, width: 1.5),
                                                                    borderRadius:
                                                                    BorderRadius.circular(
                                                                        8),
                                                                  ), // color:Colors.grey[100],
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        'assets/icons/view.png',
                                                                        color:
                                                                        blueColor,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                        10,
                                                                      ),
                                                                      Text(
                                                                        "View",
                                                                        style: TextStyle(
                                                                            color:
                                                                            blueColor,
                                                                            fontWeight:
                                                                            FontWeight.bold),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Expanded(
                                                              child: GestureDetector(
                                                                onTap: () async {
                                                                  _showAlert(context, Propertytype.sId!, Propertytype);
                                                                },
                                                                child:
                                                                Container(
                                                                  height: 40,
                                                                  decoration: BoxDecoration(
                                                                    border: Border.all(color: Colors.red, width: 1.5),
                                                                    borderRadius:
                                                                    BorderRadius.circular(
                                                                        8),
                                                                  ), // color:Colors.grey[100],
                                                                  child: const Row(
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                    children: [
                                                                      FaIcon(
                                                                        FontAwesomeIcons
                                                                            .trashCan,
                                                                        size:
                                                                        15,
                                                                        color:
                                                                        Colors.red,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                        10,
                                                                      ),
                                                                      Text(
                                                                        "Delete",
                                                                        style: TextStyle(
                                                                            color:
                                                                            Colors.red,
                                                                            fontWeight:
                                                                            FontWeight.bold),
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
                                              //SizedBox(height: 13,),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          // Text('Rows per page:'),
                                          const SizedBox(width: 10),
                                          Material(
                                            elevation: 3,
                                            child: Container(
                                              height: 40,
                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                              ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<int>(
                                                  value: itemsPerPage,
                                                  items: itemsPerPageOptions.map((int value) {
                                                    return DropdownMenuItem<int>(
                                                      value: value,
                                                      child: Text(value.toString()),
                                                    );
                                                  }).toList(),
                                                  onChanged: data.length > itemsPerPageOptions.first // Condition to check if dropdown should be enabled
                                                      ? (newValue) {
                                                          setState(() {
                                                            itemsPerPage = newValue!;
                                                            currentPage = 0; // Reset to first page when items per page change
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
                                              color: currentPage == 0 ? Colors.grey : blueColor,
                                            ),
                                            onPressed: currentPage == 0
                                                ? null
                                                : () {
                                                    setState(() {
                                                      currentPage--;
                                                    });
                                                  },
                                          ),
                                          // IconButton(
                                          //   icon: Icon(Icons.arrow_back),
                                          //   onPressed: currentPage > 0
                                          //       ? () {
                                          //     setState(() {
                                          //       currentPage--;
                                          //     });
                                          //   }
                                          //       : null,
                                          // ),
                                          Text('Page ${currentPage + 1} of $totalPages'),
                                          // IconButton(
                                          //   icon: Icon(Icons.arrow_forward),
                                          //   onPressed: currentPage < totalPages - 1
                                          //       ? () {
                                          //     setState(() {
                                          //       currentPage++;
                                          //     });
                                          //   }
                                          //       : null,
                                          // ),
                                          IconButton(
                                            icon: FaIcon(
                                              FontAwesomeIcons.circleChevronRight,
                                              color: currentPage < totalPages - 1 ? blueColor : Colors.grey,
                                            ),
                                            onPressed: currentPage < totalPages - 1
                                                ? () {
                                                    setState(() {
                                                      currentPage++;
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
                  /* if (MediaQuery.of(context).size.width > 500)
              FutureBuilder<List<propertytype>>(
                future: futurePropertyTypes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ShimmerTabletTable();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Container(
                      height: MediaQuery.of(context).size.height * .5,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/no_data.jpg",
                              height: 200,
                              width: 200,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "No Data Available",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: blueColor,
                                  fontSize: 16),
                            )
                          ],
                        ),
                      ),
                    );
                  } else {
                    _tableData = snapshot.data!;
                    if (selectedValue == null && searchvalue.isEmpty) {
                      _tableData = snapshot.data!;
                    } else if (selectedValue == "All") {
                      _tableData = snapshot.data!;
                    } else if (searchvalue.isNotEmpty) {
                      _tableData = snapshot.data!
                          .where((property) =>
                      property.propertyType!
                          .toLowerCase()
                          .contains(searchvalue.toLowerCase()) ||
                          property.propertysubType!
                              .toLowerCase()
                              .contains(searchvalue.toLowerCase()))
                          .toList();
                    } else {
                      _tableData = snapshot.data!
                          .where((property) =>
                      property.propertyType == selectedValue)
                          .toList();
                    }
                    totalrecords = _tableData.length;
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 5),
                              child: Column(
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          .91,
                                      child: Table(
                                        defaultColumnWidth:
                                        IntrinsicColumnWidth(),
                                        children: [
                                          TableRow(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                // color: blueColor
                                              ),
                                            ),
                                            children: [

                                              _buildHeader(
                                                  'Main Type',
                                                  0,
                                                      (property) =>
                                                  property.propertyType!),
                                              _buildHeader(
                                                  'Subtype',
                                                  1,
                                                      (property) => property
                                                      .propertysubType!),
                                              _buildHeader(
                                                  'Created At', 2, null),
                                              _buildHeader(
                                                  'Updated At', 3, null),
                                              _buildHeader('Actions', 4, null),
                                            ],
                                          ),
                                          TableRow(
                                            decoration: BoxDecoration(
                                              border: Border.symmetric(
                                                  horizontal: BorderSide.none),
                                            ),
                                            children: List.generate(
                                                5,
                                                    (index) => TableCell(
                                                    child:
                                                    Container(height: 20))),
                                          ),
                                          for (var i = 0;
                                          i < _pagedData.length;
                                          i++)
                                            TableRow(
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  left: BorderSide(
                                                      color: blueColor


),
                                                  right: BorderSide(
                                                      color: blueColor


),
                                                  top: BorderSide(
                                                      color: blueColor


),
                                                  bottom: i ==
                                                      _pagedData.length - 1
                                                      ? BorderSide(
                                                      color: blueColor


)
                                                      : BorderSide.none,
                                                ),
                                              ),
                                              children: [

                                                // Text(
                                                //     '${_pagedData[i].propertyType!}'),
                                                // Text(
                                                //     '${_pagedData[i].propertysubType!}'),
                                                // Text(
                                                //     '${formatDate(_pagedData[i].createdAt!)}'),
                                                // Text(
                                                //     '${formatDate(_pagedData[i].updatedAt!)}'),
                                                _buildDataCell(_pagedData[i]
                                                    .propertyType!),

                                                _buildDataCell(_pagedData[i]
                                                    .propertysubType!),

                                                _buildDataCell(
                                                  formatDate(
                                                      _pagedData[i].createdAt!),
                                                ),

                                                _buildDataCell(
                                                  formatDate(
                                                      _pagedData[i].updatedAt!),
                                                ),
                                                _buildActionsCell(
                                                    _pagedData[i]),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 25),
                                  _buildPaginationControls(),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 25),
                        ],
                      ),
                    );
                  }
                },
              ),*/
                ],
              ),
            )
          : SizedBox(
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
                  const Text(
                    'No Internet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Check your internet connection',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
    );
  }
}
