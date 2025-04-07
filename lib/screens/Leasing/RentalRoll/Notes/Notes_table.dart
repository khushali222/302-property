import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Model/lease_notes_model.dart';
import '../../../../constant/constant.dart';

import '../../../../provider/dateProvider.dart';
import '../../../../widgets/CustomTableShimmer.dart';
import '../../../../widgets/appbar.dart';

import 'package:http/http.dart' as http;

class NotesTable extends StatefulWidget {
  String? leaseid;
   NotesTable({super.key,this.leaseid});

  @override
  State<NotesTable> createState() => _NotesTableState();
}

class _NotesTableState extends State<NotesTable> {
  late Future<List<lease_notes>> _futureleasenotes;
  bool isLoading = true;
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int totalrecords = 0;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  int currentPage = 0;
  int itemsPerPage = 10;
  int? expandedRowIndex;
  List<int> itemsPerPageOptions = [10, 25, 50, 100];
  int? expandedIndex;
  void _changeRowsPerPage(int selectedRowsPerPage) {
    setState(() {
      _rowsPerPage = selectedRowsPerPage;
      _currentPage = 0; // Reset to the first page when changing rows per page
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futureleasenotes = fetchleasenotedata();
  }
  Future<List<lease_notes>> fetchleasenotedata() async {
   // RentersInsuranceService service = RentersInsuranceService();
    try {
      List<lease_notes> data =
      await fetchleaseNote(widget.leaseid!);
      setState(() {
       // rentersInsuranceModel = data;
        isLoading = false;
        //errorMessage = null; // Reset error message on successful data fetch
      });
      return data;
    } catch (e) {
      setState(() {
        isLoading = false;
        // errorMessage =
        // 'Failed to load renters insurance data. Please try again later.';
      });
      return [];
    }
  }

  Future<List<lease_notes>> fetchleaseNote(String leaseid) async {
    print('entry');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');
    try {
      final response = await http.get(Uri.parse('$Api_url/api/lease-notes/$leaseid'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $adminId",
      });
      print("$Api_url/api/lease-notes/$leaseid");
      print(response.body);
      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        print(response.body);
        final parsedJson = jsonDecode(response.body);
        print(parsedJson);
        List leasesJson = parsedJson['data'];
        setState(() {
          isLoading = false;
        });
        return leasesJson.map((data) => lease_notes.fromJson(data)).toList();
      } else {
        print(response.body);
        // If the server did not return a 200 OK response, throw an exception
        throw Exception('Failed to load renters insurance');
      }
    } catch (e) {
      // Handle any other exceptions
      print('Error fetching data: $e');
      return [];
    }
  }

  final List<String> noteTypeList = [
    "General",
    "Reminder",
    "Legal",
    "Lease Payment",
  ];

  Future<Map<String, dynamic>> deleteNote({
    required String noteid,
  }) async {
    try {
      final Uri uri = Uri.parse('$Api_url/api/lease-notes/delete_note/$noteid');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? id = prefs.getString('adminId');
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
        return json.decode(response.body);
      } else {
        Fluttertoast.showToast(msg: responseData["message"]);
        throw Exception('Failed to delete Insurance');
      }
    } catch (e) {
      throw Exception('Failed to delete Insurance: $e');
    }
  }


  final _formKey = GlobalKey<FormState>();
  Future<void> submitNote(
      {
        String? leaseId,
        String? adminId,
        String? noteId,
        String? noteType,
        String? content,
      }

      ) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? Id = prefs.getString("adminId");
    String? token = prefs.getString('token');
//if (!_formKey.currentState!.validate()) return;


    final url = noteId == null
        ? Uri.parse("$Api_url/api/lease-notes/add_note")
        : Uri.parse("$Api_url/api/lease-notes/update_note/${noteId}");

    print("$url");
    final body = {
      "lease_id": leaseId,
      "admin_id": Id,
      "note_type": noteType!,
      "content": content,
    };

