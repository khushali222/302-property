import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/StaffModule/screen/Leasing/RentalRoll/Document_Rental/pdf_view.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';

import '../../../../../constant/constant.dart';
import '../../../../../widgets/CustomTableShimmer.dart';
import 'Add_DocumentRental.dart';

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
  reloadScreen(){
    setState(() {
      _futureRentersInsurance = fetchRentersInsuranceData();
    });
  }
  void _showDeleteAlert(BuildContext context, String id) {
    TextEditingController reason = TextEditingController();
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Do You want to delete this document?",
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
            await deleteNote(noteid: id);
            reloadScreen();
          },
          color: blueColor,
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
  Future<Map<String, dynamic>> deleteNote({
    required String noteid,
  }) async {
    try {
      final Uri uri = Uri.parse('$Api_url/api/lease-document/delete-document/$noteid');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? adminid = prefs.getString('adminId');
      String? id = prefs.getString("staff_id");
      final http.Response response = await http.delete(
        uri,
        headers: <String, String>{
          "authorization": "CRM $token",
          "id": "CRM $id",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({}),
      );

      var responseData = json.decode(response.body);
      print(response.body);
      // print(renters_insurance_id);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: responseData["message"]);
        Navigator.of(context).pop();
        return json.decode(response.body);
      } else {
        Fluttertoast.showToast(msg: responseData["message"]);
        throw Exception('Failed to delete Insurance');
      }
    } catch (e) {
      throw Exception('Failed to delete Insurance: $e');
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
          color: const Color(0xFFF4F8FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDBE0E5))),
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
              child: Row(
                children: [
                  Text(" Document\nType",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: blueColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  SizedBox(width: 5),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Text("    Document\n    Name",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: blueColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
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
                          ?  Text("           Date ",
                          style: TextStyle(
                              color: blueColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15
                          ))
                          :  Text("           Date ",
                          style:
                          TextStyle(color: blueColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
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
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          SizedBox(height: 10,),
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
                  final result = await Navigator.of(context)
                      .push(MaterialPageRoute(
                      builder: (context) => AddDocument(
                        leaseId: widget.leaseId,
                      )));
                  if (result == true) {
                    setState(() {
                      _futureRentersInsurance = fetchRentersInsuranceData();
                      //  futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
                    });
                  }
                },
                child: Container(
                  height: (MediaQuery.of(context).size.width < 500)
                      ? 38
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
                width: 5,
              ),
            ],
          ),
          SizedBox(height: 5,),
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
                  padding: const EdgeInsets.only(left: 4,right: 4),
                  child: Column(
                    children: [
                      const SizedBox(height: 5),
                      _buildHeaders(),
                      const SizedBox(height: 10),
                      Container(
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
                              margin: const EdgeInsets.symmetric(
                                  vertical: 6),
                              decoration: BoxDecoration(
                                color: rowIndex % 2 != 0
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
                                          SizedBox(width: 2),
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
                                            flex: 2,
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
                                          SizedBox(width: 20),
                                          Expanded(
                                            flex: 0,
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
                                          SizedBox(width: 10),
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
                                                    size: 40,
                                                    color: Colors
                                                        .transparent,
                                                  ),
                                                  Expanded(
                                                    child: Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                            'Created By : ',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight
                                                                    .bold,
                                                                color:
                                                                grey), // Bold and black
                                                          ),
                                                          TextSpan(
                                                            text:
                                                            '${item["adminDetails"]["first_name"]} ${item["adminDetails"]["last_name"]}',
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
                                              SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .end,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      // print("calling");
                                                      // print( "${image_url}${item["document_name"]}");
                                                      // const PDF().fromUrl(
                                                      //  "${image_url}${item["document_name"]}",
                                                      //   placeholder: (double progress) => Center(child: Text('$progress %')),
                                                      //   errorWidget: (dynamic error) => Center(child: Text(error.toString())),
                                                      // );
                                                      // String pdfUrl =
                                                      //     "${image_url}${item["document_name"]}";
                                                      // print(
                                                      //     "Opening PDF: $pdfUrl");
                                                      // Navigator.push(
                                                      //   context,
                                                      //   MaterialPageRoute(
                                                      //     builder: (context) =>
                                                      //         PDFViewerScreen(
                                                      //             pdfUrl:
                                                      //             pdfUrl),
                                                      //   ),
                                                      // );
                                                      // showPdfDialog(context, pdfUrl);
                                                    },
                                                    child:
                                                    Container(
                                                      height: 35,
                                                      width: 35,
                                                      decoration:
                                                      BoxDecoration(
                                                        color: Colors
                                                            .grey
                                                            .shade200,
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            8),
                                                      ),
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
                                                                .eye,
                                                            size: 15,
                                                            color: Colors
                                                                .black,
                                                          ),
                                                          SizedBox(
                                                              width: 2),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  GestureDetector(
                                                    onTap: () {
                                                      // print("calling");
                                                      // print( "${image_url}${item["document_name"]}");
                                                      // const PDF().fromUrl(
                                                      //  "${image_url}${item["document_name"]}",
                                                      //   placeholder: (double progress) => Center(child: Text('$progress %')),
                                                      //   errorWidget: (dynamic error) => Center(child: Text(error.toString())),
                                                      // );
                                                      _showDeleteAlert(context,item["document_id"] );
                                                      // showPdfDialog(context, pdfUrl);
                                                    },
                                                    child:
                                                    Container(
                                                      height: 35,
                                                      width: 35,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              8),
                                                          color: Colors
                                                              .red
                                                              .shade50),
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
                                                            size: 15,
                                                            color: Colors
                                                                .red,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 15),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 15,
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
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    try {
      final response = await http.get(
          Uri.parse('$Api_url/api/lease-document/get-documents/$leaseid'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
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
