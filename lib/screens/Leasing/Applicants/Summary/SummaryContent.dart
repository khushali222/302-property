import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/applicant_summery_model.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/applicant_summery_repo.dart';
import 'package:three_zero_two_property/screens/Leasing/Applicants/Summary/applicant_summery2.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';

class SummaryContent extends StatefulWidget {
  applicant_summery_details summery;
  String applicant_id;
  SummaryContent({required this.summery, required this.applicant_id});

  @override
  State<SummaryContent> createState() => _SummaryContentState();
}

class _SummaryContentState extends State<SummaryContent> {
  bool _showAll = false;

  List<String> applicantCheckedChecklist = [
    "CreditCheck",
    "EmploymentVerification",
    "ApplicationFee",
    "IncomeVerification",
    "LandlordVerification"
  ];
  final Map<String, String> displayNames = {
    "CreditCheck": "Credit and background check",
    "EmploymentVerification": "Employment verification",
    "ApplicationFee": "Application fee collected",
    "IncomeVerification": "Income verification",
    "LandlordVerification": "Landlord verification",
  };
  TextEditingController checkvalue = TextEditingController();
  List<String> applicantChecklist = [];
  bool addcheckbox = false;
  bool openNote = false;
  TextEditingController noteController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? _uploadedFileName;
  List<File> _pdfFiles = [];

  Future<void> _pickPdfFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      List<File> files = result.paths
          .where((path) => path != null)
          .map((path) => File(path!))
          .toList();

      if (files.length > 10) {
        Fluttertoast.showToast(msg: 'You can only select up to 10 files.');
        return; // Exit the method if more than 10 files are selected
      }

      setState(() {
        _pdfFiles = files;
      });