    final response = noteId == null
        ? await http.post(url, body: json.encode(body), headers: {
      "authorization": "CRM $token",
      "id": "CRM $Id",
      "Content-Type": "application/json",
    })
        : await http.put(url, body: json.encode(body), headers: {
      "authorization": "CRM $token",
      "id": "CRM $Id",
      "Content-Type": "application/json",
    });
    print(body);

    print(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
     // Navigator.of(context).pop();
     //  setState(() {
     //    _futureleasenotes = fetchleasenotedata();
     //  });
      //widget.onSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to ${noteId == null ? 'add' : 'update'} note")),
      );
    }
  }

  reloadScreen(){
    setState(() {
      _futureleasenotes = fetchleasenotedata();
    });
    Navigator.pop(context);
  }
  Future<bool?>  showNoteDialog(BuildContext context, {
     String? leaseId,
     String? adminId,
    String? noteId,
    String? noteType,
    String? content,
  }) async {
    String? selectedNoteType =noteType;
    TextEditingController contentController = content != null ? TextEditingController(text: content):TextEditingController();
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return  StatefulBuilder(
            builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        noteId == null ? 'Add Note' : 'Edit Note',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(" Notes Type *",style: TextStyle(color: blueColor,fontWeight: FontWeight.bold,fontSize: 15),),
                                DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField2<String>(
                                    isExpanded: true,
                                    hint: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 5),
                                      child: Text(
                                        "Select Note Type",
                                        style: TextStyle(fontSize: 14, color: Colors.black),
                                      ),
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.zero,

                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none, // <-- Hide outer border
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none, // <-- Hide underline
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none, // <-- Hide underline
                                      ),
                                    ),
                                    value: selectedNoteType,
                                    items: noteTypeList
                                        .map((type) => DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(
                                        type,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedNoteType = value!;
                                      });
                                    },
                                    validator: (value) => value == null ? 'Please select a note type' : null,
                                    dropdownStyleData: DropdownStyleData(
                                      maxHeight: 300,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: Colors.white,
                                      ),
                                      scrollbarTheme: ScrollbarThemeData(
                                        radius: const Radius.circular(6),
                                        thickness: MaterialStateProperty.all(6),
                                        thumbVisibility: MaterialStateProperty.all(true),
                                      ),
                                    ),
                                    buttonStyleData: ButtonStyleData(
                                      height: 50,
                                      padding: const EdgeInsets.symmetric(horizontal: 3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: Colors.white,
                                        border: Border.all(color: Colors.grey.shade400),
                                      ),
                                      elevation: 2,
                                    ),
                                    iconStyleData: const IconStyleData(
                                      icon: Icon(Icons.arrow_drop_down),
                                      iconSize: 24,
                                      iconEnabledColor: Color(0xFFb0b6c3),
                                      iconDisabledColor: Colors.grey,
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 50,
                                      padding: EdgeInsets.only(left: 14, right: 14),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                            const SizedBox(height: 16),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(" Content *",style: TextStyle(color: blueColor,fontWeight: FontWeight.bold,fontSize: 15),),

                                TextFormField(
                                  controller: contentController,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                   // labelText: 'Content',
                                    hintText: 'Content...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Content is required';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;

                              setState(() {
                                isLoading = true;
                              });

                              await submitNote(
                                leaseId: leaseId,
                                adminId: adminId,
                                noteId: noteId,
                                noteType: selectedNoteType,
                                content: contentController.text,
                              ).then((value){
                                setState(() {
                                  isLoading = false;
                                 // _futureleasenotes = fetchleasenotedata();
                                });
                               reloadScreen();

                              });
                              //

                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blueColor,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : Text(
                              noteId == null ? 'Add' : 'Update',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          }
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
      desc: "You want to delete this note?",
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
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.grey,
        ),
      ],
    ).show();
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
              child: Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Row(
                  children: [
                    width < 400 ? const Text("Date", style: TextStyle(color: Colors.white, fontSize: 15)) : const Text("Date", style: TextStyle(color: Colors.white, fontSize: 15)),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 3),
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
            Expanded(
              child: Row(
                children: [
                  Text("Note Type", style: TextStyle(color: Colors.white, fontSize: 15)),
                  SizedBox(width: 5),
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    return Container(

      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Spacer(),
                GestureDetector(
                  onTap: () async {
                    final shouldRefresh = await showNoteDialog( context,leaseId: widget.leaseid);
                    if (shouldRefresh == true) {
                      print("should Refresh $shouldRefresh");
                      setState(() {
                        _futureleasenotes = fetchleasenotedata(); // or whatever your data refresh method is
                      });
                    }

                    // Provider.of<SelectedTenantsProvider>(context,
                    //     listen: false)
                    //     .clearTenant();
                    // Provider.of<SelectedCosignersProvider>(context,
                    //     listen: false)
                    //     .clearCosigner();
                    // Provider.of<SelectedApplicantProvider>(context,
                    //     listen: false)
                    //     .clearApplicant();
                  },
                  child: Container(
                    height: (MediaQuery.of(context).size.width < 500) ? 35 : MediaQuery.of(context).size.width * 0.063,
                    width: (MediaQuery.of(context).size.width < 500) ? MediaQuery.of(context).size.width * 0.35 : MediaQuery.of(context).size.width * 0.2,
                    decoration: BoxDecoration(
                      color: blueColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        "+ Add Note",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width < 500 ? 14 : 22,
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
            const SizedBox(height: 8),

            FutureBuilder<List<lease_notes>>(
                future: _futureleasenotes,
                builder: (context, snapshot) {
                  if (isLoading) {
                    return Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: ColabShimmerLoadingWidget(),
                    );
                  }
                  else if(snapshot.hasError){
                    print(snapshot.error);
                  }
                  else if (!snapshot.hasData ||
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
                  final totalPages = (data.length / itemsPerPage).ceil();
                  final currentPageData = data
                      .skip(currentPage * itemsPerPage)
                      .take(itemsPerPage)
                      .toList();

                  return  SingleChildScrollView(
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
                                               // Larger size for the first field
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
                                                            '${dateProvider.formatCurrentDate(item.createdAt!) ?? '-'}',
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
                                              SizedBox(width: 10),
                                              Expanded(

                                                child: Text(
                                                  item.noteType!
                                                     ,
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
                                                                'Content : ',
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                    color:
                                                                    blueColor), // Bold and black
                                                              ),
                                                              TextSpan(
                                                                // text: formatDate(
                                                                //     '${Propertytype.updatedAt}'),
                                                                text:  '${item.content}' ,
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight
                                                                        .w700,
                                                                    color:
                                                                    grey), // Light and grey
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),

                                                    ],
                                                  ),

                                                  SizedBox(
                                                    height: 15,
                                                  ),
                                                  Row(
                                                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child:
                                                        GestureDetector(
                                                          onTap:
                                                              () async {
                                                                final shouldRefresh =    await  showNoteDialog(context,noteId: item.noteId,content: item.content,adminId: item.adminId,leaseId: item.leaseId,noteType: item.noteType);
                                                                if (shouldRefresh == true) {
                                                                  setState(() {
                                                                    _futureleasenotes = fetchleasenotedata(); // or whatever your data refresh method is
                                                                  });
                                                                }
                                                          },
                                                          child:
                                                          Container(
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
                                                                      .edit,
                                                                  size:
                                                                  15,
                                                                  color:
                                                                  blueColor,
                                                                ),
                                                                SizedBox(
                                                                  width:
                                                                  10,
                                                                ),
                                                                Text(
                                                                  "Edit",
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
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Expanded(
                                                        child:
                                                        GestureDetector(
                                                          onTap: () {
                                                            _showDeleteAlert(
                                                                context,
                                                                item.noteId ??
                                                                    "");
                                                          },
                                                          child:
                                                          Container(
                                                            height: 40,
                                                            decoration: BoxDecoration(
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
                                                                      .trashCan,
                                                                  size:
                                                                  15,
                                                                  color:
                                                                  blueColor,
                                                                ),
                                                                SizedBox(
                                                                  width:
                                                                  10,
                                                                ),
                                                                Text(
                                                                  "Delete",
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
                })
          ],
        ),
      ),
    );
  }
}
