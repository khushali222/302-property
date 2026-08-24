import 'package:three_zero_two_property/services/app_log.dart';
import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:three_zero_two_property/widgets/no_internet_view.dart';
import 'package:three_zero_two_property/provider/network_retry_state.dart';
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
import 'package:three_zero_two_property/services/api_helpers.dart';

class NotesTable extends StatefulWidget {
  String? leaseid;
  /// When set, the table is TENANT-scoped (web: LeaseNote scope="tenant"):
  /// it reads /lease-notes/tenant/{id} — tenant notes merged with the notes
  /// of every lease that tenant is on — and new notes attach to the tenant.
  /// Leave null for the existing lease-scoped behaviour.
  final String? tenantId;
  NotesTable({super.key, this.leaseid, this.tenantId});

  bool get isTenantScope => (tenantId ?? '').isNotEmpty;

  @override
  State<NotesTable> createState() => _NotesTableState();
}

class _NotesTableState extends State<NotesTable>
    with NetworkRetryState {
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
  String selectedNoteFilter = "All Types";
  final List<String> filterTypeList = [
    "All Types",
    "General",
    "Reminder",
    "Legal",
    "Lease Payment",
  ];
  void _changeRowsPerPage(int selectedRowsPerPage) {
    setState(() {
      _rowsPerPage = selectedRowsPerPage;
      _currentPage = 0; // Reset to the first page when changing rows per page
    });
  }

  /// Required by [NetworkRetryState]: re-issue this view's own load.
  /// The data calls `initState` makes; controllers and defaults are not
  /// repeated, so a reload keeps what the user was looking at.
  @override
  Future<void> reloadData() async {
    if (!mounted) return;
    setState(() {
      _futureleasenotes = fetchleasenotedata();
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
      // In tenant scope leaseid is null by design — the id is not used to
      // build the URL there, so it must not be force-unwrapped.
      List<lease_notes> data = await fetchleaseNote(widget.leaseid ?? '');
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');
    try {
      // Web parity: tenant scope reads a different path.
      final uri = widget.isTenantScope
          ? Uri.parse('$Api_url/api/lease-notes/tenant/${widget.tenantId}')
          : Uri.parse('$Api_url/api/lease-notes/$leaseid');
      final response = await http.get(uri, headers: {
        "authorization": "CRM $token",
        "id": "CRM $adminId",
      });
      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        final parsedJson = jsonDecode(response.body);
        List leasesJson = parsedJson['data'];
        setState(() {
          isLoading = false;
        });
        return leasesJson.map((data) => lease_notes.fromJson(data)).toList();
      } else {
        // If the server did not return a 200 OK response, throw an exception
        throw Exception('Failed to load renters insurance');
      }
    } catch (e) {
      // Handle any other exceptions
      logError('Error fetching data: $e');
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
      final http.Response response = await apiDelete(
        uri,
        headers: <String, String>{
          "authorization": "CRM $token",
          "id": "CRM $id",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({}),
      );

      var responseData = json.decode(response.body);
      // print(renters_insurance_id);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: responseData["message"] ?? "Note deleted successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return json.decode(response.body);
      } else {
        Fluttertoast.showToast(
          msg: responseData["message"] ?? "Failed to delete note",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        throw Exception('Failed to delete note');
      }
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  final _formKey = GlobalKey<FormState>();
  Future<void> submitNote({
    String? leaseId,
    String? adminId,
    String? noteId,
    String? noteType,
    String? content,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? Id = prefs.getString("adminId");
    String? token = prefs.getString('token');
//if (!_formKey.currentState!.validate()) return;

    final url = noteId == null
        ? Uri.parse("$Api_url/api/lease-notes/add_note")
        : Uri.parse("$Api_url/api/lease-notes/update_note/${noteId}");

    // Web parity: an EDIT never moves a note between owners, so the owner
    // keys are only sent when creating.
    final body = {
      "admin_id": Id,
      "note_type": noteType!,
      "content": content,
      if (noteId == null)
        ...(widget.isTenantScope
            ? {"scope": "tenant", "tenant_id": widget.tenantId}
            : {"scope": "lease", "lease_id": leaseId}),
    };

    final response = noteId == null
        ? await apiPost(url, body: json.encode(body), headers: {
            "authorization": "CRM $token",
            "id": "CRM $Id",
            "Content-Type": "application/json",
          })
        : await apiPut(url, body: json.encode(body), headers: {
            "authorization": "CRM $token",
            "id": "CRM $Id",
            "Content-Type": "application/json",
          });

    if (response.statusCode == 200 || response.statusCode == 201) {
      var responseData = json.decode(response.body);
      Fluttertoast.showToast(
        msg: responseData["message"] ??
            "${noteId == null ? 'Note added' : 'Note updated'} successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      // Navigator.of(context).pop();
      //  setState(() {
      //    _futureleasenotes = fetchleasenotedata();
      //  });
      //widget.onSuccess();
    } else {
      var responseData = json.decode(response.body);
      Fluttertoast.showToast(
        msg: responseData["message"] ??
            "Failed to ${noteId == null ? 'add' : 'update'} note",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  reloadScreen() {
    setState(() {
      _futureleasenotes = fetchleasenotedata();
    });
    Navigator.pop(context);
  }

  Future<bool?> showNoteDialog(
    BuildContext context, {
    String? leaseId,
    String? adminId,
    String? noteId,
    String? noteType,
    String? content,
  }) async {
    String? selectedNoteType = noteType;
    TextEditingController contentController = content != null
        ? TextEditingController(text: content)
        : TextEditingController();
    // Store original values for comparison when editing
    String? originalNoteType = noteType;
    String? originalContent = content;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          final bool canSubmit = (selectedNoteType != null &&
                  selectedNoteType!.trim().isNotEmpty) &&
              contentController.text.trim().isNotEmpty;
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          noteId == null ? 'Add Note' : 'Edit Note',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: blueColor,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 22,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
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
                              Text.rich(
                                TextSpan(
                                  text: "Notes Type ",
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                  children: const [
                                    TextSpan(
                                      text: "*",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonHideUnderline(
                                child: DropdownButtonFormField2<String>(
                                  isExpanded: true,
                                  hint: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    child: Text(
                                      "Select Note Type",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Color(0xFF9AA0AA)),
                                    ),
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide
                                          .none, // <-- Hide outer border
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide.none, // <-- Hide underline
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide.none, // <-- Hide underline
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
                                  validator: (value) => value == null
                                      ? 'Please select a note type'
                                      : null,
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 300,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                    scrollbarTheme: ScrollbarThemeData(
                                      radius: const Radius.circular(6),
                                      thickness: MaterialStateProperty.all(6),
                                      thumbVisibility:
                                          MaterialStateProperty.all(true),
                                    ),
                                  ),
                                  buttonStyleData: ButtonStyleData(
                                    height: 56,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                  ),
                                  iconStyleData: IconStyleData(
                                    icon:
                                        const Icon(Icons.keyboard_arrow_down),
                                    iconSize: 26,
                                    iconEnabledColor: blueColor,
                                    iconDisabledColor: Colors.grey,
                                  ),
                                  menuItemStyleData: const MenuItemStyleData(
                                    height: 50,
                                    padding:
                                        EdgeInsets.only(left: 14, right: 14),
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
                              Text.rich(
                                TextSpan(
                                  text: "Content ",
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                  children: const [
                                    TextSpan(
                                      text: "*",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: contentController,
                                maxLines: 5,
                                maxLength: 500,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: 'Write your note here...',
                                  hintStyle: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: blueColor, width: 1.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
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
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[800],
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: !canSubmit
                                ? null
                                : () async {
                                    if (!_formKey.currentState!.validate())
                                      return;

                                    // Check if editing and no changes were made
                                    if (noteId != null) {
                                      bool hasChanges = (selectedNoteType !=
                                              originalNoteType) ||
                                          (contentController.text.trim() !=
                                              (originalContent ?? '').trim());

                                      if (!hasChanges) {
                                        Fluttertoast.showToast(
                                          msg: "No changes made",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                        );
                                        return;
                                      }
                                    }

                                    setState(() {
                                      isLoading = true;
                                    });

                                    await submitNote(
                                      leaseId: leaseId,
                                      adminId: adminId,
                                      noteId: noteId,
                                      noteType: selectedNoteType,
                                      content: contentController.text,
                                    ).then((value) {
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
                              disabledBackgroundColor: Colors.grey.shade300,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    noteId == null ? 'Add Note' : 'Update Note',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
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
            // deleteNote rethrows on a failed delete, and reloadScreen() is
            // the only thing that pops this dialog — so without this catch a
            // failure left the confirmation dialog stuck on screen. The repo
            // has already toasted the reason, so just close and stand down.
            try {
              await deleteNote(noteid: id);
            } catch (_) {
              if (mounted) Navigator.pop(context);
              return;
            }
            reloadScreen();
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
              child: Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Row(
                  children: [
                    width < 400
                        ? Text("Date",
                            style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15))
                        : Text("Date",
                            style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
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
                  Text("Note Type",
                      style: TextStyle(
                          color: blueColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
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
    // This view lives inside another screen's tab, so it shows the
    // compact offline state rather than taking over the whole page.
    if (isOffline) {
      return NoInternetView(compact: true, onRetry: retryNow);
    }
    final dateProvider = Provider.of<DateProvider>(context);
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 7),
                Container(
                  height: (MediaQuery.of(context).size.width < 500)
                      ? 44
                      : MediaQuery.of(context).size.width * 0.063,
                  width: (MediaQuery.of(context).size.width < 500)
                      ? MediaQuery.of(context).size.width * 0.42
                      : MediaQuery.of(context).size.width * 0.2,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFDBE0E5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      value: selectedNoteFilter,
                      selectedItemBuilder: (context) {
                        return filterTypeList
                            .map((type) => Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              500
                                          ? 15
                                          : 18,
                                      fontWeight: FontWeight.w600,
                                      color: blueColor,
                                    ),
                                  ),
                                ))
                            .toList();
                      },
                      items: filterTypeList.asMap().entries.map((entry) {
                        final int idx = entry.key;
                        final String type = entry.value;
                        final bool isSelected = type == selectedNoteFilter;
                        final bool isLast =
                            idx == filterTypeList.length - 1;
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFEAF0FB)
                                  : Colors.white,
                              border: isLast
                                  ? null
                                  : const Border(
                                      bottom: BorderSide(
                                          color: Color(0xFFEEF1F4)),
                                    ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    type,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: blueColor,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check,
                                      size: 20, color: blueColor),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedNoteFilter = value!;
                          currentPage = 0;
                          expandedRowIndex = null;
                        });
                      },
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.zero,
                      ),
                      iconStyleData: IconStyleData(
                        icon: const Icon(Icons.keyboard_arrow_down),
                        openMenuIcon: const Icon(Icons.keyboard_arrow_up),
                        iconSize: 24,
                        iconEnabledColor: blueColor,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 400,
                        width: (MediaQuery.of(context).size.width < 500)
                            ? MediaQuery.of(context).size.width * 0.42
                            : MediaQuery.of(context).size.width * 0.2,
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        offset: const Offset(0, -4),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 52,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () async {
                    final shouldRefresh =
                        await showNoteDialog(context, leaseId: widget.leaseid);
                    // showNoteDialog builds the payload via the scope getter,
                    // so a tenant-scoped note attaches to the tenant even when
                    // there is no lease.
                    if (shouldRefresh == true) {
                      setState(() {
                        _futureleasenotes =
                            fetchleasenotedata(); // or whatever your data refresh method is
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
                    height: (MediaQuery.of(context).size.width < 500)
                        ? 44
                        : MediaQuery.of(context).size.width * 0.063,
                    width: (MediaQuery.of(context).size.width < 500)
                        ? MediaQuery.of(context).size.width * 0.35
                        : MediaQuery.of(context).size.width * 0.2,
                    decoration: BoxDecoration(
                      color: blueColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.width < 500
                                ? 18
                                : 26,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Add Note",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width < 500
                                      ? 14
                                      : 22,
                            ),
                          ),
                        ],
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
                  } else if (snapshot.hasError) {
                  }

                  var data = snapshot.data ?? <lease_notes>[];
                  if (selectedNoteFilter != "All Types") {
                    data = data
                        .where((note) => note.noteType == selectedNoteFilter)
                        .toList();
                  }

                  if (data.isEmpty) {
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(7.0),
                        child: Column(
                          children: [
                            _buildHeaders(),
                            const SizedBox(height: 10),
                            Container(
                              height: MediaQuery.of(context).size.height * .45,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
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
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final totalPages = (data.length / itemsPerPage).ceil();
                  // Keep the current page within the valid range so that
                  // changing the filter / page size or deleting a note never
                  // leaves us on a non-existent (blank) page.
                  if (currentPage > totalPages - 1) {
                    currentPage = totalPages - 1;
                  }
                  if (currentPage < 0) {
                    currentPage = 0;
                  }
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
                          const SizedBox(height: 10),
                          Container(
                            child: Column(
                              children:
                                  currentPageData.asMap().entries.map((entry) {
                                int rowIndex = entry.key;
                                var item = entry.value;
                                bool isRowExpanded =
                                    expandedRowIndex == rowIndex;

                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: rowIndex % 2 != 0
                                        ? const Color(0xFFF4F8FF)
                                        : Colors.white,
                                    border: Border.all(
                                        color: const Color(0xFFDBE0E5)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
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
                                                  setState(() {
                                                    if (expandedRowIndex ==
                                                        rowIndex) {
                                                      expandedRowIndex = null;
                                                    } else {
                                                      expandedRowIndex =
                                                          rowIndex;
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 5),
                                                  padding: !isRowExpanded
                                                      ? const EdgeInsets.only(
                                                          bottom: 10)
                                                      : const EdgeInsets.only(
                                                          top: 10),
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
                                                      const EdgeInsets.only(
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
                                                                '${dateProvider.formatCurrentDate(item.createdAt!)}',
                                                            style: TextStyle(
                                                              color: blueColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 13,
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
                                                  item.noteType!,
                                                  style: TextStyle(
                                                    color: blueColor,
                                                    fontWeight: FontWeight.bold,
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
                                          margin: EdgeInsets.only(bottom: 2),
                                          child: SingleChildScrollView(
                                            child: Container(
                                              //color: Colors.blue,
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      FaIcon(
                                                        isRowExpanded
                                                            ? FontAwesomeIcons
                                                                .sortUp
                                                            : FontAwesomeIcons
                                                                .sortDown,
                                                        size: 50,
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                      Expanded(
                                                        child: Text.rich(
                                                          TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text:
                                                                    'Content : ',
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
                                                                text:
                                                                    '${item.content}',
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
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 15,
                                                  ),
                                                  Row(
                                                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () async {
                                                          final shouldRefresh =
                                                              await showNoteDialog(
                                                                  context,
                                                                  noteId: item
                                                                      .noteId,
                                                                  content: item
                                                                      .content,
                                                                  adminId: item
                                                                      .adminId,
                                                                  leaseId: item
                                                                      .leaseId,
                                                                  noteType: item
                                                                      .noteType);
                                                          if (shouldRefresh ==
                                                              true) {
                                                            setState(() {
                                                              _futureleasenotes =
                                                                  fetchleasenotedata(); // or whatever your data refresh method is
                                                            });
                                                          }
                                                        },
                                                        child: Container(
                                                          height: 35,
                                                          width: 35,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color: Colors
                                                                  .green
                                                                  .shade50), // color:Colors.grey[100],
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
                                                                    .edit,
                                                                size: 15,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          _showDeleteAlert(
                                                              context,
                                                              item.noteId ??
                                                                  "");
                                                        },
                                                        child: Container(
                                                          height: 35,
                                                          width: 35,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color: Colors
                                                                  .red.shade50),
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
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 15,
                                                      ),
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
                          if (totalPages > 1)
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
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
