// import 'dart:convert';
// import 'package:flutter_quill/quill_delta.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart' as quill;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:three_zero_two_property/constant/constant.dart';
// import 'package:html2md/html2md.dart' as html2md;
// import 'package:flutter_quill/flutter_quill.dart' as quill;
// import 'package:html/parser.dart' as htmlParser;
// import 'package:html/dom.dart' as dom;
//
// class SendEmailScreen extends StatefulWidget {
//   final String leaseId;
//   SendEmailScreen({required this.leaseId});
//   @override
//   _SendEmailScreenState createState() => _SendEmailScreenState();
// }
//
// class _SendEmailScreenState extends State<SendEmailScreen> {
//   final _subjectController = TextEditingController();
//   quill.QuillController _quillController = quill.QuillController.basic();
//
//   String? selectedTenant;
//   String? selectedEvent;
//   String? selectedTemplateName;
//   @override
//   void initState() {
//     super.initState();
//
//     fetchTenants();
//     fetchTemplates();
//   }
//
//   List<String> events = [
//     'Invitation',
//     'Lease creation',
//     'Lease end Reminder',
//     'Payment receipt',
//     'Payment refund',
//     'LateFee reminder',
//     'Express Payment'
//   ];
//   List<Map<String, dynamic>> tenants = [];
//   List selectedTenants = [];
//   List<Map<String, dynamic>> templates = [];
//   Map<String, dynamic>? selectedTemplate;
//   List<Map<String, dynamic>> filteredTemplates = [];
//   Future<void> fetchTenants() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? adminId = prefs.getString("adminId");
//     String? token = prefs.getString('token');
//     final response = await http.get(
//         Uri.parse("${Api_url}/api/tenant/lease-tenant/${adminId}"),
//         headers: {
//           "authorization": "CRM $token",
//           "id": "CRM $adminId",
//         });
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data["data"] != null) {
//         setState(() {
//           tenants = List<Map<String, dynamic>>.from(data["data"]);
//         });
//       }
//     } else {
//       throw Exception("Failed to load tenants");
//     }
//   }
//
// //for templet
//   Future<void> fetchTemplates() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? adminId = prefs.getString("adminId");
//     String? token = prefs.getString('token');
//     final response = await http.get(
//         Uri.parse("${Api_url}/api/templates/get/1736503150202"),
//         headers: {
//           "authorization": "CRM $token",
//           "id": "CRM $adminId",
//         });
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       // if (data["statusCode"] == 200) {
//       //   setState(() {
//       //     templates = List<Map<String, dynamic>>.from(data["data"]);
//       //     events = templates.map((t) => t["name"] as String).toList();
//       //   });
//       // }
//       if (data["statusCode"] == 200 && data.containsKey("template")) {
//         setState(() {
//           templates = [data["template"]]; // Store the single template in a list
//           events = [data["template"]["name"] as String]; // Extract event name
//         });
//       }
//     } else {
//       print("Failed to load templates");
//     }
//   }
//
//   void onEventSelected(String? value) {
//     setState(() {
//       selectedEvent = value;
//       filteredTemplates = templates.where((t) => t["name"] == value).toList();
//       selectedTemplateName = filteredTemplates.isNotEmpty
//           ? filteredTemplates.first["name"] as String
//           : null;
//       updateQuillBody(selectedTemplateName);
//     });
//   }
//
//   void onTemplateSelected(String? value) {
//     setState(() {
//       selectedTemplateName = value;
//       updateQuillBody(value);
//     });
//   }
//
//   void updateQuillBody(String? templateName) {
//     if (templateName == null || filteredTemplates.isEmpty) return;
//
//     final selectedTemplate = filteredTemplates.firstWhere(
//       (t) => t["name"] == templateName,
//       orElse: () => {},
//     );
//
//     if (selectedTemplate.isNotEmpty && selectedTemplate.containsKey("body")) {
//       String htmlBody = selectedTemplate["body"] ?? "";
//
//       // Convert HTML to Quill Delta
//       quill.Document document = htmlToQuillDelta(htmlBody);
//
//       setState(() {
//         _quillController.document = document;
//       });
//     }
//   }
//
//   // void updateQuillBody(String? templateName) {
//   //   if (templateName == null || filteredTemplates.isEmpty) return;
//   //
//   //   final selectedTemplate = filteredTemplates.firstWhere(
//   //         (t) => t["name"] == templateName,
//   //     orElse: () => {},
//   //   );
//   //
//   //   if (selectedTemplate.isNotEmpty && selectedTemplate.containsKey("body")) {
//   //     String htmlBody = selectedTemplate["body"] ?? "";
//   //
//   //     // Convert HTML to Markdown
//   //     //String markdownText = html2md.convert(htmlBody);
//   //     String markdownText = html2md.convert(htmlBody);
//   //
//   //     setState(() {
//   //       // Set the Quill editor with converted Markdown content
//   //       _quillController.document = quill.Document()..insert(0, markdownText);
//   //     });
//   //   }
//   // }
//
//
//   quill.Document htmlToQuillDelta(String html) {
//     dom.Document doc = htmlParser.parse(html);
//     var delta = Delta();
//
//     void parseNode(dom.Node node, {Map<String, dynamic>? parentAttributes}) {
//       if (node is dom.Element) {
//         Map<String, dynamic> attributes = {};
//
//         // Inherit styles from parent
//         if (parentAttributes != null) {
//           attributes.addAll(parentAttributes);
//         }
//
//         String tag = node.localName ?? '';
//
//         // Handle lists (bullet and ordered lists)
//         if (tag == "ul" || tag == "ol") {
//           node.children.forEach((child) {
//             if (child.localName == "li") {
//               // For lists, directly add "list" attribute
//               delta.insert(child.text + "\n", {"list": tag == "ul" ? "bullet" : "ordered"});
//             }
//           });
//           return; // Return after handling the list, so no further processing is done for this node
//         }
//
//         // Apply text formatting (only after list is handled)
//         if (tag == "b" || tag == "strong") attributes["bold"] = true;
//         if (tag == "i" || tag == "em") attributes["italic"] = true;
//         if (tag == "u") attributes["underline"] = true;
//         if (tag == "h1") attributes["header"] = 1;
//         if (tag == "h2") attributes["header"] = 2;
//         if (tag == "h3") attributes["header"] = 3;
//         if (tag == "blockquote") attributes["blockquote"] = true;
//
//         // Handle alignment styles (e.g., text-align)
//         if (node.attributes.containsKey("style")) {
//           String style = node.attributes["style"] ?? "";
//           final alignMatch = RegExp(r"text-align:\s*([^;]+);?").firstMatch(style);
//           if (alignMatch != null) {
//             attributes["align"] = alignMatch.group(1);
//           }
//         }
//
//         // Recursively parse children
//         if (node.nodes.isNotEmpty) {
//           for (var child in node.nodes) {
//             parseNode(child, parentAttributes: attributes);
//           }
//         } else {
//           String text = node.text.trim();
//           if (text.isNotEmpty) {
//             delta.insert(text + "\n", attributes);
//           }
//         }
//       } else if (node is dom.Text) {
//         String text = node.text.trim();
//         if (text.isNotEmpty) {
//           delta.insert(text + "\n", parentAttributes ?? {});
//         }
//       }
//     }
//
//     doc.body?.nodes.forEach(parseNode);
//
//     return quill.Document.fromDelta(delta);
//   }
//
//   void loadTemplateIntoQuill(
//       quill.QuillController controller, String htmlBody) {
//     String markdownText = html2md.convert(htmlBody); // Convert HTML to Markdown
//
//     // Set the converted text in Quill Editor
//     controller.document = quill.Document()..insert(0, markdownText);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Send New E-mail"),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Tenant Dropdown
//             DropdownButtonHideUnderline(
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 child: PopupMenuButton<String>(
//                   onSelected: (String
//                       tenantId) {}, // Do nothing here, handle in onChanged
//                   itemBuilder: (context) {
//                     return tenants.map((tenant) {
//                       return PopupMenuItem<String>(
//                         value: tenant['tenant_id'],
//                         child: StatefulBuilder(
//                           builder: (context, setStatePopup) {
//                             return InkWell(
//                               onTap: () {
//                                 setStatePopup(() {
//                                   if (selectedTenants
//                                       .contains(tenant['tenant_id'])) {
//                                     selectedTenants.remove(tenant['tenant_id']);
//                                   } else {
//                                     selectedTenants.add(tenant['tenant_id']);
//                                   }
//                                 });
//                                 setState(() {}); // Update parent widget
//                               },
//                               child: Row(
//                                 children: [
//                                   Checkbox(
//                                     value: selectedTenants
//                                         .contains(tenant['tenant_id']),
//                                     onChanged: (bool? value) {
//                                       setStatePopup(() {
//                                         if (value == true) {
//                                           selectedTenants
//                                               .add(tenant['tenant_id']);
//                                         } else {
//                                           selectedTenants
//                                               .remove(tenant['tenant_id']);
//                                         }
//                                       });
//                                       setState(() {}); // Ensure UI updates
//                                     },
//                                   ),
//                                   Expanded(
//                                     child: Text(
//                                       tenant['tenant_firstName'] +
//                                           " " +
//                                           tenant['tenant_lastName'],
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       );
//                     }).toList();
//                   },
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         selectedTenants.isEmpty
//                             ? "Select Tenants"
//                             : selectedTenants
//                                 .map((id) {
//                                   final tenant = tenants.firstWhere(
//                                       (tenant) => tenant['tenant_id'] == id);
//                                   return tenant != null
//                                       ? "${tenant['tenant_firstName']} ${tenant['tenant_lastName']}"
//                                       : "";
//                                 })
//                                 .where((name) => name.isNotEmpty)
//                                 .join(", "),
//                       ),
//                       Icon(Icons.arrow_drop_down),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//
//             // Subject Input Field
//             TextField(
//               controller: _subjectController,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: "Subject",
//               ),
//             ),
//             SizedBox(height: 10),
//
//             // Event Type Dropdown
//             DropdownButtonFormField<String>(
//               value: selectedEvent,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 // labelText: "Select Event",
//               ),
//               items: events.map((event) {
//                 return DropdownMenuItem(
//                   value: event,
//                   child: Text(event),
//                 );
//               }).toList(),
//               onChanged: onEventSelected,
//             ),
//             SizedBox(height: 10),
//             DropdownButtonFormField<String>(
//               value: selectedTemplateName,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 //  labelText: "Select Template",
//               ),
//               items: filteredTemplates.map((template) {
//                 return DropdownMenuItem(
//                   value: template["name"] as String,
//                   child: Text(template["name"] as String),
//                 );
//               }).toList(),
//               onChanged: onTemplateSelected,
//             ),
//             SizedBox(height: 10),
//             // Email Body Label
//             Text("Body", style: TextStyle(fontWeight: FontWeight.bold)),
//             SizedBox(height: 5),
//
//             // CKEditor-style Rich Text Editor
//             Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey),
//                 borderRadius: BorderRadius.circular(5),
//               ),
//               child: Column(
//                 children: [
//                   quill.QuillSimpleToolbar(
//                       controller: _quillController,
//                       configurations: quill.QuillSimpleToolbarConfigurations(
//                         multiRowsDisplay: false, // Keep toolbar in one row
//                         showAlignmentButtons: true,
//                         showFontFamily: true,
//                         showFontSize: true,
//                         showColorButton: true,
//                         showBackgroundColorButton: true,
//                         showListCheck: true,
//                         showSubscript: true,
//                         showSuperscript: true,
//                         showHeaderStyle: true,
//                         showDirection: true,
//                         showInlineCode: true,
//                       )),
//                   SizedBox(
//                     height: 300,
//                     child: Padding(
//                       padding:
//                           const EdgeInsets.only(top: 8, right: 10, left: 10),
//                       child: quill.QuillEditor.basic(
//                         controller: _quillController,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             SizedBox(height: 20),
//
//             // Action Buttons
//             Row(
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     print("Send Email");
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                   ),
//                   child: Text("Send", style: TextStyle(color: Colors.white)),
//                 ),
//                 SizedBox(width: 10),
//                 OutlinedButton(
//                   onPressed: () {
//                     _subjectController.clear();
//                     _quillController.clear();
//                     setState(() {
//                       selectedTenant = null;
//                       selectedEvent = null;
//                     });
//                     Navigator.pop(context);
//                   },
//                   style: OutlinedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                   ),
//                   child: Text("Cancel"),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class EmailTemplateScreen extends StatefulWidget {
  @override
  _EmailTemplateScreenState createState() => _EmailTemplateScreenState();
}

