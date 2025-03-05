import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_tooltip/super_tooltip.dart';

import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';

import '../../../widgets/appbar.dart';
import '../../../widgets/custom_drawer.dart';

class Add_Email_templet extends StatefulWidget {
  @override
  _Add_Email_templetState createState() => _Add_Email_templetState();
}

class _Add_Email_templetState extends State<Add_Email_templet> {
  String? selectedTemplateId;
  GlobalKey<TooltipState> _tooltipKey = GlobalKey<TooltipState>();
  final HtmlEditorController _htmlEditorController = HtmlEditorController();
  final TextEditingController name = TextEditingController();
  final TextEditingController subject = TextEditingController();
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final _controller = SuperTooltipController();
  FocusNode? _subjectFocusNode;
  FocusNode? _bodyFocusNode;
  FocusNode? _nameFocusNode;
  String? nameError;
  bool? nameErrorr;
  String? subjectError;
  String? bodyError;
  bool isLoading = false;
  String? _selectedEvent;
  List<String> events = [
    'Reset password',
    'Invitation',
    'Property assign',
    'Lease creation',
    'Work Orders',
    'Payment receipt',
    'LateFee reminder',
    'Lease end Reminder',
    'Express Payment',
    'Payment refund',
    'Applicant application',
    'Applicant status',
    'Payment failure',
    'Manual Tenant',
  ];
  @override
  void initState() {
    super.initState();
    _subjectFocusNode = FocusNode();
    _nameFocusNode = FocusNode();
  }

  void saveTemplate() async {
    setState(() {
      isLoading = true;
      nameError = null;
      subjectError = null;
      bodyError = null; // Start loading
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString("token");

    String updatedHtmlBody =
        await _htmlEditorController.getText(); // Get updated HTML content

    print("body of ${updatedHtmlBody}");

    if (name.text.trim().isEmpty || subject.text.trim().isEmpty || updatedHtmlBody.trim().isEmpty) {
      setState(() {
        isLoading = false;
        nameError = name.text.trim().isEmpty ? "Template name cannot be empty" : null;
        subjectError = subject.text.trim().isEmpty ? "Email subject cannot be empty" : null;
        bodyError = "Email body cannot be empty"; // Set the error message
      });
      return; // Stop execution
    }
    Map<String, dynamic> updatedTemplate = {
      "admin_id": adminId,
      "name": name.text,
      "subject": subject.text,
      "body": updatedHtmlBody,
      "type": "E-mail",
      "mail_type": _selectedEvent,
    };

    final response = await http.post(
      Uri.parse("${Api_url}/api/templates"),
      headers: {
        "Content-Type": "application/json",
        "authorization": "CRM $token",
        "id": "CRM $adminId",
      },
      body: json.encode(updatedTemplate),
    );
    print(" templet post ${response.body}");
    setState(() {
      isLoading = false; // Stop loading
    });
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Template posted successfully!",
      );
      Navigator.pop(context, true);
    } else {
      print("Failed to add template");
      Fluttertoast.showToast(msg: "Failed to post template");
    }
  }

