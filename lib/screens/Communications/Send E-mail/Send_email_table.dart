import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:three_zero_two_property/widgets/CustomTableShimmer.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import 'package:html/parser.dart' as htmlParser;
import '../../../Model/Comunication_model/Send_email_table.dart';
import '../../../Model/Comunication_model/email_logtable.dart';
import '../../../constant/constant.dart';
import '../../../provider/dateProvider.dart';
import '../../../repository/Communication/Email_log_repo.dart';
import '../../../repository/Communication/Send_email_repo.dart';
import '../../../widgets/custom_drawer.dart';
import 'send_mail.dart';

class Send_Email_table extends StatefulWidget {
  @override
  _Send_Email_tableState createState() => _Send_Email_tableState();
}

class _Send_Email_tableState extends State<Send_Email_table> {
  int totalrecords = 0;
  //Future<List<Emailss>>? futureEmailss;
  Future<Send_email_table>? futureEmailss;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  int currentPage = 1;
  int itemsPerPage = 10;
  List<int> itemsPerPageOptions = [
    10,
    25,
    50,
    100,
  ]; // Options for items per page

  void sortData(List<Emailss> data) {
    if (sorting1) {
      data.sort((a, b) => ascending1
          ? a.subject!.compareTo(b.subject!)
          : b.subject!.compareTo(a.subject!));
    } else if (sorting2) {
      data.sort((a, b) => ascending2
          ? a.subject!.compareTo(b.subject!)
          : b.subject!.compareTo(a.subject!));
    } else if (sorting3) {
      data.sort((a, b) => ascending3
          ? a.createdAt!.compareTo(b.createdAt!)
          : b.createdAt!.compareTo(a.createdAt!));
    }
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
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
          color: Color(0xFFF4F8FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFFDBE0E5))),
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
                        ? Text(" Subject",
                            style: TextStyle(
                                color: blueColor, fontWeight: FontWeight.bold))
                        : Text(" Subject",
                            style: TextStyle(
                                color: blueColor, fontWeight: FontWeight.bold)),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                    // SizedBox(width: 3),
                    // ascending1
                    //     ? Padding(
                    //   padding: const EdgeInsets.only(top: 7, left: 2),
                    //   child: FaIcon(
                    //     FontAwesomeIcons.sortUp,
                    //     size: 20,
                    //     color: Colors.white,
                    //   ),
                    // )
                    //     : Padding(
                    //   padding: const EdgeInsets.only(bottom: 7, left: 2),
                    //   child: FaIcon(
                    //     FontAwesomeIcons.sortDown,
                    //     size: 20,
                    //     color: Colors.white,
                    //   ),
                    // ),
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
                    Text("     Sent",
                        style: TextStyle(
                            color: blueColor, fontWeight: FontWeight.bold)),
                    SizedBox(width: 3),
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

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectivityResult = result;
        if (_connectivityResult != ConnectivityResult.none)
          futureEmailss =
              SendemailRepository().fetchSendEmailTable(limit: 10, page: 1);
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
      futureEmailss = SendemailRepository().fetchSendEmailTable();
  }

  bool _errorText = false;
  void _showAlert(BuildContext context, String id, Emailss data) {
    String searchValue = ""; // Local state for search value

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Section
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: blueColor,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(10)),
                    ),
                    child: Center(
                      child: Row(
                        children: [
                          SizedBox(width: 15),
                          Text(
                            "Email Recipients Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.close, color: Colors.white),
                          ),
                          SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    child: TextField(
                      style: TextStyle(fontSize: 15),
                      onChanged: (value) {
                        setState(() {
                          searchValue =
                              value.toLowerCase(); // ✅ Update search value
                        });
                      },
                      cursorColor: blueColor,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF8A95A8)),
                        ),
                        hintText: "Search recipients...",
                        hintStyle: TextStyle(color: Color(0xFF8A95A8)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  // Emails List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    border:
                                        Border.all(color: Color(0xFF8A95A8)),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: data.to!
                                          .where((email) => email
                                              .toLowerCase()
                                              .contains(searchValue))
                                          .map((email) {
                                        List<String?> openedEmails = data.opens!
                                            .map(
                                                (openData) => openData.openedBy)
                                            .toList();

                                        // Debugging prints
                                        print("Checking email: $email");
                                        print("Accepted: ${data.accepted}");
                                        print("Opened: $openedEmails");

                                        bool isAccepted =
                                            data.accepted!.contains(email);
                                        bool isOpened =
                                            openedEmails.contains(email);

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Row(
                                            children: [
                                              // Text(
                                              //   email,
                                              //   style: TextStyle(
                                              //     fontWeight: FontWeight.bold,
                                              //     color: blueColor,
                                              //   ),
                                              // ),
                                              // Spacer(), // Push icon to the right
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  email,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: blueColor,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              if (isAccepted && isOpened)
                                                Icon(Icons.done_all,
                                                    color: Colors.green)
                                              else if (isAccepted)
                                                Icon(Icons.check,
                                                    color: Colors.green)
                                              else
                                                Icon(Icons.close,
                                                    color: Colors.red)
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // Total Recipients
                        Row(
                          children: [
                            Text(
                              "Total Recipients  : ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: blueColor,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "${data.to?.length ?? 0}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: blueColor,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteAlert(BuildContext context, String id) {
    TextEditingController reason = TextEditingController();
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc:
          "Once deleted, you will not be able to recover this e-mail history!",
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
                hintText: 'Enter reason for deletion',
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
              var data = await SendemailRepository()
                  .DeleteSendMail(email_id: id, reason: reason.text);
              // Add your delete logic here
              if (data != null)
                setState(() {
                  futureEmailss = SendemailRepository().fetchSendEmailTable();
                });
              Navigator.pop(context);
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

  Widget _buildField(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: blueColor),
          ),
          SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200], // Light background like input field
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 14, color: grey, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String title, String value, Color textColor) {
    return TableRow(
      children: [
        Padding(
          padding: EdgeInsets.all(4.0),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: blueColor),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(4.0),
          child: Text(
            value,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: grey),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  List<Emailss> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<Emailss> get _pagedData {
    int startIndex = _currentPage * _rowsPerPage;
    int endIndex = startIndex + _rowsPerPage;
    return _tableData.sublist(startIndex,
        endIndex > _tableData.length ? _tableData.length : endIndex);
  }

  void _changeRowsPerPage(int selectedRowsPerPage) {
    setState(() {
      _rowsPerPage = selectedRowsPerPage;
      _currentPage = 0; // Reset to the first page when changing rows per page
    });
  }

  void _sort<T>(Comparable<T> Function(Emailss d) getField, int columnIndex,
      bool ascending) {
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

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(Emailss d)? getField) {
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

  Widget _buildDataCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 16),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildPaginationControls() {
    int numorpages = 1;
    numorpages = (totalrecords / _rowsPerPage).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Text('Rows per page: '),
        // SizedBox(width: 10),
        Material(
          elevation: 2,
          color: Colors.white,
          child: Container(
            height: 55,
            padding: EdgeInsets.symmetric(horizontal: 12.0),
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
                    _changeRowsPerPage(newValue);
                  }
                },
                icon: Icon(
                  Icons.arrow_drop_down,
                  size: 40,
                ),
                style: TextStyle(color: Colors.black, fontSize: 17),
                dropdownColor: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.circleChevronLeft,
            size: 30,
            color: _currentPage == 0 ? Colors.grey : blueColor,
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
          'Page ${_currentPage + 1} of $numorpages',
          style: TextStyle(fontSize: 18),
        ),
        IconButton(
          icon: FaIcon(
            size: 30,
            FontAwesomeIcons.circleChevronRight,
            color: (_currentPage + 1) * _rowsPerPage >= _tableData.length
                ? Colors.grey
                : blueColor, // Change color based on availability
          ),
          onPressed: (_currentPage + 1) * _rowsPerPage >= _tableData.length
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

  ConnectivityResult? _connectivityResult;
  final _scrollController = ScrollController();
  String extractText(String htmlString) {
    var document = htmlParser.parse(htmlString);
    return document.body?.text.trim().replaceAll(RegExp(r'\s+'), ' ') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    //final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
       // currentpage: "Send E-mail",
        currentpage: "E-mail Logs",
        dropdown: true,
      ),
      body: _connectivityResult != ConnectivityResult.none
          ? SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  // Header Section with Title and Add Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        if (MediaQuery.of(context).size.width > 500)
                          SizedBox(
                            width: 13,
                          ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: titleBar(
                              width: double.infinity,
                             // title: 'Emails',
                             title: "E-mail Logs",
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: GestureDetector(
                              onTap: () async {
                                final result = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => send_email()));
                                if (result == true) {
                                  setState(() {
                                    futureEmailss = SendemailRepository()
                                        .fetchSendEmailTable(
                                            limit: 10, page: 1);
                                  });
                                }
                              },
                              child: Container(
                                height:
                                    (MediaQuery.of(context).size.width < 768)
                                        ? 50
                                        : 60,
                                decoration: BoxDecoration(
                                  color: blueColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Center(
                                  child: Text(
                                    " Send\n Email",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (MediaQuery.of(context).size.width < 500)
                          SizedBox(width: 3),
                        if (MediaQuery.of(context).size.width > 500)
                          SizedBox(width: 18),
                      ],
                    ),
                  ),

                  // if (MediaQuery.of(context).size.width < 500)
                  Padding(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width < 500 ? 15 : 28),
                    child: FutureBuilder<Send_email_table>(
                      future: futureEmailss,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ColabShimmerLoadingWidget(); // Show loading indicator
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(snapshot.error
                                .toString()), // Show error message from API
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data == null ||
                            snapshot.data!.emails == null ||
                            snapshot.data!.emails!.isEmpty) {
                          // If no emails or 204 response, show "No Data Available" in table
                          return Container(
                            height: MediaQuery.of(context).size.height * .5,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // No email icon
                                  SizedBox(height: 10),
                                  Text(
                                    "No Emails Available",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: blueColor,
                                      fontSize: 16,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        } else {
                          var data = snapshot.data!.emails!;
                          print("data send mail ${data.length}");

                          final totalPages =
                              (snapshot.data!.totalEmails! / itemsPerPage)
                                  .ceil();
                          final currentPageData = data;
                          //     .skip(currentPage * itemsPerPage)
                          //     .take(itemsPerPage)
                          //     .toList();
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildHeaders(),
                                SizedBox(height: 10),
                                Container(
                                  // decoration: BoxDecoration(
                                  //     border: Border.all(
                                  //         color: Color.fromRGBO(
                                  //             152, 162, 179, .5))),
                                  // decoration: BoxDecoration(
                                  //     border: Border.all(color: blueColor)),
                                  child: Column(
                                    children: currentPageData
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      int index = entry.key;
                                      bool isExpanded = expandedIndex == index;
                                      Emailss Propertytype = entry.value;

                                      //return CustomExpansionTile(data: Propertytype, index: index);
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (expandedIndex == index) {
                                              expandedIndex = null;
                                            } else {
                                              expandedIndex = index;
                                            }
                                          });
                                        },
                                        child: Container(
                                          // decoration: BoxDecoration(
                                          //   color: index % 2 != 0
                                          //       ? Colors.white
                                          //       : blueColor.withOpacity(0.09),
                                          //   border: Border.all(
                                          //       color: Color.fromRGBO(
                                          //           152, 162, 179, .5)),
                                          // ),
                                          // decoration: BoxDecoration(
                                          //   border: Border.all(color: blueColor),
                                          // ),
                                          margin:
                                              EdgeInsets.symmetric(vertical: 6),
                                          decoration: BoxDecoration(
                                            color: index % 2 != 0
                                                ? Color(0xFFF4F8FF)
                                                : Colors.white,
                                            border: Border.all(
                                                color: Color(0xFFDBE0E5)),
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
                                                        CrossAxisAlignment
                                                            .center,
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
                                                              expandedIndex =
                                                                  null;
                                                            } else {
                                                              expandedIndex =
                                                                  index;
                                                            }
                                                          });
                                                        },
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 5,
                                                                  right: 5),
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
                                                            size: 20,
                                                            color: blueColor,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 3,
                                                        child: InkWell(
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
                                                          child: Text(
                                                            Propertytype
                                                                    .subject!
                                                                    .isNotEmpty
                                                                ? '${Propertytype.subject}'
                                                                : 'N/A',
                                                            style: TextStyle(
                                                              color: blueColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .099),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                          // '${widget.data.createdAt}',
                                                          // formatDate(
                                                          //     '${Propertytype.createdAt}'),
                                                          Propertytype
                                                                  .createdAt!
                                                                  .isNotEmpty
                                                              ? dateProvider
                                                                  .formatCurrentDateTime(
                                                                      '${Propertytype.createdAt}')
                                                              : 'Not Sent',

                                                          style: TextStyle(
                                                            color: blueColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (isExpanded)
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 2.0),
                                                  margin: EdgeInsets.only(
                                                      bottom: 2),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      children: [
                                                        SizedBox(
                                                          height: 7,
                                                        ),
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
                                                              size: 23,
                                                              color: Colors
                                                                  .transparent,
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <Widget>[
                                                                  Text.rich(
                                                                    TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                              'Reply to : ',
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: blueColor), // Bold and black
                                                                        ),
                                                                        TextSpan(
                                                                          // text: formatDate(
                                                                          //     '${Propertytype.updatedAt}'),
                                                                          text: Propertytype.from!.isNotEmpty
                                                                              ? Propertytype.from
                                                                              : 'N/A',

                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.w700,
                                                                              color: grey), // Light and grey
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Text.rich(
                                                                    TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                              'Body : ',
                                                                          style:
                                                                              TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color:
                                                                                blueColor, // Bold and black
                                                                          ),
                                                                        ),
                                                                        TextSpan(
                                                                          text: Propertytype.body!.isNotEmpty
                                                                              ? extractText(Propertytype.body!)
                                                                              : 'N/A',
                                                                          style:
                                                                              TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                            color:
                                                                                grey, // Light and grey
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    maxLines:
                                                                        1, // Restrict to 2 lines
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis, // Show "..." if the text is too long
                                                                  ),
                                                                  SizedBox(
                                                                    height: 15,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            FaIcon(
                                                              isExpanded
                                                                  ? FontAwesomeIcons
                                                                      .sortUp
                                                                  : FontAwesomeIcons
                                                                      .sortDown,
                                                              size: 25,
                                                              color: Colors
                                                                  .transparent,
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  _showDeleteAlert(
                                                                      context,
                                                                      Propertytype
                                                                          .emailId!);
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .red,
                                                                        width:
                                                                            1.5),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
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
                                                                            .trashCan,
                                                                        size:
                                                                            15,
                                                                        color: Colors
                                                                            .red,
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
                                                                            fontWeight: FontWeight.bold),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Expanded(
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  _showAlert(
                                                                      context,
                                                                      Propertytype
                                                                          .emailId!,
                                                                      Propertytype);
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border: Border.all(
                                                                        color:
                                                                            blueColor,
                                                                        width:
                                                                            1.5),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
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
                                                                            .users,
                                                                        size:
                                                                            18,
                                                                        color:
                                                                            blueColor,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Text(
                                                                        "Details",
                                                                        style: TextStyle(
                                                                            color:
                                                                                blueColor,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      )
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
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                SizedBox(height: 20),
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
                                                onChanged: snapshot.data!
                                                            .totalEmails! >
                                                        itemsPerPageOptions
                                                            .first // Condition to check if dropdown should be enabled
                                                    ? (newValue) {
                                                        setState(() {
                                                          itemsPerPage =
                                                              newValue!;
                                                          currentPage =
                                                              1; // Reset to first page when items per page change
                                                          futureEmailss = SendemailRepository()
                                                              .fetchSendEmailTable(
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
                                                    futureEmailss =
                                                        SendemailRepository()
                                                            .fetchSendEmailTable(
                                                                limit:
                                                                    itemsPerPage,
                                                                page:
                                                                    currentPage);
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
                                        Text(
                                            'Page ${currentPage} of $totalPages'),
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
                                            color: currentPage < totalPages
                                                ? blueColor
                                                : Colors.grey,
                                          ),
                                          onPressed: currentPage < totalPages
                                              ? () {
                                                  setState(() {
                                                    currentPage++;
                                                    futureEmailss =
                                                        SendemailRepository()
                                                            .fetchSendEmailTable(
                                                                limit:
                                                                    itemsPerPage,
                                                                page:
                                                                    currentPage);
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
}

void main() => runApp(MaterialApp(home: Send_Email_table()));