class _EmailTemplateScreenState extends State<EmailTemplateScreen> {
  List<Map<String, dynamic>> templates = [];
  List<String> events = [];
  String? selectedTemplateId;
  final HtmlEditorController _htmlEditorController = HtmlEditorController();
  String htmlBody = ""; // Store HTML content

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
      Uri.parse("${Api_url}/api/templates/get/1736503150202"),
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
          htmlBody = data["template"]["body"]; // Get HTML content
          // _htmlEditorController
          //     .setText(replaceSpanTags(htmlBody)); // Set editor content
          _htmlEditorController.setText(htmlBody);
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
      "body": updatedHtmlBody, // Send updated HTML
      //"body": replaceFontTags(updatedHtmlBody), // Send updated HTML
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

  String replaceSpanTags(String html) {
    // Mapping class names to corresponding font sizes
    final Map<String, String> classToFontSizeMap = {
      'text-tiny': '1',
      'text-small': '2',
      'text-default': '3',
      'text-big': '5',
      'text-huge': '7',
    };

    // Regular expression to match <span class="X">...</span>
    return html.replaceAllMapped(
      RegExp(r'<span\s+class="(.*?)">(.*?)<\/span>', caseSensitive: false),
      (match) {
        String className = match.group(1) ?? ''; // Get class name
        String text = match.group(2) ?? ''; // Get inner text
        String? fontSize =
            classToFontSizeMap[className]; // Get corresponding font size

        // If class name is found in the map, replace with <font>, else keep original
        return fontSize != null
            ? '<font size="$fontSize">$text</font>'
            : match.group(0)!;
      },
    );
  }

