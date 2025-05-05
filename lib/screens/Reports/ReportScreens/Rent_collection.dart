import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';
import '../../../Model/Rent_collection_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:three_zero_two_property/widgets/CustomTableShimmer.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import '../../../repository/Rent_colllection_repository.dart';
import '../../../repository/daily_transaction_report.dart';
import '../../../widgets/custom_drawer.dart';

class Rent_collection extends StatefulWidget {
  const Rent_collection({super.key});

  @override
  State<Rent_collection> createState() => _Rent_collectionState();
}

class _Rent_collectionState extends State<Rent_collection> {
  late Future<Rentcollection_model> _futureRentcollection;
  Rentcollection_model? DelinquentTenantsModel;
  bool isLoading = true;
  String? errorMessage;
  int? expandedRowIndex;
  Map<int, int?> expandedTenantIndex = {};
  ConnectivityResult? _connectivityResult;
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  List<String> years = [];

  String selectedMonth = '';
  String selectedYear = '';
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
    fetchReport();
    initDropdowns();
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  void initDropdowns() {
    DateTime now = DateTime.now();

    // Set current month/year as default
    selectedMonth = months[now.month - 1]; // E.g., May
    selectedYear = now.year.toString();

    // Populate years list (e.g., last 10 years up to next year)
    int currentYear = now.year;
    for (int i = currentYear - 10; i <= currentYear + 1; i++) {
      years.add(i.toString());
    }
  }

  fetchReport() {
    setState(() {
      daterange = "Today";
      fromDate.text = formatDate(DateTime.now().toString());
      toDate.text = formatDate(DateTime.now().toString());
    });

    DateTime time = DateTime.now();
    DateTime date = DateFormat('yyyy-MM-dd').parse(time.toString());

    int monthNumber = months.indexOf(selectedMonth) + 1;

    // Assign the new Future to _futureRentcollection
    setState(() {
      _futureRentcollection = fetchDelinquentTenantsData(
        monthNumber.toString(),
        selectedYear,
      );
    });
  }

