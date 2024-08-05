// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:three_zero_two_property/Model/Preminum%20Plans/GetCardDetailModel.dart';
// import 'package:three_zero_two_property/repository/Preminum%20Plans/GetCardDetailSerivce.dart';
// import 'package:three_zero_two_property/screens/Plans/PreminumPlanForm.dart';
// import 'package:three_zero_two_property/screens/Plans/planform.dart';
// import '../../widgets/appbar.dart';
// import '../../widgets/drawer_tiles.dart';

// class Plan_screen extends StatefulWidget {
//   const Plan_screen({Key? key}) : super(key: key);

//   @override
//   State<Plan_screen> createState() => _Plan_screenState();
// }

// class _Plan_screenState extends State<Plan_screen> {
//   late Future<List<CardData>> _futureCard;
//   List<CardData> Cards = [];
//   bool isLoading = true;
//   String? errorMessage;

//   @override
//   void initState() {
//     // TODO: implement initState
//     _futureCard = fetchData();
//     super.initState();
//   }

//   Future<List<CardData>> fetchData() async {
//     GetCardDetailService service = GetCardDetailService();
//     try {
//       List<CardData>? data = await service.fetchCardDetail();
//       setState(() {
//         Cards = data!;
//         isLoading = false;
//         errorMessage = null; // Reset error message on successful data fetch
//       });
//       return data!;
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         errorMessage =
//             'Failed to load renters insurance data. Please try again later.';
//       });
//       return [];
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;
//     return Scaffold(
//       appBar: widget_302.App_Bar(context: context),
//       backgroundColor: Colors.white,
//       drawer: Drawer(
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.white,
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               const SizedBox(height: 40),
//               Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Image.asset("assets/images/logo.png"),
//               ),
//               const SizedBox(height: 40),
//               buildListTile(
//                   context,
//                   const Icon(
//                     CupertinoIcons.circle_grid_3x3,
//                     color: Colors.white,
//                   ),
//                   "Dashboard",
//                   true),
//               buildListTile(
//                   context,
//                   const Icon(
//                     CupertinoIcons.house,
//                     color: Colors.black,
//                   ),
//                   "Add Property Type",
//                   false),
//               buildListTile(
//                   context,
//                   const Icon(
//                     CupertinoIcons.person_add,
//                     color: Colors.black,
//                   ),
//                   "Add Staff Member",
//                   false),
//               buildDropdownListTile(
//                   context,
//                   const FaIcon(
//                     FontAwesomeIcons.key,
//                     size: 20,
//                     color: Colors.black,
//                   ),
//                   "Rental",
//                   ["Properties", "RentalOwner", "Tenants"]),
//               buildDropdownListTile(
//                   context,
//                   const FaIcon(
//                     FontAwesomeIcons.thumbsUp,
//                     size: 20,
//                     color: Colors.black,
//                   ),
//                   "Leasing",
//                   ["Rent Roll", "Applicants"]),
//               buildDropdownListTile(
//                   context,
//                   Image.asset("assets/icons/maintence.png",
//                       height: 20, width: 20),
//                   "Maintenance",
//                   ["Vendor", "Work Order"]),
//             ],
//           ),
//         ),
//       ),
//       body: FutureBuilder<List<CardData>>(
//           future: _futureCard,
//           builder: (context, snapshot) {
//             if (isLoading) {
//               return const Center(
//                 child: SpinKitFadingCircle(
//                   color: Colors.black,
//                   size: 40.0,
//                 ),
//               );
//             } else if (snapshot.hasError) {
//               return Center(child: Text(errorMessage ?? 'Unknown error'));
//             } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return const Center(child: Text('No data available'));
//             }
//             var data = snapshot.data!;
//             return SingleChildScrollView(
//               child: Column(
//                 children:
//                     data.map((plan) => buildPlanCard(context, plan)).toList(),
//               ),
//             );
//           }),
//     );
//   }
// }

