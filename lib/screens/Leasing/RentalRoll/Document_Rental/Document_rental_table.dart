import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../../constant/constant.dart';
import '../../../../provider/dateProvider.dart';
import '../../../../widgets/CustomTableShimmer.dart';

class DocumentRentalTable extends StatefulWidget {
  String leaseId;
   DocumentRentalTable({super.key, required this.leaseId});

  @override
  State<DocumentRentalTable> createState() => _DocumentRentalTableState();
}

class _DocumentRentalTableState extends State<DocumentRentalTable> {

  late Future<List<Map<String,dynamic>>> _futureRentersInsurance;
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String searchvalue = "";
  String? selectedValue;
  bool isLoading = true;
  String? errorMessage;
  int? expandedRowIndex;

  int totalrecords = 0;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  int currentPage = 0;
  int itemsPerPage = 10;
  List<int> itemsPerPageOptions = [10, 25, 50, 100];
  List<Map<String,dynamic>> rentersInsuranceModel = [];
  void _changeRowsPerPage(int selectedRowsPerPage) {
    setState(() {
      _rowsPerPage = selectedRowsPerPage;
      _currentPage = 0; // Reset to the first page when changing rows per page
    });
  }



  Future<List<Map<String,dynamic>>> fetchRentersInsuranceData() async {
   // RentersInsuranceService service = RentersInsuranceService();
    try {
      List<Map<String,dynamic>> data =
      await fetchDocumentRental(widget.leaseId);
      setState(() {
        rentersInsuranceModel = data;
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
      return [];
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futureRentersInsurance = fetchRentersInsuranceData();
  }

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

        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: const Icon(
                Icons.expand_less,
                color: Colors.transparent,
              ),
            ),
            const Expanded(
              child: Row(
                children: [
                  Text("Document \n Type",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white,fontSize: 15)),
                  SizedBox(width: 5),

                ],
              ),
            ),
            const Expanded(
              child: Row(
                children: [
                  Text("Document \n Name",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white,fontSize: 15)),
                  SizedBox(width: 5),

                ],
              ),
            ),