  Future<Rentcollection_model> fetchDelinquentTenantsData(
      String fromDate, String toDate,
      {String? charge}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString('token');

      String? chargedata = chargeType == "All" ? null : chargeType;

      Rentcollection_model data = await RentColllectionReport()
          .FetchRentColllection(id!, fromDate, toDate, chargetype: chargedata);

      setState(() {
        DelinquentTenantsModel = data;
        isLoading = false;
        errorMessage = null; // Reset error message on successful data fetch
      });
      return data;
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage =
            'Failed to load renters insurance data. Please try again later.';
      });
      return DelinquentTenantsModel!;
    }
  }

  double grandtotal = 0.0;
  List<DailyTransactionReport> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String searchvalue = "";
  String? selectedValue;

  int totalrecords = 0;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  int currentPage = 0;
  int itemsPerPage = 10;
  List<int> itemsPerPageOptions = [10, 25, 50, 100];
  bool customdate = false;

  int? nestedExpandedIndex;

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
        color: blueColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(13),
        ),
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
              child: GestureDetector(
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
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Row(
                    children: [
                      width < 400
                          ? const Text("   Entity",
                              style: TextStyle(color: Colors.white))
                          : const Text("   Entity",
                              style: TextStyle(color: Colors.white)),
                      // Text("Property", style: TextStyle(color: Colors.white)),
                      // const SizedBox(width: 3),
                      // ascending1
                      //     ? const Padding(
                      //         padding: EdgeInsets.only(top: 7, left: 2),
                      //         child: FaIcon(
                      //           FontAwesomeIcons.sortUp,
                      //           size: 20,
                      //           color: Colors.white,
                      //         ),
                      //       )
                      //     : const Padding(
                      //         padding: EdgeInsets.only(bottom: 7, left: 2),
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
            ),
            Expanded(
              child: GestureDetector(
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
                    Text("Total Outstanding",
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            // Expanded(
            //   child: GestureDetector(
            //     onTap: () {
            //       setState(() {
            //         if (sorting3) {
            //           sorting1 = false;
            //           sorting2 = false;
            //           sorting3 = sorting3;
            //           ascending3 = sorting3 ? !ascending3 : true;
            //           ascending2 = false;
            //           ascending1 = false;
            //         } else {
            //           sorting1 = false;
            //           sorting2 = false;
            //           sorting3 = !sorting3;
            //           ascending3 = sorting3 ? !ascending3 : true;
            //           ascending2 = false;
            //           ascending1 = false;
            //         }
            //
            //         // Sorting logic here
            //       });
            //     },
            //     child: Row(
            //       children: [
            //         Text("     Record", style: TextStyle(color: Colors.white)),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  bool istenantDataLoading = false;
  bool isAddLoading = false;
//  bool customdate = false;

  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();
  String? daterange;
  String? chargeType;
  String? selectedrenatalownerid;
  bool showTableData = false;
  int _selectedIndex = 0;
  final List<String> downloadOptions = ['PDF', 'Excel', 'CSV'];
  void handleDownload(String format) {
    // Replace with your download logic
    print("Downloading as $format");
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      drawer: CustomDrawer(
        currentpage: "Report",
        dropdown: false,
      ),
      body: _connectivityResult != ConnectivityResult.none
          ? SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  titleBar(
                    title: 'Daily Transaction Report',
                    width: MediaQuery.of(context).size.width * .91,
                  ),
                  if (MediaQuery.of(context).size.width > 500)
                    const SizedBox(height: 16),
                  if (MediaQuery.of(context).size.width < 500)
                    FutureBuilder<Rentcollection_model>(
                      future: _futureRentcollection,
                      builder: (context, snapshot) {
                        if (isLoading) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ColabShimmerLoadingWidget(),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.summary!.isEmpty) {
                          return Column(
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height * .5,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/images/no_data.jpg",
                                        height: 200,
                                        width: 200,
                                      ),
                                      SizedBox(height: 10),
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
                              ),
                            ],
                          );
                        }

                        var data = snapshot.data!.summary!;
                        final currentPageData = data;
                        var dataa = snapshot.data!.leases!;
                        var totaldata = snapshot.data;
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: selectedMonth.isNotEmpty
                                          ? selectedMonth
                                          : null,
                                      decoration: InputDecoration(
                                          labelText: 'Select Month'),
                                      items: months.map((String month) {
                                        return DropdownMenuItem<String>(
                                          value: month,
                                          child: Text(month),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedMonth = newValue!;
                                        });
                                        // fetchReport(); // Re-fetch on change
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: selectedYear.isNotEmpty
                                          ? selectedYear
                                          : null,
                                      decoration: InputDecoration(
                                          labelText: 'Select Year'),
                                      items: years.map((String year) {
                                        return DropdownMenuItem<String>(
                                          value: year,
                                          child: Text(year),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedYear = newValue!;
                                        });
                                        // fetchReport(); // Re-fetch on change
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Container(
                                      height: 45,
                                      width: 45,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(0),
                                        color: Colors.white,
                                      ),
                                      child: IconButton(
                                        icon:
                                            FaIcon(FontAwesomeIcons.circlePlay),
                                        onPressed: () {
                                          setState(() {
                                            int monthNumber =
                                                months.indexOf(selectedMonth) +
                                                    1;
                                            _futureRentcollection =
                                                fetchDelinquentTenantsData(
                                              monthNumber.toString(),
                                              selectedYear,
                                            );
                                          });
                                          print("Run Report");
                                        },
                                        tooltip: "Run Report",
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 45,
                                      width: 75,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(0),
                                        color: Colors.white,
                                      ),
                                      child: PopupMenuButton<String>(
                                        offset: Offset(5, 50),
                                        onSelected: handleDownload,
                                        icon: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            FaIcon(FontAwesomeIcons
                                                .download), // Your download icon
                                            SizedBox(
                                                width:
                                                    5), // Adds spacing between the icons
                                            Icon(Icons
                                                .arrow_drop_down), // The dropdown arrow icon
                                          ],
                                        ),
                                        tooltip: "Download",
                                        itemBuilder: (BuildContext context) {
                                          return downloadOptions
                                              .map((String option) {
                                            return PopupMenuItem<String>(
                                              value: option,
                                              onTap: () async {
                                                // if (option == "PDF")
                                                //   generaterentersInsurancePdf(
                                                //       snapshot.data!);
                                                // if (option == "Excel")
                                                //   generateRentersInsuranceExcel(
                                                //       snapshot.data!);
                                                // if (option == "CSV")
                                                //   generateRentersInsuranceCSV(
                                                //       snapshot.data!);
                                              },
                                              child:
                                                  Text("Download as $option"),
                                            );
                                          }).toList();
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0E0E0),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  children: [
                                    _buildTabButton("Details", 0),
                                    _buildTabButton("Summary", 1),
                                  ],
                                ),
                              ),
                              if (_selectedIndex == 0)
                                DetailScreen(data, totaldata!),
                              if (_selectedIndex == 1) SummeryScreen(dataa),
                              // Custom Tab Bar
                            ],
                          ),
                        );
                      },
                    ),
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
                  Text(
                    'No Internet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Check your internet connection',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            //    _tabController.index = index;
            _selectedIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? blueColor : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  TableRow buildTableRows(
      String leftLabel,
      String leftValue,
      String centerLabel,
      String centerValue,
      String rightLabel,
      String rightValue) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leftLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                SizedBox(height: 4.0), // Space between label and value
                Text(
                  leftValue,
                  style: TextStyle(color: grey),
                ),
              ],
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  centerLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                SizedBox(height: 4.0), // Space between label and value
                Text(
                  centerValue,
                  style: TextStyle(color: grey),
                ),
              ],
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rightLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                SizedBox(height: 4.0), // Space between label and value
                Text(
                  rightValue,
                  style: TextStyle(color: grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  DetailScreen(List<Summary> currentPageData, Rentcollection_model data) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeaders(),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
              ),
              child: Column(
                children: [
                  ...currentPageData.asMap().entries.map((entry) {
                    int rowIndex = entry.key;
                    var item = entry.value;
                    bool isRowExpanded = expandedRowIndex == rowIndex;
                    return Container(
                      decoration: BoxDecoration(
                        color: rowIndex % 2 != 0
                            ? Colors.white
                            : blueColor.withOpacity(0.09),
                        border: Border.all(
                            color: Color.fromRGBO(152, 162, 179, .5)),
                      ),
                      child: Column(
                        children: <Widget>[
                          // Row header
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
                                      setState(() {
                                        if (expandedRowIndex == rowIndex) {
                                          expandedRowIndex = null;
                                        } else {
                                          expandedRowIndex = rowIndex;
                                          nestedExpandedIndex = null;
                                        }
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 5),
                                      padding: !isRowExpanded
                                          ? const EdgeInsets.only(bottom: 10)
                                          : const EdgeInsets.only(top: 10),
                                      child: FaIcon(
                                        isRowExpanded
                                            ? FontAwesomeIcons.sortUp
                                            : FontAwesomeIcons.sortDown,
                                        size: 20,
                                        color: blueColor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${item.rentalOwnerName ?? '-'}',
                                      style: TextStyle(
                                        color: blueColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '\$${item.totalPending ?? '-'}',
                                      style: TextStyle(
                                        color: blueColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ),
                          if (isRowExpanded)
                            Container(
                                margin: const EdgeInsets.symmetric(vertical: 0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(width: 25),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Total Charged',
                                                style: TextStyle(
                                                  color: blueColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                '\$${item.totalCharged ?? '-'}',
                                                style: TextStyle(
                                                  color: grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Collected %',
                                                style: TextStyle(
                                                  color: blueColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                '\$${item.collectedPercentage ?? '-'}',
                                                style: TextStyle(
                                                  color: grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                  ],
                                )),
                        ],
                      ),
                    );
                  }).toList(),
                  Container(
                    decoration: BoxDecoration(
                      color: (currentPageData.length % 2 == 0)
                          ? blueColor.withOpacity(0.09)
                          : Colors.white,
                      border:
                          Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
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
                                // This Overall row can optionally be expandable too
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (expandedRowIndex ==
                                          currentPageData.length) {
                                        expandedRowIndex = null;
                                      } else {
                                        expandedRowIndex =
                                            currentPageData.length;
                                      }
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 5),
                                    padding: expandedRowIndex !=
                                            currentPageData.length
                                        ? const EdgeInsets.only(bottom: 10)
                                        : const EdgeInsets.only(top: 10),
                                    child: FaIcon(
                                      expandedRowIndex == currentPageData.length
                                          ? FontAwesomeIcons.sortUp
                                          : FontAwesomeIcons.sortDown,
                                      size: 20,
                                      color: blueColor,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Overall',
                                    style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '\$${data.totalSummary?.totalPending ?? '-'}',
                                    style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ),
                        if (expandedRowIndex == currentPageData.length)
                          Container(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(width: 25),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Total Charged',
                                              style: TextStyle(
                                                color: blueColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              '\$${data.totalSummary?.totalCharged ?? '-'}',
                                              style: TextStyle(
                                                color: grey,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Collected %',
                                              style: TextStyle(
                                                color: blueColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              '\$${data.totalSummary?.averageCollectedPercentage ?? '-'}',
                                              style: TextStyle(
                                                color: grey,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                ],
                              )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SummeryScreen(List<Leases> currentPageData) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeaders(),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
              ),
              child: Column(
                children: currentPageData.asMap().entries.map((entry) {
                  int rowIndex = entry.key;
                  var item = entry.value;
                  bool isRowExpanded = expandedRowIndex == rowIndex;

                  return Container(
                    decoration: BoxDecoration(
                      color: rowIndex % 2 != 0
                          ? Colors.white
                          : blueColor.withOpacity(0.09),
                      border:
                          Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
                    ),
                    child: Column(
                      children: <Widget>[
                        // Row header
                        // ListTile(
                        //   contentPadding: EdgeInsets.zero,
                        //   title: Padding(
                        //     padding: const EdgeInsets.all(2.0),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.start,
                        //       crossAxisAlignment: CrossAxisAlignment.center,
                        //       children: <Widget>[
                        //         InkWell(
                        //           onTap: () {
                        //             setState(() {
                        //               if (expandedRowIndex == rowIndex) {
                        //                 expandedRowIndex = null;
                        //               } else {
                        //                 expandedRowIndex = rowIndex;
                        //                 nestedExpandedIndex = null; // reset inner when switching rows
                        //               }
                        //             });
                        //           },
                        //           child: Container(
                        //             margin: const EdgeInsets.only(left: 5),
                        //             padding: !isRowExpanded ? const EdgeInsets.only(bottom: 10) : const EdgeInsets.only(top: 10),
                        //             child: FaIcon(
                        //               isRowExpanded ? FontAwesomeIcons.sortUp : FontAwesomeIcons.sortDown,
                        //               size: 20,
                        //               color: blueColor,
                        //             ),
                        //           ),
                        //         ),
                        //         SizedBox(width: 8),
                        //         Expanded(
                        //           child: Text(
                        //             '${item.leaseData. ?? '-'}',
                        //             style: TextStyle(
                        //               color: blueColor,
                        //               fontWeight: FontWeight.bold,
                        //               fontSize: 14,
                        //             ),
                        //           ),
                        //         ),
                        //         SizedBox(width: 8),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        //
                        // // Outer expanded section
                        // if (isRowExpanded)
                        //   Container(
                        //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                        //     decoration: BoxDecoration(
                        //       border: Border(top: BorderSide(color: Colors.grey.shade400)),
                        //     ),
                        //     child: Column(
                        //       children: item.activeLeases?.asMap().entries.map((leaseEntry) {
                        //         int leaseIndex = leaseEntry.key;
                        //         ActiveLeases lease = leaseEntry.value;
                        //         bool isLeaseExpanded = expandedLeaseIndex == leaseIndex;
                        //         bool isLeaseIndexExpanded = expandedLeaseTotalIndex == leaseIndex;
                        //
                        //         return Column(
                        //           children: [
                        //             Container(
                        //               margin: const EdgeInsets.symmetric(vertical: 0),
                        //               child: ListTile(
                        //                 contentPadding: EdgeInsets.zero,
                        //                 onTap: () {
                        //                   setState(() {
                        //                     if (expandedLeaseIndex == leaseIndex) {
                        //                       expandedLeaseIndex = null;
                        //                     } else {
                        //                       expandedLeaseIndex = leaseIndex;
                        //                     }
                        //                   });
                        //                 },
                        //                 title: Row(
                        //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //                   children: [
                        //                     InkWell(
                        //                       onTap: () {
                        //                         setState(() {
                        //                           if (expandedLeaseIndex == leaseIndex) {
                        //                             expandedLeaseIndex = null;
                        //                           } else {
                        //                             expandedLeaseIndex = leaseIndex;
                        //                           }
                        //                         });
                        //                       },
                        //                       child: Container(
                        //                         margin: const EdgeInsets.only(left: 5),
                        //                         padding: !isLeaseExpanded ? const EdgeInsets.only(bottom: 10) : const EdgeInsets.only(top: 10),
                        //                         child: FaIcon(
                        //                           isLeaseExpanded ? FontAwesomeIcons.sortUp : FontAwesomeIcons.sortDown,
                        //                           size: 20,
                        //                           color: blueColor,
                        //                         ),
                        //                       ),
                        //                     ),
                        //                     SizedBox(width: 8),
                        //                     Expanded(
                        //                         child: Text(
                        //                           "${lease.unit?.rentalUnit ?? '-'}",
                        //                           style: TextStyle(
                        //                             color: blueColor,
                        //                             fontWeight: FontWeight.bold,
                        //                             fontSize: 14,
                        //                           ),
                        //                         )),
                        //                     Expanded(
                        //                         child: Text(
                        //                           "${lease.leaseStart ?? '-'}",
                        //                           style: TextStyle(
                        //                             color: blueColor,
                        //                             fontWeight: FontWeight.bold,
                        //                             fontSize: 14,
                        //                           ),
                        //                         )),
                        //                     Expanded(
                        //                         child: Text(
                        //                           "${lease.leaseEnd ?? '-'}",
                        //                           style: TextStyle(
                        //                             color: blueColor,
                        //                             fontWeight: FontWeight.bold,
                        //                             fontSize: 14,
                        //                           ),
                        //                         )),
                        //                   ],
                        //                 ),
                        //               ),
                        //             ),
                        //             if (isLeaseExpanded)
                        //               Row(
                        //                 children: [
                        //                   Expanded(
                        //                     child: Table(
                        //                       columnWidths: {
                        //                         // 0: FixedColumnWidth(150.0), // Adjust width as needed
                        //                         // 1: FlexColumnWidth(),
                        //                         0: FlexColumnWidth(), // Distribute columns equally
                        //                         1: FlexColumnWidth(),
                        //                         2: FlexColumnWidth(),
                        //                       },
                        //                       children: [
                        //                         buildTableRows(
                        //                           'Rent start',
                        //                           getDisplayValue("${lease.leaseStart}"),
                        //                           'Rent Cycle',
                        //                           getDisplayValue(lease.rentCycle),
                        //                           'Credits',
                        //                           getDisplayValue("\$${lease.creditAmount!.toStringAsFixed(2)}"),
                        //                         ),
                        //                         buildTableRows(
                        //                           'Bed/Bath',
                        //                           getDisplayValue("${lease.unit!.bedBath}"),
                        //                           'Prepayments',
                        //                           getDisplayValue("\$${lease.prepayments!.toStringAsFixed(2)}"),
                        //                           'Charges',
                        //                           getDisplayValue("\$${lease.chargeAmount!.toStringAsFixed(2)}"),
                        //                         ),
                        //                         buildTableRows(
                        //                           'Total',
                        //                           getDisplayValue("\$${lease.chargeTotal!.toStringAsFixed(2)}"),
                        //                           'Balance Due',
                        //                           getDisplayValue("\$${lease.balanceDue!.toStringAsFixed(2)}"),
                        //                           'Rent',
                        //                           getDisplayValue("\$${lease.rentAmount!.toStringAsFixed(2)}"),
                        //                         ),
                        //                         buildTableRows(
                        //                           'Deposit Held',
                        //                           getDisplayValue("\$${lease.depositHeld ?? "0.0"}"),
                        //                           'Tenants',
                        //                           getDisplayValue(lease.tenants!.map((tenant) => "${tenant.tenantFirstName ?? ''} ${tenant.tenantLastName ?? ''}".trim()).join(", ")),
                        //                           '',
                        //                           "",
                        //                         )
                        //                       ],
                        //                     ),
                        //                   ),
                        //                 ],
                        //               ),
                        //             Container(
                        //               decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade500))),
                        //               child: ListTile(
                        //                 contentPadding: EdgeInsets.zero,
                        //                 title: Padding(
                        //                   padding: const EdgeInsets.all(2.0),
                        //                   child: Row(
                        //                     mainAxisAlignment: MainAxisAlignment.start,
                        //                     crossAxisAlignment: CrossAxisAlignment.center,
                        //                     children: <Widget>[
                        //                       InkWell(
                        //                         onTap: () {
                        //                           setState(() {
                        //                             if (expandedLeaseTotalIndex == leaseIndex) {
                        //                               expandedLeaseTotalIndex = null;
                        //                             } else {
                        //                               expandedLeaseTotalIndex = leaseIndex;
                        //                             }
                        //                           });
                        //                         },
                        //                         child: Container(
                        //                           margin: const EdgeInsets.only(left: 5),
                        //                           padding: !isLeaseIndexExpanded ? const EdgeInsets.only(bottom: 10) : const EdgeInsets.only(top: 10),
                        //                           child: FaIcon(
                        //                             isLeaseIndexExpanded ? FontAwesomeIcons.sortUp : FontAwesomeIcons.sortDown,
                        //                             size: 20,
                        //                             color: blueColor,
                        //                           ),
                        //                         ),
                        //                       ),
                        //                       SizedBox(width: 8),
                        //                       Expanded(
                        //                         child: Text(
                        //                           'Total For ${item.rentalAddress ?? '-'}',
                        //                           style: TextStyle(
                        //                             color: blueColor,
                        //                             fontWeight: FontWeight.bold,
                        //                             fontSize: 14,
                        //                           ),
                        //                         ),
                        //                       ),
                        //                       SizedBox(width: 8),
                        //                     ],
                        //                   ),
                        //                 ),
                        //               ),
                        //             ),
                        //             if (isLeaseIndexExpanded)
                        //               Row(
                        //                 children: [
                        //                   Expanded(
                        //                     child: Table(
                        //                       columnWidths: {
                        //                         // 0: FixedColumnWidth(150.0), // Adjust width as needed
                        //                         // 1: FlexColumnWidth(),
                        //                         0: FlexColumnWidth(), // Distribute columns equally
                        //                         1: FlexColumnWidth(),
                        //                         2: FlexColumnWidth(),
                        //                       },
                        //                       children: [
                        //                         buildTableRows(
                        //                           'Credits',
                        //                           getDisplayValue("\$${item.totals!.totalCredits!.toStringAsFixed(2)}"),
                        //                           'Prepayments',
                        //                           getDisplayValue("\$${item.totals!.totalPrepayments!.toStringAsFixed(2)}"),
                        //                           'Charges',
                        //                           getDisplayValue("\$${item.totals!.totalCharges!.toStringAsFixed(2)}"),
                        //                         ),
                        //                         buildTableRows(
                        //                           'Total',
                        //                           getDisplayValue("\$${item.totals!.totalAmount!.toStringAsFixed(2)}"),
                        //                           'Balance Due',
                        //                           getDisplayValue("\$${item.totals!.totalBalanceDue!.toStringAsFixed(2)}"),
                        //                           'Rent',
                        //                           getDisplayValue("\$${item.totals!.totalRent!.toStringAsFixed(2)}"),
                        //                         ),
                        //                         buildTableRows(
                        //                           'Deposit Held',
                        //                           getDisplayValue("\$${item.totals!.totalDeposits!.toStringAsFixed(2)}"),
                        //                           '',
                        //                           "",
                        //                           '',
                        //                           "",
                        //                         ),
                        //                       ],
                        //                     ),
                        //                   ),
                        //                 ],
                        //               ),
                        //           ],
                        //         );
                        //       }).toList() ??
                        //           [const Text("No Active Leases")],
                        //     ),
                        //   )
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