// Widget buildPlanCard(BuildContext context, CardData plan) {
//   return Padding(
//     padding:
//         const EdgeInsets.only(top: 8.0, left: 28.0, right: 28.0, bottom: 8.0),
//     child: Container(
//       //  width: MediaQuery.of(context).size.width * .78,
//       // height: MediaQuery.of(context).size.height * ,
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: Colors.black,
//             width: 1,
//           )),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             height: 50,
//             decoration: const BoxDecoration(
//               color: Color.fromRGBO(21, 43, 81, 1),
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(20), topRight: Radius.circular(20)),
//             ),
//             child: Row(
//               children: [
//                 const SizedBox(
//                   width: 20,
//                 ),
//                 Image.asset(
//                   "assets/icons/plan_icon.png",
//                   height: 20,
//                 ),
//                 const SizedBox(
//                   width: 10,
//                 ),
//                 Text(
//                   "${plan.planName}",
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18),
//                 )
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(15),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("\$${plan.planPrice} / ${plan.billingInterval}",
//                     style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Color.fromRGBO(21, 43, 81, 1)))
//               ],
//             ),
//           ),
//           ...plan.features!
//               .map((feature) => Row(
//                     children: [
//                       const SizedBox(width: 15),
//                       Padding(
//                         padding: const EdgeInsets.only(top: 4),
//                         child: const Icon(Icons.fiber_manual_record, size: 15),
//                       ),
//                       const SizedBox(width: 5),
//                       Expanded(
//                           child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(
//                             height: 4,
//                           ),
//                           Text(feature.features!,
//                               style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                   color: Color.fromRGBO(21, 43, 81, 1))),
//                         ],
//                       )),
//                     ],
//                   ))
//               .toList(),
//           const SizedBox(
//             height: 30,
//           ),
//           GestureDetector(
//             onTap: () {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => PreminumPlanForm(
//                             plan: plan,
//                           )));
//             },
//             child: Center(
//               child: Material(
//                 elevation: 3,
//                 borderRadius: BorderRadius.circular(4),
//                 child: Container(
//                   width: 120,
//                   height: 40,
//                   decoration: BoxDecoration(
//                       color: const Color.fromRGBO(21, 43, 81, 1),
//                       borderRadius: BorderRadius.circular(4)),
//                   child: const Center(
//                       child: Text(
//                     "Get Started",
//                     style: TextStyle(color: Colors.white),
//                   )),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           const Center(
//               child: Text(
//             "Term Apply",
//             style: TextStyle(
//                 color: Color.fromRGBO(21, 43, 81, 1),
//                 fontWeight: FontWeight.bold),
//           )),
//           const SizedBox(
//             height: 25,
//           ),
//         ],
//       ),
//     ),
//   );
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shimmer/shimmer.dart';
import 'package:three_zero_two_property/Model/Preminum%20Plans/getPlanDetailModel.dart';
import 'package:three_zero_two_property/Model/Preminum%20Plans/pastPlansHistoryModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/provider/Plan%20Purchase/plancheckProvider.dart';
import 'package:three_zero_two_property/repository/Preminum%20Plans/cancelSubscription.dart';
import 'package:three_zero_two_property/repository/Preminum%20Plans/getPlanDetailService.dart';
import 'package:three_zero_two_property/repository/Preminum%20Plans/pastPlansHistoryService.dart';
import 'package:three_zero_two_property/screens/Plans/PlansPurcharCard.dart';
import 'package:three_zero_two_property/widgets/CustomTableShimmer.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';

class getPlanDetailScreen extends StatefulWidget {
  @override
  State<getPlanDetailScreen> createState() => _getPlanDetailScreenState();
}

class _getPlanDetailScreenState extends State<getPlanDetailScreen> {
  Future<List<pastPlanData>>? _futureReport;
  late Future<getPlanDetailModel?> _futurePlanDetails;
  final getPlanDetailService _service = getPlanDetailService();
  bool isLoading = false;
  String? globalPlanName;
  bool isPlanCancelling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<checkPlanPurchaseProiver>(context, listen: false);
      if (!provider.isLoading) {
        setState(() {
          globalPlanName =
              provider.checkplanpurchaseModel?.data?.planDetail?.planName ??
                  'No Plan';
        });
      }
    });
    _futureReport = _fetchPastPlans();
    _futurePlanDetails = _service.fetchPlanPurchaseDetails();
  }

  Future<List<pastPlanData>> _fetchPastPlans() async {
    // Use await to get the Future result from PastPlansHistoryService
    return await PastPlansHistoryService().fetchPastPlans();
  }

  Widget _buildDataCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 16, bottom: 20.0),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  int totalrecords = 0;
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
  ];

  void _showEnhancedAlert(
      BuildContext context, String SubscriptionId, String purchaseId) {
    bool isPlanCancelling = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "Warning",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              content: Text(
                "Do you want to cancel your subscription?",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: BorderSide(color: blueColor, width: 2),
              ),
              actions: <Widget>[
                Container(
                  width: 70,
                  child: ElevatedButton(
                    child: isPlanCancelling
                        ? const Center(
                            child: SpinKitFadingCircle(
                              color: Colors.white,
                              size: 25.0,
                            ),
                          )
                        : Text(
                            "Yes",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () async {
                      setState(() {
                        isPlanCancelling = true;
                      });
                      SubscriptionService service = SubscriptionService();
                      int statusCode =
                          await service.cancelSubscription(SubscriptionId);
                      int statusCode1 = await service
                          .cancelFromDataBaseSubscription(purchaseId);

                      if (statusCode == 200 && statusCode1 == 200) {
                        setState(() {
                          isPlanCancelling = false;
                        });
                        Fluttertoast.showToast(
                            msg: 'Subscription cancelled successfully.');
                        print('Subscription cancelled successfully.');
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PlanPurchaseCard()),
                          (Route<dynamic> route) => false,
                        );
                      } else {
                        setState(() {
                          isPlanCancelling = false;
                        });
                        Fluttertoast.showToast(
                            msg: 'Failed to cancel subscription.');
                        print(
                            'Failed to cancel subscription. Status code: $statusCode');
                      }
                    },
                  ),
                ),
                Container(
                  width: 70,
                  child: ElevatedButton(
                    child: Text(
                      "No",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _changeRowsPerPage(int selectedRowsPerPage) {
    setState(() {
      _rowsPerPage = selectedRowsPerPage;
      _currentPage = 0; // Reset to the first page when changing rows per page
    });
  }

  List<pastPlanData> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String searchvalue = "";
  String? selectedValue;

  List<pastPlanData> get _pagedData {
    int startIndex = _currentPage * _rowsPerPage;
    int endIndex = startIndex + _rowsPerPage;
    return _tableData.sublist(startIndex,
        endIndex > _tableData.length ? _tableData.length : endIndex);
  }

  Widget _buildPaginationControls() {
    int totalPages = (totalrecords / _rowsPerPage).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Material(
          elevation: 2,
          color: Colors.white,
          child: Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _rowsPerPage,
                items: [10, 25, 50, 100].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _rowsPerPage = newValue;
                      _currentPage = 0; // Reset to first page
                    });
                  }
                },
                icon: const Icon(
                  Icons.arrow_drop_down,
                  size: 40,
                ),
                style: const TextStyle(color: Colors.black, fontSize: 17),
                dropdownColor: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.circleChevronLeft,
            size: 30,
            color: _currentPage == 0
                ? Colors.grey
                : const Color.fromRGBO(21, 43, 83, 1),
          ),
          onPressed: _currentPage == 0
              ? null
              : () {
                  setState(() {
                    _currentPage--;
                  });
                },
        ),
        Text(
          'Page ${_currentPage + 1} of $totalPages',
          style: const TextStyle(fontSize: 18),
        ),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.circleChevronRight,
            size: 30,
            color: (_currentPage + 1) * _rowsPerPage >= totalrecords
                ? Colors.grey
                : const Color.fromRGBO(21, 43, 83, 1),
          ),
          onPressed: (_currentPage + 1) * _rowsPerPage >= totalrecords
              ? null
              : () {
                  setState(() {
                    _currentPage++;
                  });
                },
        ),
      ],
    );
  }

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
    // var width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: blueColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(13),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
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
                    if (sorting1) {
                      // Toggle sorting for the same column
                      ascending1 = !ascending1;
                    } else {
                      // Switch to sorting by this column
                      sorting1 = true;
                      sorting2 = false;
                      sorting3 = false;
                      ascending1 = true;
                    }
                    sorting2 = false;
                    sorting3 = false;

                    // Sort the data after state change
                  });
                },
                child: Row(
                  children: [
                    const Text("Plan Name",
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 3),
                    ascending1
                        ? const Padding(
                            padding: EdgeInsets.only(top: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortUp,
                              size: 20,
                              color: Colors.white,
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.only(bottom: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortDown,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sorting2) {
                      // Toggle sorting for the same column
                      ascending2 = !ascending2;
                    } else {
                      // Switch to sorting by this column
                      sorting1 = false;
                      sorting2 = true;
                      sorting3 = false;
                      ascending2 = true;
                    }
                    sorting1 = false;
                    sorting3 = false;

                    // Sort the data after state change
                    // sortData(_futureReport.data ?? []);
                  });
                },
                child: Row(
                  children: [
                    const Text("Status", style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 5),
                    ascending2
                        ? const Padding(
                            padding: EdgeInsets.only(top: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortUp,
                              size: 20,
                              color: Colors.white,
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.only(bottom: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortDown,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(pastPlanData d)? getField) {
    return TableCell(
      child: InkWell(
        onTap: getField != null
            ? () {
                _sort(getField, columnIndex, !_sortAscending);
              }
            : null,
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

  void _sort<T>(Comparable<T> Function(pastPlanData d) getField,
      int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _tableData.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        final result = aValue.compareTo(bValue as T);
        return _sortAscending ? result : -result;
      });
    });
  }

  void sortData(List<pastPlanData> data) {
    if (sorting1) {
      data.sort((a, b) => ascending1
          ? a.planName!.compareTo(b.planName!)
          : b.planName!.compareTo(a.planName!));
    } else if (sorting2) {
      data.sort((a, b) {
        int comparison = (a.isActive == true ? 'Active' : 'Inactive')
            .compareTo(b.isActive == true ? 'Active' : 'Inactive');
        return ascending2 ? comparison : -comparison;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: widget_302.App_Bar(context: context, isPlanPageActive: true),
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
                    color: Colors.white,
                  ),
                  "Dashboard",
                  true),
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
      body: globalPlanName == 'Free Plan'
          ? PlanPurchaseCard(isappbarShow: false)
          : SingleChildScrollView(
              child: Column(
                children: [
                  FutureBuilder<getPlanDetailModel?>(
                    future: _futurePlanDetails,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CardShimmerCurrentPlan();
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const Center(child: Text('No data available'));
                      }

                      final data = snapshot.data!.data;
                      if (data == null) {
                        return const Center(
                            child: Text('No plan details found.'));
                      }

                      return Column(
                        children: [
                          if (MediaQuery.of(context).size.width < 500)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color.fromRGBO(21, 43, 83, 1),
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          'Current Subscription Details',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: blueColor)),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green),
                                            onPressed: () {},
                                            child: const Text(
                                              'Plan Upgrade',
                                              style: TextStyle(fontSize: 12),
                                            )),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red),
                                            onPressed: () {
                                              _showEnhancedAlert(
                                                  context,
                                                  data.subscriptionId!,
                                                  data.purchaseId!);
                                              print(data.subscriptionId);
                                            },
                                            child: const Text(
                                              'Cancel Subscription',
                                              style: TextStyle(fontSize: 12),
                                            )),
                                        const SizedBox(
                                          width: 16,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 360,
                                      height: 110,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: screenWidth * .040),
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      child: Material(
                                        elevation: 3,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15)),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: blueColor,
                                                  borderRadius:
                                                      const BorderRadius
                                                          .vertical(
                                                          top: Radius.circular(
                                                              15)),
                                                ),
                                                child: const Center(
                                                    child: Text(
                                                  "Plan Infomation",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 8,
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                          bottom:
                                                              Radius.circular(
                                                                  15)),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Text(
                                                            "PLAN NAME",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        138,
                                                                        149,
                                                                        168,
                                                                        1)),
                                                          ),
                                                          // SizedBox(height: 8), // Space between the text
                                                          Text(
                                                            "${data.planDetail?.planName}",
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color:
                                                                    blueColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      ),
                                                      Divider(
                                                        color: blueColor,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Text(
                                                            "PLAN PRICE",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        138,
                                                                        149,
                                                                        168,
                                                                        1)),
                                                          ),
                                                          // SizedBox(height: 8), // Space between the text
                                                          Text(
                                                            "\$${data.planDetail?.planPrice}",
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color:
                                                                    blueColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      width: 360,
                                      height: 110,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: screenWidth * .040),
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      child: Material(
                                        elevation: 3,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15)),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: blueColor,
                                                  borderRadius:
                                                      const BorderRadius
                                                          .vertical(
                                                          top: Radius.circular(
                                                              15)),
                                                ),
                                                child: const Center(
                                                    child: Text(
                                                  "Duration",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 8,
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                          bottom:
                                                              Radius.circular(
                                                                  15)),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Text(
                                                            "PURCHASE DATE",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        138,
                                                                        149,
                                                                        168,
                                                                        1)),
                                                          ),
                                                          // SizedBox(height: 8), // Space between the text
                                                          Text(
                                                            formatDate(data
                                                                .purchaseDate!),
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color:
                                                                    blueColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      ),
                                                      Divider(
                                                        color: blueColor,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Text(
                                                            "BILLING PERIOD",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        138,
                                                                        149,
                                                                        168,
                                                                        1)),
                                                          ),
                                                          // SizedBox(height: 8), // Space between the text
                                                          Text(
                                                            "\$${data.planDetail?.billingInterval}",
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color:
                                                                    blueColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16)
                                  ],
                                ),
                              ),
                            ),
                          if (MediaQuery.of(context).size.width > 500)
                            Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color.fromRGBO(21, 43, 83, 1),
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          'Current Subscription Details',
                                          style: TextStyle(
                                              fontSize: 21,
                                              fontWeight: FontWeight.bold,
                                              color: blueColor)),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green),
                                            onPressed: () {},
                                            child: const Text(
                                              'Plan Upgrade',
                                              style: TextStyle(fontSize: 16),
                                            )),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red),
                                            onPressed: () {
                                              _showEnhancedAlert(
                                                  context,
                                                  data.subscriptionId!,
                                                  data.purchaseId!);
                                            },
                                            child: const Text(
                                              'Cancel Subscription',
                                              style: TextStyle(fontSize: 16),
                                            )),
                                        const SizedBox(
                                          width: 16,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Container(
                                          width: screenWidth * 0.43,
                                          height: 110,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: screenWidth * .016),
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                          ),
                                          child: Material(
                                            elevation: 3,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(15)),
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: blueColor,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .vertical(
                                                              top: Radius
                                                                  .circular(
                                                                      15)),
                                                    ),
                                                    child: const Center(
                                                        child: Text(
                                                      "Plan Infomation",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 8,
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                              bottom: Radius
                                                                  .circular(
                                                                      15)),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              const Text(
                                                                "PLAN NAME",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            138,
                                                                            149,
                                                                            168,
                                                                            1)),
                                                              ),
                                                              // SizedBox(height: 8), // Space between the text
                                                              Text(
                                                                "${data.planDetail?.planName}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color:
                                                                        blueColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Divider(
                                                            color: blueColor,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              const Text(
                                                                "PLAN PRICE",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            138,
                                                                            149,
                                                                            168,
                                                                            1)),
                                                              ),
                                                              // SizedBox(height: 8), // Space between the text
                                                              Text(
                                                                "\$${data.planDetail?.planPrice}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color:
                                                                        blueColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // SizedBox(width: 16),
                                        Container(
                                          width: screenWidth * 0.43,
                                          height: 110,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: screenWidth * .016),
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                          ),
                                          child: Material(
                                            elevation: 3,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(15)),
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: blueColor,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .vertical(
                                                              top: Radius
                                                                  .circular(
                                                                      15)),
                                                    ),
                                                    child: const Center(
                                                        child: Text(
                                                      "Duration",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 8,
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                              bottom: Radius
                                                                  .circular(
                                                                      15)),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              const Text(
                                                                "PURCHASE DATE",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            138,
                                                                            149,
                                                                            168,
                                                                            1)),
                                                              ),
                                                              // SizedBox(height: 8), // Space between the text
                                                              Text(
                                                                formatDate(data
                                                                    .purchaseDate!),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color:
                                                                        blueColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Divider(
                                                            color: blueColor,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              const Text(
                                                                "BILLING PERIOD",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            138,
                                                                            149,
                                                                            168,
                                                                            1)),
                                                              ),
                                                              // SizedBox(height: 8), // Spce between the text
                                                              Text(
                                                                "\$${data.planDetail?.billingInterval}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color:
                                                                        blueColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16)
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  if (MediaQuery.of(context).size.width < 500)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10.0,
                        right: 10.0,
                      ),
                      child: FutureBuilder<List<pastPlanData>>(
                        future: _futureReport,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ColabShimmerLoadingWidget();
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data == null ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('No data available'));
                          }

                          var data = snapshot.data!;

                          // Apply filtering based on selectedValue and searchvalue
                          if (selectedValue == null && searchvalue.isEmpty) {
                            data = snapshot.data!;
                          } else if (selectedValue == "All") {
                            data = snapshot.data!;
                          } else if (searchvalue.isNotEmpty) {
                            data = snapshot.data!
                                .where((workOrder) =>
                                    workOrder.planName!
                                        .toLowerCase()
                                        .contains(searchvalue.toLowerCase()) ||
                                    (workOrder.isActive!
                                            ? 'Active'
                                            : 'Inactive')
                                        .toLowerCase()
                                        .contains(searchvalue.toLowerCase()))
                                .toList();
                          } else {
                            data = snapshot.data!
                                .where((workOrder) =>
                                    workOrder.planName == selectedValue)
                                .toList();
                          }

                          // Sort data if necessary
                          sortData(data);

                          // Pagination logic
                          final totalPages =
                              (data.length / itemsPerPage).ceil();
                          final currentPageData = data
                              .skip(currentPage * itemsPerPage)
                              .take(itemsPerPage)
                              .toList();
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                // Expanded(
                                //   flex: 0,
                                //   child: Padding(
                                //     padding: const EdgeInsets.symmetric(
                                //         horizontal: 5.0, vertical: 5),
                                //     child: Row(
                                //       mainAxisAlignment:
                                //           MainAxisAlignment.spaceBetween,
                                //       children: [
                                //         Material(
                                //           elevation: 3,
                                //           borderRadius: BorderRadius.circular(2),
                                //           child: Container(
                                //             padding: const EdgeInsets.symmetric(
                                //                 horizontal: 10),
                                //             height:
                                //                 MediaQuery.of(context).size.width <
                                //                         500
                                //                     ? 40
                                //                     : 50,
                                //             width: MediaQuery.of(context).size.width <
                                //                     500
                                //                 ? MediaQuery.of(context).size.width *
                                //                     .90
                                //                 : MediaQuery.of(context).size.width *
                                //                     .90,
                                //             decoration: BoxDecoration(
                                //               color: Colors.white,
                                //               borderRadius: BorderRadius.circular(2),
                                //               border: Border.all(
                                //                   color: const Color(0xFF8A95A8)),
                                //             ),
                                //             child: TextField(
                                //               onChanged: (value) {
                                //                 setState(() {
                                //                   searchvalue = value;
                                //                 });
                                //               },
                                //               decoration: const InputDecoration(
                                //                 border: InputBorder.none,
                                //                 hintText: "Search here...",
                                //                 hintStyle: TextStyle(
                                //                     color: Color(0xFF8A95A8)),
                                //               ),
                                //             ),
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // ),
                                const SizedBox(height: 10),
                                _buildHeaders(),
                                const SizedBox(height: 20),
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: blueColor)),
                                  child: Column(
                                    children: currentPageData
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      int index = entry.key;
                                      bool isExpanded = expandedIndex == index;
                                      pastPlanData workOrder = entry.value;

                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: blueColor),
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              title: Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          if (expandedIndex ==
                                                              index) {
                                                            expandedIndex =
                                                                null;
                                                          } else {
                                                            expandedIndex =
                                                                index;
                                                          }
                                                        });
                                                      },
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                            .only(left: 5),
                                                        padding: !isExpanded
                                                            ? const EdgeInsets
                                                                .only(
                                                                bottom: 10)
                                                            : const EdgeInsets
                                                                .only(top: 10),
                                                        child: FaIcon(
                                                          isExpanded
                                                              ? FontAwesomeIcons
                                                                  .sortUp
                                                              : FontAwesomeIcons
                                                                  .sortDown,
                                                          size: 20,
                                                          color: const Color
                                                              .fromRGBO(
                                                              21, 43, 83, 1),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        '   ${workOrder.planName!.isEmpty ? '-- - - -- ----' : workOrder.planName} ',
                                                        style: TextStyle(
                                                          color: workOrder
                                                                      .isActive ==
                                                                  true
                                                              ? Colors.green
                                                              : blueColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .02),
                                                    Expanded(
                                                      child: Text(
                                                        workOrder.isActive ==
                                                                true
                                                            ? 'Active'
                                                            : 'Inactive',
                                                        style: TextStyle(
                                                          color: workOrder
                                                                      .isActive ==
                                                                  true
                                                              ? Colors.green
                                                              : blueColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (isExpanded)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                margin: const EdgeInsets.only(
                                                    bottom: 20),
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          FaIcon(
                                                            isExpanded
                                                                ? FontAwesomeIcons
                                                                    .sortUp
                                                                : FontAwesomeIcons
                                                                    .sortDown,
                                                            size: 50,
                                                            color: Colors
                                                                .transparent,
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <Widget>[
                                                                Row(
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          'Start Date',
                                                                          style:
                                                                              TextStyle(
                                                                            color: workOrder.isActive == true
                                                                                ? Colors.green
                                                                                : blueColor,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                14,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          ' ${formatDate(workOrder.purchaseDate!)}',
                                                                          style:
                                                                              TextStyle(
                                                                            color: workOrder.isActive == true
                                                                                ? Colors.green[800]
                                                                                : blueColor,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                14,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            .1),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          'End Date',
                                                                          style:
                                                                              TextStyle(
                                                                            color: workOrder.isActive == true
                                                                                ? Colors.green
                                                                                : blueColor,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                14,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          ' ${formatDate(workOrder.expirationDate!)}',
                                                                          style:
                                                                              TextStyle(
                                                                            color: workOrder.isActive == true
                                                                                ? Colors.green[800]
                                                                                : blueColor,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                14,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 40,
                                                            child: const Column(
                                                              children: [],
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
                                const SizedBox(height: 20),
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
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<int>(
                                                value: itemsPerPage,
                                                items: itemsPerPageOptions
                                                    .map((int value) {
                                                  return DropdownMenuItem<int>(
                                                    value: value,
                                                    child:
                                                        Text(value.toString()),
                                                  );
                                                }).toList(),
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    itemsPerPage = newValue!;
                                                    currentPage =
                                                        0; // Reset to first page when items per page change
                                                  });
                                                },
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
                                            color: currentPage == 0
                                                ? Colors.grey
                                                : const Color.fromRGBO(
                                                    21, 43, 83, 1),
                                          ),
                                          onPressed: currentPage == 0
                                              ? null
                                              : () {
                                                  setState(() {
                                                    currentPage--;
                                                  });
                                                },
                                        ),
                                        Text(
                                            'Page ${currentPage + 1} of $totalPages'),
                                        IconButton(
                                          icon: FaIcon(
                                            FontAwesomeIcons.circleChevronRight,
                                            color: currentPage < totalPages - 1
                                                ? const Color.fromRGBO(
                                                    21, 43, 83, 1)
                                                : Colors.grey,
                                          ),
                                          onPressed:
                                              currentPage < totalPages - 1
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
                        },
                      ),
                    ),
                  if (MediaQuery.of(context).size.width > 500)
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Material(
                              elevation: 3,
                              borderRadius: BorderRadius.circular(2),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                // height: 40,
                                height: MediaQuery.of(context).size.width < 500
                                    ? 40
                                    : 50,
                                width: MediaQuery.of(context).size.width < 500
                                    ? MediaQuery.of(context).size.width * .45
                                    : MediaQuery.of(context).size.width * .4,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                      color: const Color(0xFF8A95A8)),
                                ),
                                child: TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      searchvalue = value;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Search here...",
                                    hintStyle:
                                        TextStyle(color: Color(0xFF8A95A8)),
                                    // contentPadding: EdgeInsets.all(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (MediaQuery.of(context).size.width > 500)
                    const SizedBox(height: 25),
                  if (MediaQuery.of(context).size.width > 500)
                    FutureBuilder<List<pastPlanData>>(
                      future: _futureReport,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ShimmerTabletTable();
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(child: Text('No data available'));
                        }

                        var data = snapshot.data!;

                        // Apply filtering based on selectedValue and searchvalue
                        if (selectedValue == null && searchvalue.isEmpty) {
                          data = snapshot.data!;
                        } else if (selectedValue == "All") {
                          data = snapshot.data!;
                        } else if (searchvalue.isNotEmpty) {
                          data = snapshot.data!
                              .where((workOrder) =>
                                  workOrder.planName!
                                      .toLowerCase()
                                      .contains(searchvalue.toLowerCase()) ||
                                  (workOrder.isActive! ? 'Active' : 'Inactive')
                                      .toLowerCase()
                                      .contains(searchvalue.toLowerCase()))
                              .toList();
                        } else {
                          data = snapshot.data!
                              .where((workOrder) =>
                                  workOrder.planName == selectedValue)
                              .toList();
                        }

                        // Apply pagination
                        final int itemsPerPage = 10;
                        final int totalPages =
                            (data.length / itemsPerPage).ceil();
                        final int currentPage =
                            1; // Update this with your pagination logic
                        final List<pastPlanData> pagedData = data
                            .skip((currentPage - 1) * itemsPerPage)
                            .take(itemsPerPage)
                            .toList();

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Table(
                                    defaultColumnWidth:
                                        const IntrinsicColumnWidth(),
                                    columnWidths: {
                                      0: const FlexColumnWidth(),
                                      1: const FlexColumnWidth(),
                                      2: const FlexColumnWidth(),
                                      3: const FlexColumnWidth(),
                                      // 4: FlexColumnWidth(),
                                    },
                                    children: [
                                      TableRow(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: blueColor),
                                        ),
                                        children: [
                                          _buildHeader(
                                              'Date',
                                              0,
                                              (workOrder) =>
                                                  workOrder.planName!),
                                          _buildHeader('Address', 1,
                                              (workOrder) => workOrder.status!),
                                          _buildHeader(
                                              'Work',
                                              2,
                                              (workOrder) =>
                                                  workOrder.createdAt!),
                                          _buildHeader(
                                              'Description',
                                              3,
                                              (workOrder) =>
                                                  workOrder.expirationDate!),
                                          // _buildHeader('Note', 5,
                                          //     (workOrder) => workOrder.vendorNotes!),
                                        ],
                                      ),
                                      TableRow(
                                        decoration: const BoxDecoration(
                                          border: Border.symmetric(
                                              horizontal: BorderSide.none),
                                        ),
                                        children: List.generate(
                                            4,
                                            (index) => TableCell(
                                                child: Container(height: 20))),
                                      ),
                                      for (var i = 0; i < pagedData.length; i++)
                                        TableRow(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              left: const BorderSide(
                                                  color: Color.fromRGBO(
                                                      21, 43, 81, 1)),
                                              right: const BorderSide(
                                                  color: Color.fromRGBO(
                                                      21, 43, 81, 1)),
                                              top: const BorderSide(
                                                  color: Color.fromRGBO(
                                                      21, 43, 81, 1)),
                                              bottom: i == pagedData.length - 1
                                                  ? const BorderSide(
                                                      color: Color.fromRGBO(
                                                          21, 43, 81, 1))
                                                  : BorderSide.none,
                                            ),
                                          ),
                                          children: [
                                            _buildDataCell(
                                                pagedData[i].planName!),
                                            _buildDataCell(
                                                pagedData[i].isActive == true
                                                    ? 'Active'
                                                    : 'Inactive'),
                                            _buildDataCell(formatDate(
                                                pagedData[i].purchaseDate!)),
                                            _buildDataCell(
                                                pagedData[i].expirationDate!),
                                            // _buildDataCell(pagedData[i].vendorNotes!),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 25),
                                  _buildPaginationControls(),
                                  const SizedBox(height: 25),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}

class CardShimmerCurrentPlan extends StatelessWidget {
  const CardShimmerCurrentPlan({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: blueColor),
          color: Colors.white, // Ensure background color is set
          borderRadius: BorderRadius.circular(16.0),
        ),
        height: screenWidth > 500 ? 250 : 340,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16, bottom: 8),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300], // Set a different background color
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  height: 20,
                  width: 180,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors
                            .grey[300], // Set a different background color
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      height: 45,
                      width: 100,
                    ),
                  ),
                  SizedBox(width: 8),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors
                            .grey[300], // Set a different background color
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      height: 45,
                      width: 100,
                    ),
                  ),
                ],
              ),
            ),
            if (MediaQuery.of(context).size.width < 500)
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, top: 16, right: 16.0, bottom: 8),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          Colors.grey[300], // Set a different background color
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    height: 100,
                    width: double.infinity,
                  ),
                ),
              ),
            if (MediaQuery.of(context).size.width < 500)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          Colors.grey[300], // Set a different background color
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    height: 100,
                    width: double.infinity,
                  ),
                ),
              ),
            if (MediaQuery.of(context).size.width > 500)
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, top: 16, right: 16.0, bottom: 8),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors
                                .grey[300], // Set a different background color
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          height: 100,
                          width: screenWidth * 0.40),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors
                                .grey[300], // Set a different background color
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          height: 100,
                          width: screenWidth * 0.40),
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