  String replaceFontTags(String html) {
    // Mapping font sizes to corresponding class names
    final Map<String, String> fontSizeMap = {
      '1': 'text-tiny',
      '2': 'text-small',
      '3': 'text-default',
      '5': 'text-big',
      '7': 'text-huge',
    };

    // Regular expression to match <font size="X">...</font>
    return html.replaceAllMapped(
      RegExp(r'<font\s+size="(\d+)">(.*?)<\/font>', caseSensitive: false),
      (match) {
        String size = match.group(1) ?? ''; // Get font size
        String text = match.group(2) ?? ''; // Get inner text
        String? className = fontSizeMap[size]; // Get corresponding class

        // If the size is found in the map, replace with <span>, else keep original
        return className != null
            ? '<span class="$className">$text</span>'
            : match.group(0)!;
      },
    );
  }

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
      appBar: AppBar(title: Text("HTML Email Editor")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Dropdown for Templates
              Row(
                children: [
                  Text("Select Template",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedTemplateId,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedTemplateId = newValue;
                        var selectedTemplate = templates.firstWhere(
                          (template) => template["template_id"] == newValue,
                          orElse: () => {},
                        );
                        htmlBody = selectedTemplate["body"] ?? "";
                        _htmlEditorController.setText(htmlBody);
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

              SizedBox(height: 20),

              // Fix scroll issue by using SingleChildScrollView
              Row(
                children: [
                  SizedBox(
                    width: 2,
                  ),
                  Text(
                    "Body",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 4,
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: HtmlEditor(
                    controller: _htmlEditorController,
                    htmlEditorOptions: HtmlEditorOptions(
                      hint: "Edit your email content here...",
                      //  shouldEnsureVisible: true,
                    ),
                    otherOptions: OtherOptions(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(4),
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
                            _htmlEditorController.execCommand("formatBlock",
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
                            _htmlEditorController.execCommand("formatBlock",
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
                            PopupMenuItem(value: "1", child: Text("tiny")),
                            PopupMenuItem(value: "2", child: Text("small")),
                            PopupMenuItem(value: "3", child: Text("default")),
                            PopupMenuItem(value: "5", child: Text("big")),
                            PopupMenuItem(value: "7", child: Text("huge")),
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
    );
  }
}

//"{"template_id":"1736503150202","admin_id":"1730957524276","name":"invitation ","subject":"Welcome to Smith test","body":"<h2 style=\"text-align:center;\"><a href=\"www.google.com\"><span style=\"color:hsl(270,94%,81%);\">hello </span></a>${<span style=\"color:hsl(0,75%,60%);\">Name</span>},</h2><p><span style=\"color:hsl(210,75%,60%);\">Welcome </span>to the ${CompanyName}</p><figure class=\"table\"><table><tbody><tr><td><strong>Name</strong></td><td><strong>Age</strong></td></tr><tr><td>test</td><td>12</td></tr></tbody></table></figure><blockquote><ul><li><i>here</i> is your credential&nbsp;<br>Email: ${EmailAddress}</li></ul></blockquote><ul><li><i><strong>Password</strong>:</i> ${Password}</li></ul><p>you can l<strong>ogin</strong> to your account via ${Url}</p>","type":"E-mail","mail_type":"Invitation","is_delete":false,"is_active":false,"createdAt":"2025-01-10T09:59:10.205Z","updatedAt":"2025-02-28T05:13:17.484Z"}"