      for (var file in _pdfFiles) {
        await _uploadPdf(file);
      }
    }
  }

  Future<void> _uploadPdf(File pdfFile) async {
    try {
      String? fileName = await uploadPdf(pdfFile);
      setState(() {
        _uploadedFileName = fileName;
      });
    } catch (e) {
      print('PDF upload failed: $e');
    }
  }

  Future<String?> uploadPdf(File pdfFile) async {
    print(pdfFile.path);
    final String uploadUrl = '${Api_url}/api/images/upload';

    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files.add(await http.MultipartFile.fromPath('files', pdfFile.path));

    var response = await request.send();
    var responseData = await http.Response.fromStream(response);

    var responseBody = json.decode(responseData.body);
    if (responseBody['status'] == 'ok') {
      Fluttertoast.showToast(msg: 'PDF added successfully');
      List file = responseBody['files'];
      return file.first["filename"];
    } else {
      throw Exception('Failed to upload file: ${responseBody['message']}');
    }
  }

  late List<ApplicantNotesAndFile> notesAndFiles;

  @override
  void initState() {
    super.initState();
    notesAndFiles = widget.summery.applicantNotesAndFile!;
  }

  void addNoteAndFile(ApplicantNotesAndFile noteFile) {
    setState(() {
      notesAndFiles.add(noteFile);
    });
  }

  void deleteNoteAndFile(int index, String applicantId, String note__id) async {
    print("${index} ${applicantId} ${note__id} ");
    ApplicantSummeryRepository applicantSummeryRepository =
        ApplicantSummeryRepository();

    int response = await applicantSummeryRepository.deleteNoteAndFiles(
        applicantId, note__id);
    if (response == 200) {
      Fluttertoast.showToast(msg: 'Note Delete Successfully');
      setState(() {
        notesAndFiles.removeAt(index);
      });
    }
  }

  List<Widget> buildRowsNote(
      List<ApplicantNotesAndFile> statuses, int itemCount) {
    List<Widget> rows = [];
    for (int i = 0; i < itemCount && i < statuses.length; i++) {
      final status = statuses[i];
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  status.applicantNotes ?? '',
                  style: const TextStyle(
                      color: Color.fromRGBO(21, 43, 83, 1),
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Text(
                  status.applicantFile ?? 'N/A',
                  style: const TextStyle(
                      color: Color.fromRGBO(21, 43, 83, 1),
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: const Icon(Icons.clear,
                      color: Color.fromRGBO(21, 43, 83, 1)),
                  onPressed: () {
                    deleteNoteAndFile(
                        i, widget.summery.applicantId!, status.sId!);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
    return rows;
  }

  bool isNotePost = false;

  @override
  Widget build(BuildContext context) {
    int itemCount = _showAll ? widget.summery.applicantStatus!.length : 5;
    applicantChecklist =
        List<String>.from(widget.summery.applicantCheckedChecklist!);
    List<DataRow> buildRows(List<ApplicantStatus> statuses) {
      print(widget.summery.applicantId);
      List<DataRow> rows = [];
      for (int i = 0; i < itemCount && i < statuses.length; i++) {
        final status = statuses[i];
        final statusMessage =
            '${status.status} by ${status.statusUpdatedBy} at ${status.updateAt}';
        rows.add(DataRow(cells: [
          DataCell(Text(status.status!)),
          const DataCell(Text("The New Rental Application Status")),
          DataCell(Text(statusMessage)),
        ]));
      }
      return rows;
    }

    // List<Widget> buildRowsNote(
    //     List<ApplicantNotesAndFile> statuses, int itemCount) {
    //   List<Widget> rows = [];
    //   for (int i = 0; i < itemCount && i < statuses.length; i++) {
    //     final status = statuses[i];
    //     rows.add(
    //       Padding(
    //         padding: const EdgeInsets.symmetric(vertical: 8.0),
    //         child: Row(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Expanded(
    //               flex: 2,
    //               child: Text(
    //                 status.applicantNotes ?? '',
    //                 style: TextStyle(
    //                     color: Color.fromRGBO(
    //                       21,
    //                       43,
    //                       83,
    //                       1,
    //                     ),
    //                     fontSize: 14,
    //                     fontWeight: FontWeight.w500),
    //                 softWrap: true,
    //                 overflow: TextOverflow.visible,
    //               ),
    //             ),
    //             SizedBox(width: 20),
    //             Expanded(
    //               flex: 2,
    //               child: Text(
    //                 status.applicantFile ?? 'N/A',
    //                 style: TextStyle(
    //                     color: Color.fromRGBO(21, 43, 83, 1),
    //                     fontSize: 14,
    //                     fontWeight: FontWeight.w500),
    //                 softWrap: true,
    //                 overflow: TextOverflow.visible,
    //               ),
    //             ),
    //             SizedBox(width: 20),
    //             Expanded(
    //               flex: 1,
    //               child: Icon(Icons.clear,
    //                   color: const Color.fromRGBO(21, 43, 83, 1)),
    //             ),
    //           ],
    //         ),
    //       ),
    //     );
    //   }
    //   return rows;
    // }

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: applicantCheckedChecklist.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: const Color.fromRGBO(21, 43, 83, 1),
                        value: widget.summery.applicantCheckedChecklist!
                            .contains(item),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value != false) {
                              widget.summery.applicantCheckedChecklist!
                                  .add(item);
                              applicantChecklist.add(item);
                            } else {
                              widget.summery.applicantCheckedChecklist!
                                  .remove(item);
                              applicantChecklist.remove(item);
                            }
                          });
                          updatecheckBox();
                        },
                      ),
                      Text(displayNames[item].toString()),
                    ],
                  ),
                );
              }).toList(),
            ),
            Column(
              children: widget.summery.applicantChecklist!.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: const Color.fromRGBO(21, 43, 83, 1),
                        value: widget.summery.applicantCheckedChecklist!
                            .contains(item),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value != false) {
                              widget.summery.applicantCheckedChecklist!
                                  .add(item);
                              applicantChecklist.add(item);
                            } else {
                              widget.summery.applicantCheckedChecklist!
                                  .remove(item);
                              applicantChecklist.remove(item);
                            }
                          });
                          updatecheckBox();
                        },
                      ),
                      Text(item),
                      InkWell(
                          onTap: () {
                            widget.summery.applicantChecklist!.remove(item);
                            updatecheckBoxnew(
                                widget.summery.applicantChecklist!);
                          },
                          child: const Icon(
                            Icons.close,
                            color: Colors.grey,
                          )),
                    ],
                  ),
                );
              }).toList(),
            ),
            if (addcheckbox)
              Row(
                children: [
                  SizedBox(
                    height: 50,
                    width: 150,
                    child: TextFormField(
                      controller: checkvalue,
                      decoration: const InputDecoration(
                          hintText: "Enter Value",
                          border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        widget.summery.applicantChecklist!.add(checkvalue.text);
                        checkvalue.text = "";
                        addcheckbox = false;
                      });
                      updatecheckBoxnew(widget.summery.applicantChecklist!);
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.green)),
                      child: const Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        checkvalue.text = "";
                      });
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.red)),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  addcheckbox = !addcheckbox;
                });
                //  Navigator.pop(context);
              },
              child: Material(
                elevation: 3,
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
                child: Container(
                  height: 40,
                  width: 150,
                  decoration: const BoxDecoration(
                    //color: Color.fromRGBO(21, 43, 81, 1),
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add),
                      Center(
                          child: Text(
                        "Add Checklist",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(21, 43, 83, 1)),
                      )),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text('Notes And Files',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                )),
            const SizedBox(
              height: 10,
            ),
            if (openNote == false)
              Material(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      openNote = !openNote;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color.fromRGBO(21, 43, 81, 1)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Attach Note / File'),
                    ),
                  ),
                ),
              ),
            if (openNote)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color.fromRGBO(21, 43, 81, 1)),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notes',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(21, 43, 83, 1)),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      CustomTextField(
                        hintText: 'Enter Notes',
                        controller: noteController,
                      ),
                      const SizedBox(height: 10),
                      const Text('Upload File',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF152b51))),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 50,
                        width: 95,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF152b51),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: _pickPdfFiles,
                          child: const Text('Upload'),
                        ),
                      ),
                      if (_uploadedFileName != Null)
                        Text(_uploadedFileName ?? ''),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(21, 43, 83, 1),
                            ),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                NoteFile noteFiles = NoteFile(
                                    note: noteController.text,
                                    files: _uploadedFileName ?? '');
                                setState(() {
                                  isNotePost = true;
                                });
                                ApplicantSummeryRepository
                                    applicantSummeryRepository =
                                    ApplicantSummeryRepository();

                                int response = await applicantSummeryRepository
                                    .noteAndFilePost(
                                        noteFiles, widget.summery.applicantId!);
                                if (response == 200) {
                                  Fluttertoast.showToast(
                                      msg: 'Note Added Successfully');
                                  noteController.clear();
                                  setState(() {
                                    openNote = false;
                                    isNotePost = false;
                                  });
                                }
                              } else {
                                setState(() {
                                  openNote = false;
                                  isNotePost = true;
                                });
                              }
                              // Implement save logic
                            },
                            child: isNotePost
                                ? const Center(
                                    child: SpinKitFadingCircle(
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                  )
                                : const Text('Save'),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                openNote = !openNote;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color.fromRGBO(21, 43, 81, 1)),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(
              height: 10,
            ),
            notesAndFiles.isEmpty
                ? Container()
                : Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color.fromRGBO(21, 43, 81, 1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "Notes And Files",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Color.fromRGBO(21, 43, 83, 1)),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: buildRowsNote(
                                notesAndFiles,
                                _showAll ? notesAndFiles.length : 10,
                              ),
                            ),
                          ),
                          if (notesAndFiles.length > 10)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _showAll = !_showAll;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: const Color.fromRGBO(
                                                21, 43, 81, 1)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(_showAll
                                            ? 'Show Less'
                                            : 'View More'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(
              height: 10,
            ),
            Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color.fromRGBO(21, 43, 81, 1)),
                ),
                //width: ,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "Updates",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Color.fromRGBO(21, 43, 83, 1)),
                      ),
                    ),
                    DataTable(
                      headingRowHeight: 10,
                      columnSpacing: 20,
                      dataRowHeight:
                          80, // Adjust spacing between columns as needed
                      columns: [
                        const DataColumn(label: Text('')),
                        const DataColumn(label: Text('')),
                        const DataColumn(label: Text('')),
                      ],
                      rows: buildRows(widget.summery.applicantStatus!),
                    ),
                    if (widget.summery.applicantStatus!.length > 5)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showAll = !_showAll;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color:
                                          const Color.fromRGBO(21, 43, 81, 1)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      _showAll ? 'Show Less' : 'View More'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color.fromRGBO(21, 43, 81, 1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 16, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${widget.summery.applicantFirstName} ${widget.summery.applicantLastName}',
                          style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(21, 43, 81, 1),
                              fontWeight: FontWeight.bold)),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text('Applicant',
                          style: TextStyle(
                              color: Color.fromRGBO(21, 43, 81, 1),
                              fontWeight: FontWeight.normal)),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.home,
                            color: Color.fromRGBO(138, 149, 168, 1),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "${widget.summery.applicantHomeNumber != null ? 'N/A' : widget.summery.applicantHomeNumber??"N/A"}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(21, 43, 83, 1),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.business_center_outlined,
                            color: Color.fromRGBO(138, 149, 168, 1),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "${widget.summery.applicantBusinessNumber != null ? 'N/A' : widget.summery.applicantBusinessNumber??"N/A"}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(21, 43, 83, 1),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.mobile,
                            color: Color.fromRGBO(138, 149, 168, 1),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "${widget.summery.applicantPhoneNumber!.isEmpty ? 'N/A' : widget.summery.applicantPhoneNumber}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(21, 43, 83, 1),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.mail,
                            color: Color.fromRGBO(138, 149, 168, 1),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "${widget.summery.applicantEmail ?? 'N/A'}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(21, 43, 83, 1),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }

  updatecheckBox() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    var checkvalue = {"applicant_checkedChecklist": applicantChecklist};
    final response = await http.put(
      Uri.parse('$Api_url/api/applicant/applicant/${widget.applicant_id}'),
      headers: <String, String>{
        "id": "CRM $id",
        "authorization": "CRM $token",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(checkvalue),
    );
    if (response.statusCode == 200) {
      // Fluttertoast.showToast(msg: 'Applicant Updated Successfully');

      setState(() {});
    } else {
      // Log the response body for debugging
      print('Failed to update data: ${response.body}');
      throw Exception('Failed to update applicant data');
    }
  }

  updatecheckBoxnew(List applicant) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    var checkvalue = {"applicant_checklist": applicant};
    final response = await http.put(
      Uri.parse(
          '$Api_url/api/applicant/applicant/${widget.applicant_id}/checklist'),
      headers: <String, String>{
        "id": "CRM $id",
        "authorization": "CRM $token",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(checkvalue),
    );
    if (response.statusCode == 200) {
      // Fluttertoast.showToast(msg: 'Applicant Updated Successfully');

      setState(() {});
    } else {
      // Log the response body for debugging
      print('Failed to update data: ${response.body}');
      throw Exception('Failed to update applicant data');
    }
  }
}
