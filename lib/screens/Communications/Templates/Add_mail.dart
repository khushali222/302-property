import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';

import '../../../widgets/appbar.dart';
import '../../../widgets/custom_drawer.dart';

class Add_Email_templet extends StatefulWidget {
  @override
  _Add_Email_templetState createState() => _Add_Email_templetState();
}

class _Add_Email_templetState extends State<Add_Email_templet> {
  List<Map<String, dynamic>> templates = [];
  List<String> events = [];
  String? selectedTemplateId;
  final HtmlEditorController _htmlEditorController = HtmlEditorController();
  final TextEditingController name = TextEditingController();
  final TextEditingController subject = TextEditingController();
  String htmlName = ""; // Store HTML content
  String htmlBody = ""; // Store HTML content
  String htmlsubject = ""; // Store HTML content

  @override
  void initState() {
    super.initState();
    fetchTemplates();
  }

  Future<void> fetchTemplates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("${Api_url}/api/templates/get/1739444432258"),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $adminId",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["statusCode"] == 200 && data.containsKey("template")) {
        setState(() {
          templates = [data["template"]]; // Store in list
          events = [data["template"]["name"] as String]; // Extract name
          selectedTemplateId =
              data["template"]["template_id"]; // Select default
          htmlName = data["template"]["name"]; // Get HTML content
          htmlBody = data["template"]["body"]; // Get HTML content
          htmlsubject = data["template"]["subject"]; // Get HTML content
          _htmlEditorController
              .setText(replaceSpanTags(htmlBody)); // Set editor content
          //_htmlEditorController.setText(htmlBody);
        });
      }
    } else {
      print("Failed to load templates");
    }
  }

  Future<void> saveTemplate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString("token");

    String updatedHtmlBody =
        await _htmlEditorController.getText(); // Get updated HTML content

    print("body of ${updatedHtmlBody}");

    print("updated body after replace.. ${replaceFontTags(updatedHtmlBody)}");
    Map<String, dynamic> updatedTemplate = {
      "template_id": selectedTemplateId,
      "admin_id": adminId,
      "name": "Invitation",
      "subject": "Welcome to Smith test",
      // "body": updatedHtmlBody, // Send updated HTML
      "body": replaceFontTags(updatedHtmlBody), // Send updated HTML
      "type": "E-mail",
      "mail_type": "Invitation",
      "is_delete": false,
      "is_active": false,
    };

    final response = await http.put(
      Uri.parse("${Api_url}/api/templates/$selectedTemplateId"),
      headers: {
        "Content-Type": "application/json",
        "authorization": "CRM $token",
        "id": "CRM $adminId",
      },
      body: json.encode(updatedTemplate),
    );

    if (response.statusCode == 200) {
      print("Template updated successfully!");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Template updated successfully!"),
        backgroundColor: Colors.green,
      ));
    } else {
      print("Failed to update template");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to update template"),
        backgroundColor: Colors.red,
      ));
    }
  }

  String replaceFontTags(String html) {
    final Map<String, String> fontSizeMap = {
      '1': 'text-tiny',
      '2': 'text-small',
      '3': 'text-default',
      '5': 'text-big',
      '7': 'text-huge',
    };

    return html.replaceAllMapped(
      RegExp(
        r'<font\s+(?:size="(\d+)")?(?:\s*style="([^"]*)")?(?:\s*size="(\d+)")?>(.*?)<\/font>',
        caseSensitive: false,
      ),
      (match) {
        // Extract size (either from group 1 or 3, since size can appear first or last)
        String size = match.group(1) ?? match.group(3) ?? '';
        String style = match.group(2) ?? ''; // Extract style if present
        String text = match.group(4) ?? ''; // Extract inner text

        // Get class name based on size
        String? className = fontSizeMap[size];

        // Construct <span> tag
        if (className != null) {
          return style.isNotEmpty
              ? '<span class="$className" style="$style">$text</span>'
              : '<span class="$className">$text</span>';
        }

        return match.group(0)!; // Return original if no match
      },
    );
  }

  String replaceSpanTags(String html) {
    // Mapping class names to corresponding font sizes
    final Map<String, String> classToFontSizeMap = {
      'text-tiny': '1',
      'text-small': '2',
      'text-default': '3',
      'text-big': '5',
      'text-huge': '7',
    };

    // Regular expression to extract class and style attributes separately
    return html.replaceAllMapped(
      RegExp(
          r'<span[^>]*class="([^"]*)"[^>]*style="([^"]*)"[^>]*>(.*?)<\/span>',
          caseSensitive: false),
      (match) {
        String classNames = match.group(1) ?? ''; // Extract class names
        String style = match.group(2) ?? ''; // Extract inline styles
        String text = match.group(3) ?? ''; // Extract inner text

        // Extract the first matching class from the known map
        String? fontSize = classNames
            .split(' ')
            .map((cls) => classToFontSizeMap[cls])
            .firstWhere((size) => size != null, orElse: () => null);

        // If a font size is found, replace <span> with <font>
        return fontSize != null
            ? '<font size="$fontSize" style="$style">$text</font>'
            : match.group(0)!;
      },
    );
  }

  // String replaceSpanTags(String html) {
  //   // Mapping class names to corresponding font sizes
  //   final Map<String, String> classToFontSizeMap = {
  //     'text-tiny': '1',
  //     'text-small': '2',
  //     'text-default': '3',
  //     'text-big': '5',
  //     'text-huge': '7',
  //   };
  //
  //   // Regular expression to match <span class="X">...</span>
  //   return html.replaceAllMapped(
  //     RegExp(r'<span\s+class="(.*?)">(.*?)<\/span>', caseSensitive: false),
  //     (match) {
  //       String className = match.group(1) ?? ''; // Get class name
  //       String text = match.group(2) ?? ''; // Get inner text
  //       String? fontSize =
  //           classToFontSizeMap[className]; // Get corresponding font size
  //
  //       // If class name is found in the map, replace with <font>, else keep original
  //       return fontSize != null
  //           ? '<font size="$fontSize">$text</font>'
  //           : match.group(0)!;
  //     },
  //   );
  // }
  //
  // String replaceFontTags(String html) {
  //   // Mapping font sizes to corresponding class names
  //   final Map<String, String> fontSizeMap = {
  //     '1': 'text-tiny',
  //     '2': 'text-small',
  //     '3': 'text-default',
  //     '5': 'text-big',
  //     '7': 'text-huge',
  //   };
  //
  //   // Regular expression to match <font size="X">...</font>
  //   return html.replaceAllMapped(
  //     RegExp(r'<font\s+size="(\d+)">(.*?)<\/font>', caseSensitive: false),
  //     (match) {
  //       String size = match.group(1) ?? ''; // Get font size
  //       String text = match.group(2) ?? ''; // Get inner text
  //       String? className = fontSizeMap[size]; // Get corresponding class
  //
  //       // If the size is found in the map, replace with <span>, else keep original
  //       return className != null
  //           ? '<span class="$className">$text</span>'
  //           : match.group(0)!;
  //     },
  //   );
  // }

  Widget separatorWidget = const VerticalDivider(
    width: 10, // Space between toolbar items
    thickness: 1, // Line thickness
    color: Colors.grey, // Divider color
    indent: 2, // Space from top
    endIndent: 2, // Space from bottom
  );
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
                              child: CustomTextField(
                                hintText: 'Enter name',
                                controller: name,
                              ),
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
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                //border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    offset: Offset(4, 4),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedTemplateId,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedTemplateId = newValue;
                                      var selectedTemplate =
                                          templates.firstWhere(
                                        (template) =>
                                            template["template_id"] == newValue,
                                        orElse: () => {},
                                      );
                                      htmlBody = selectedTemplate["body"] ?? "";
                                      htmlName = selectedTemplate["name"] ?? "";
                                      htmlsubject =
                                          selectedTemplate["subject"] ?? "";
                                      _htmlEditorController
                                          .setText(replaceSpanTags(htmlBody));
                                      name.text = htmlName;
                                      subject.text = htmlsubject;
                                      print("name ${htmlName}");
                                      print("subject ${htmlsubject}");
                                    });
                                  },
                                  items: templates.map((template) {
                                    return DropdownMenuItem<String>(
                                      value: template["template_id"],
                                      child: Text(template["name"]),
                                    );
                                  }).toList(),
                                ),
                              ),
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
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: CustomTextField(
                    // keyboardType: TextInputType.emailAddress,
                    hintText: 'Enter subject',
                    controller: subject,
                  ),
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
                        HtmlEditor(
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
                                  _htmlEditorController.execCommand("fontSize",
                                      argument: text);
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                      value: "1", child: Text("tiny")),
                                  PopupMenuItem(
                                      value: "2", child: Text("small")),
                                  PopupMenuItem(
                                      value: "3", child: Text("default")),
                                  PopupMenuItem(value: "5", child: Text("big")),
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
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: saveTemplate,
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: blueColor,
                      ),
                      child: Text(
                        "Save",
                        style: TextStyle(fontSize: 16, color: Colors.white),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
    );
  }
}