            Expanded(
              child: InkWell(

                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Row(
                    children: [
                      width < 400
                          ? const Text("        Date",
                          style: TextStyle(color: Colors.white ,fontSize: 15,))
                          : const Text("       Date",
                          style: TextStyle(color: Colors.white,fontSize: 15)),
                      // Text("Property", style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 3),

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


  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Spacer(),
              GestureDetector(
                onTap: () async {
                  // Provider.of<SelectedTenantsProvider>(context,
                  //     listen: false)
                  //     .clearTenant();
                  // Provider.of<SelectedCosignersProvider>(context,
                  //     listen: false)
                  //     .clearCosigner();
                  // Provider.of<SelectedApplicantProvider>(context,
                  //     listen: false)
                  //     .clearApplicant();
                  // final result = await Navigator.of(context)
                  //     .push(MaterialPageRoute(
                  //     builder: (context) => LeaseAddRentersInsurance(
                  //       tenantid: widget.tenantId,
                  //       leaseId: widget.leaseId,
                  //     )));
                  // if (result == true) {
                  //   setState(() {
                  //     _futureRentersInsurance =
                  //         RentersInsuranceService()
                  //             .fetchRentersInsurance(widget.leaseId);
                  //     //  futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
                  //   });
                  // }
                },
                child: Container(
                  height: (MediaQuery.of(context).size.width < 500)
                      ? 35
                      : MediaQuery.of(context).size.width * 0.063,
                  width: (MediaQuery.of(context).size.width < 500)
                      ? MediaQuery.of(context).size.width * 0.35
                      : MediaQuery.of(context).size.width * 0.2,
                  decoration: BoxDecoration(
                    color: blueColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      "+ Add Document",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize:
                        MediaQuery.of(context).size.width < 500
                            ? 14
                            : 22,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 7,
              ),
            ],
          ),

          FutureBuilder<List<Map<String,dynamic>>>(
            future: _futureRentersInsurance,
            builder: (context, snapshot) {
              if (isLoading) {
                return Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: ColabShimmerLoadingWidget(),
                );
              } else if (snapshot.hasError) {
                return Center(
                    child: Text(errorMessage ?? 'Unknown error'));
              } else if (!snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return Container(
                  height: MediaQuery.of(context).size.height * .45,
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
              }

              var data = snapshot.data!;

              // Apply filtering based on selectedValue and searchValue


              // Pagination logic
              final totalPages = (data.length / itemsPerPage).ceil();
              final currentPageData = data
                  .skip(currentPage * itemsPerPage)
                  .take(itemsPerPage)
                  .toList();

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Column(
                    children: [
                      _buildHeaders(),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Color.fromRGBO(
                                    152, 162, 179, .5))),
                        // decoration: BoxDecoration(
                        //     border: Border.all(color: blueColor)),
                        child: Column(
                          children: currentPageData
                              .asMap()
                              .entries
                              .map((entry) {
                            int rowIndex = entry.key;
                            var item = entry.value;
                            bool isRowExpanded =
                                expandedRowIndex == rowIndex;

                            return Container(
                              decoration: BoxDecoration(
                                color: rowIndex % 2 != 0
                                    ? Colors.white
                                    : blueColor.withOpacity(0.09),
                                border: Border.all(
                                    color: Color.fromRGBO(
                                        152, 162, 179, .5)),
                              ),
                              // decoration: BoxDecoration(
                              //   border: Border.all(color: blueColor),
                              // ),
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
                                                if (expandedRowIndex ==
                                                    rowIndex) {
                                                  expandedRowIndex =
                                                  null;
                                                } else {
                                                  expandedRowIndex =
                                                      rowIndex;
                                                }
                                              });
                                            },
                                            child: Container(
                                              margin: const EdgeInsets
                                                  .only(left: 5),
                                              padding: !isRowExpanded
                                                  ? const EdgeInsets
                                                  .only(
                                                  bottom: 10)
                                                  : const EdgeInsets
                                                  .only(top: 10),
                                              child: FaIcon(
                                                isRowExpanded
                                                    ? FontAwesomeIcons
                                                    .sortUp
                                                    : FontAwesomeIcons
                                                    .sortDown,
                                                size: 20,
                                                color: blueColor,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex:
                                            3, // Larger size for the first field
                                            child: Padding(
                                              padding:
                                              const EdgeInsets
                                                  .only(
                                                  left: 8.0),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (expandedRowIndex ==
                                                        rowIndex) {
                                                      expandedRowIndex =
                                                      null;
                                                    } else {
                                                      expandedRowIndex =
                                                          rowIndex;
                                                    }
                                                  });
                                                },
                                                child: Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                        '${item["file_type"] ?? '-'}',
                                                        style:
                                                        TextStyle(
                                                          color:
                                                          blueColor,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize:
                                                          13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 30),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                             "${item["file_name"]}",
                                              style: TextStyle(
                                                color: blueColor,
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 25),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                            "${dateProvider.formatCurrentDate(item["date_created"])}",
                                              style: TextStyle(
                                                color: blueColor,
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isRowExpanded)
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: 2, right: 2),
                                      margin:
                                      EdgeInsets.only(bottom: 2),
                                      child: SingleChildScrollView(
                                        child: Container(
                                          //color: Colors.blue,
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .start,
                                                children: [
                                                  FaIcon(
                                                    isRowExpanded
                                                        ? FontAwesomeIcons
                                                        .sortUp
                                                        : FontAwesomeIcons
                                                        .sortDown,
                                                    size: 50,
                                                    color: Colors
                                                        .transparent,
                                                  ),
                                                  Expanded(
                                                    child: Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                            'Created By : ${item["adminDetails"]["first_name"]} ${item["adminDetails"]["last_name"]}',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight
                                                                    .bold,
                                                                color:
                                                                blueColor), // Bold and black
                                                          ),

                                                        ],
                                                      ),
                                                    ),
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
                                      : blueColor,
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
                                      ? blueColor
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<List<Map<String,dynamic>>> fetchDocumentRental( String leaseid) async {
    print('entry');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');
    try {
      final response = await http.get(
          Uri.parse('$Api_url/api/lease-document/get-documents/$leaseid'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $adminId",
          });

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON

        final parsedJson = jsonDecode(response.body);
        print(parsedJson);
        // Check if 'data' exists and is a list
        if (parsedJson['documents'] != null && parsedJson['documents'] is List) {
          return List<Map<String, dynamic>>.from(parsedJson['documents']);
        } else {
          return []; // Return an empty list instead of null
        }
       // return leasesJson.map((data) => Map<String,dynamic>.fromJson(data)).toList();
      } else {
        // If the server did not return a 200 OK response, throw an exception
        throw Exception('Failed to load renters insurance');
      }
    } catch (e) {
      // Handle any other exceptions
      print('Error fetching data: $e');
      return [];
    }
  }
}