  Map<String, List<Map<String, String>>> tipsObject = {
    "Reset password": [
      {r"${Name}": "Receiver Name"},
      {r"${Url}": "Reset password link"},
      {r"${EmailAddress}": "E-mail Address"},
      {r"${CompanyName}": "Company Name"},
    ],
    "Invitation": [
      {r"${Name}": "Receiver Name"},
      {r"${EmailAddress}": "Email Address"},
      {r"${Password}": "Password"},
      {r"${Url}": "Login Link"},
      {r"${CompanyName}": "Company Name"},
    ],
    "Property assign": [
      {r"${Name}": "Receiver Name"},
      {r"${RentalOwner}": "Rental Owner Name"},
      {r"${RentalAddress}": "Rental Address"},
      {r"${Unit}": "Unit Address"},
      {r"${EmailAddress}": "E-mail Address"},
      {r"${CompanyName}": "Company Name"},
    ],
    "Lease creation": [
      {r"${Name}": "Receiver Name"},
      {r"${RentalOwner}": "Rental Owner Name"},
      {r"${RentalAddress}": "Rental Address"},
      {r"${Unit}": "Unit Address"},
      {r"${StartDate}": "Start Date"},
      {r"${EndDate}": "End Date"},
      {r"${Rent}": "Rent Amount"},
      {r"${EmailAddress}": "E-mail Address"},
      {r"${CompanyName}": "Company Name"},
    ],
    "Work Orders": [
      {r"${Name}": "Receiver Name"},
      {r"${RentalOwner}": "Rental Owner Name"},
      {r"${RentalAddress}": "Rental Address"},
      {r"${Unit}": "Unit Address"},
      {r"${Title}": "title"},
      {r"${Category}": "Category"},
      {r"${Priority}": "Priority"},
      {r"${Work_Perform}": "Work to be performed"},
      {r"${Status}": "Status"},
      {r"${DueDate}": "Due Date"},
      {r"${Entry_Allowed}": "Entry allowed"},
      {r"${EmailAddress}": "E-mail Address"},
      {r"${CompanyName}": "Company Name"},
    ],
    "Payment receipt": [
      {r"${Name}": "Receiver Name"},
      {r"${RentalOwner}": "Rental Owner Name"},
      {r"${RentalAddress}": "Rental Address"},
      {r"${PaymentDate}": "Payment Date"},
      {r"${CurrentDate}": "Current Date"},
      {r"${AmountPaid}": "Amount Paid"},
      {r"${AmountDue}": "Due Amount"},
      {r"${TransactionId}": "Transaction Id"},
      {r"${PaymentMethod}": "Payment Method"},
      {r"${EmailAddress}": "E-mail Address"},
      {r"${CompanyName}": "Company Name"},
    ],
    "LateFee reminder": [
      {r"${Name}": "Receiver Name"},
      {r"${Amount}": "Rent amount"},
      {r"${LateFee}": "Late Fee percentage"},
      {r"${Duration}": "late fee duration"},
      {r"${RentalAddress}": "Rental Address"},
      // { "${Unit}": "Unit Name" },
      {r"${DueDate}": "Due date to pay Rent"},
      {r"${EmailAddress}": "E-mail Address"},
      {r"${CompanyName}": "Company Name"},
    ],
    "Lease end Reminder": [
      {r"${Name}": "Receivers Name"},
      {r"${EndDate}": "Lease End Date"},
      {r"${RentalAddress}": "Rental Address"},
      {r"${EmailAddress}": "E-mail Address"},
      {r"${CompanyName}": "Company Name"},
    ],
    "Express Payment": [
      {r"${Name}": "Receivers Name"},
      {r"${RentalOwner}": "Rental Owner Name"},
      {r"${RentalAddress}": "Rental Address"},
      {r"${Url}": "Express Payment URL"},
      {r"${EmailAddress}": "E-mail Address"},
      {r"${CompanyName}": "Company Name"},
      {r"${Duration}": "link valid untill days"},
    ],
    "Payment refund": [
      {r"${Name}": "Receiver Name"},
      {r"${Amount}": "Refund Amount"},
      {r"${TransactionId}": "Transaction Id"},
      {r"${Date}": "Refund Date"},
      {r"${EmailAddress}": "E-mail Address"},
      {r"${CompanyName}": "Company Name"},
    ],
    "Applicant application": [
      {r"${Name}": "Receiver Name"},
      {r"${RentalAddress}": "Rental Address"},
      {r"${Url}": "Application link"},
      {r"${EmailAddress}": "E-mail Address"},
      {r"${CompanyName}": "Company Name"},
    ],
    "Applicant status": [
      {r"${Name}": "Receiver Name"},
      {r"${RentalAddress}": "Rental Address"},
      {r"${Status}": "Applicant Status"},
      {r"${EmailAddress}": "E-mail Address"},
      {r"${CompanyName}": "Company Name"},
    ],
    "Payment failure": [
      {r"${Name}": "Receiver Name"},
      {r"${RentalAddress}": "Rental Address"},
      {r"${PaymentDate}": "Payment Date"},
      {r"${AmountPaid}": "Amount Paid"},
      {r"${PaymentFailureReason}": "Payment Failure Reason"},
      {r"${PaymentMethod}": "Payment Method"},
      {r"${EmailAddress}": "E-mail Address"},
      {r"${CompanyName}": "Company Name"},
    ],
    "Manual Tenant": [
      {r"${Name}": "Receiver Name"},
      {r"${EmailAddress}": "E-mail Address"},
      {r"${CompanyName}": "Company Name"},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Rent Roll",
        dropdown: true,
      ),
      appBar: widget_302.App_Bar(context: context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Form(
              key: _formkey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text('Name',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: blueColor)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Material(
                                  elevation: 2,
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Container(
                                    height: 47,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.0),
                                      //border: Border.all(color: blueColor),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          offset: Offset(4, 4),
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      onChanged: (value) {
                                        setState(() {
                                          nameErrorr = false;
                                        });
                                      },
                                      focusNode: _nameFocusNode,
                                      controller: name,
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                            fontSize: 13, color: Colors.grey),
                                        border: InputBorder.none,
                                        hintText: "Enter name",
                                      ),
                                      onTapOutside: (_) {
                                        _nameFocusNode?.unfocus();
                                        FocusScope.of(context)
                                            .requestFocus(_bodyFocusNode);
                                        _htmlEditorController.setFocus();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              if (nameErrorr != null)
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5, left: 3),
                                      child: Text(
                                        nameError!,
                                        style: TextStyle(color: Colors.red, fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 1,
                      ),
                      Expanded(
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  "Event Type",
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              FormField<String>(
                                validator: (value) {
                                  if (_selectedEvent == null ||
                                      _selectedEvent!.isEmpty) {
                                    return 'Please select a event';
                                  }
                                  return null;
                                },
                                builder: (FormFieldState<String> state) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton2<String>(
                                          isExpanded: true,
                                          hint: const Text('Select Event'),
                                          value: _selectedEvent,
                                          items: events.map((method) {
                                            return DropdownMenuItem<String>(
                                              value: method,
                                              child: Text(method),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _selectedEvent = newValue;

                                              state.didChange(newValue);
                                            });
                                            print(
                                                'Selected Event: $_selectedEvent');
                                            state.reset();
                                            // Notify FormField of value change
                                          },
                                          buttonStyleData: ButtonStyleData(
                                            height: 45,
                                            padding: const EdgeInsets.only(
                                                left: 14, right: 14),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: Colors.white,
                                            ),
                                            elevation: 2,
                                          ),
                                          iconStyleData: const IconStyleData(
                                            icon: Icon(Icons.arrow_drop_down),
                                            iconSize: 24,
                                            iconEnabledColor: Color(0xFFb0b6c3),
                                            iconDisabledColor: Colors.grey,
                                          ),
                                          dropdownStyleData: DropdownStyleData(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: Colors.white,
                                            ),
                                            scrollbarTheme: ScrollbarThemeData(
                                              radius: const Radius.circular(6),
                                              thickness:
                                                  MaterialStateProperty.all(6),
                                              thumbVisibility:
                                                  MaterialStateProperty.all(
                                                      true),
                                            ),
                                          ),
                                          menuItemStyleData:
                                              const MenuItemStyleData(
                                            height: 50,
                                            padding: EdgeInsets.only(
                                                left: 14, right: 14),
                                          ),
                                        ),
                                      ),
                                      if (state.hasError)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 14, top: 8),
                                          child: Text(
                                            state.errorText!,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: 2,
                      ),
                      Text('Subject',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: blueColor)),
                    ],
                  ),
                  if (subjectError != null)
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5, left: 3),
                          child: Text(
                            subjectError!,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            height: 47,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              //border: Border.all(color: blueColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: Offset(4, 4),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: TextFormField(
                              focusNode: _subjectFocusNode,
                              controller: subject,
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    fontSize: 13, color: Color(0xFFb0b6c3)),
                                border: InputBorder.none,
                                hintText: "Enter subject",
                              ),
                              onTapOutside: (_) {
                                _subjectFocusNode?.unfocus();
                                FocusScope.of(context)
                                    .requestFocus(_bodyFocusNode);
                                _htmlEditorController
                                    .setFocus(); // Move focus to the editor
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: 2,
                      ),
                      Text(
                        "Body",
                        style: TextStyle(
                            color: blueColor, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      SuperTooltip(
                        controller: _controller,
                        popupDirection: TooltipDirection.down,
                        backgroundColor: Color(0xff2f2d2f),
                        arrowTipDistance: 20.0,
                        touchThroughAreaShape: ClipAreaShape.rectangle,
                        touchThroughAreaCornerRadius: 30,
                        barrierColor: Color.fromARGB(26, 47, 45, 47),
                        content: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            tipsObject[_selectedEvent] != null &&
                                    tipsObject[_selectedEvent]!.isNotEmpty
                                ? 'You can personalize transaction templates using the following dynamic variables :\n' +
                                    tipsObject[_selectedEvent]!
                                        .map((e) => e.entries.first)
                                        .map((entry) =>
                                            "${entry.key}: ${entry.value}")
                                        .join("\n")
                                : 'You can personalize transaction templates using the following dynamic variables :',
                            softWrap: true,
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                        child: Icon(
                          Icons.error,
                          color: blueColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Column(
                        children: [
                          Focus(
                            focusNode: _bodyFocusNode,
                            child: HtmlEditor(
                              controller: _htmlEditorController,
                              htmlEditorOptions: HtmlEditorOptions(
                                adjustHeightForKeyboard: false,
                                hint: "Edit your email content here...",
                                //  shouldEnsureVisible: true,
                              ),
                              otherOptions: OtherOptions(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(4)),
                                ),
                              ),
                              htmlToolbarOptions: HtmlToolbarOptions(
                                // toolbarType: ToolbarType.nativeExpandable,
                                customToolbarButtons: [
                                  PopupMenuButton<String>(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("Paragraph",
                                              style: TextStyle(
                                                fontSize: 16,
                                              )),
                                          Icon(Icons
                                              .arrow_drop_down), // Dropdown indicator
                                        ],
                                      ),
                                    ),
                                    tooltip: "Paragraph",
                                    onSelected: (String format) {
                                      _htmlEditorController.execCommand(
                                          "formatBlock",
                                          argument: format);
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: "h1",
                                        child: Text("Heading 1",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      PopupMenuItem(
                                        value: "h2",
                                        child: Text("Heading 2",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      PopupMenuItem(
                                        value: "h3",
                                        child: Text("Heading 3",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      PopupMenuItem(
                                        value: "p",
                                        child: Text("Paragraph",
                                            style: TextStyle(fontSize: 14)),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.format_quote),
                                    tooltip: "Insert Quote",
                                    onPressed: () {
                                      _htmlEditorController.execCommand(
                                          "formatBlock",
                                          argument: "blockquote");
                                    },
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.text_fields),
                                    tooltip: "Font Size",
                                    onSelected: (String text) {
                                      _htmlEditorController.execCommand(
                                          "fontSize",
                                          argument: text);
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                          value: "1", child: Text("tiny")),
                                      PopupMenuItem(
                                          value: "2", child: Text("small")),
                                      PopupMenuItem(
                                          value: "3", child: Text("default")),
                                      PopupMenuItem(
                                          value: "5", child: Text("big")),
                                      PopupMenuItem(
                                          value: "7", child: Text("huge")),
                                    ],
                                  ),
                                ],
                                defaultToolbarButtons: [
                                  OtherButtons(
                                      fullscreen: false,
                                      help: false,
                                      codeview: false,
                                      undo: true,
                                      redo: true,
                                      copy: false,
                                      paste: false),
                                  FontButtons(
                                    bold: true,
                                    italic: true,
                                    underline: false,
                                    strikethrough: false,
                                    subscript: false,
                                    superscript: false,
                                    clearAll: false,
                                  ),
                                  InsertButtons(
                                    picture: false,
                                    video: false,
                                    audio: false,
                                    table: true,
                                    hr: false,
                                  ),
                                  ListButtons(
                                    ul: true,
                                    ol: true,
                                    listStyles: false,
                                  ),
                                  ParagraphButtons(
                                    textDirection: false,
                                    lineHeight: false,
                                    caseConverter: false,
                                    decreaseIndent: false,
                                    increaseIndent: false,
                                  ),
                                  ColorButtons(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (bodyError != null)
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5, left: 3),
                          child: Text(
                            bodyError!,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (name.text.trim().isEmpty) {
                            setState(() {
                              nameErrorr = true;
                              nameError = "Name is required";
                            });
                          } else {
                            setState(() {
                              nameErrorr = false;
                            });
                          }
                          // if (_formkey.currentState?.validate() ?? false) {
                          //   print('valid');
                          //
                          //   saveTemplate();
                          // } else {
                          //   print('invalid');
                          // }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: blueColor,
                        ),
                        child: isLoading
                            ? SpinKitFadingCircle(
                                color: Colors.white,
                                size: 25.0,
                              )
                            : Text(
                                "Save",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(fontSize: 16, color: blueColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
