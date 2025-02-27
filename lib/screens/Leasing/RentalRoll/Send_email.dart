import 'dart:convert';
import 'package:flutter_quill/quill_delta.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as dom;

class SendEmailScreen extends StatefulWidget {
  final String leaseId;
  SendEmailScreen({required this.leaseId});
  @override
  _SendEmailScreenState createState() => _SendEmailScreenState();
}

class _SendEmailScreenState extends State<SendEmailScreen> {
  final _subjectController = TextEditingController();
  quill.QuillController _quillController = quill.QuillController.basic();

  String? selectedTenant;
  String? selectedEvent;
  String? selectedTemplateName;
  @override
  void initState() {
    super.initState();

    fetchTenants();
    fetchTemplates();
  }

  List<String> events = [
    'Invitation',
    'Lease creation',
    'Lease end Reminder',
    'Payment receipt',
    'Payment refund',
    'LateFee reminder',
    'Express Payment'
  ];
  List<Map<String, dynamic>> tenants = [];
  List selectedTenants = [];
  List<Map<String, dynamic>> templates = [];
  Map<String, dynamic>? selectedTemplate;
  List<Map<String, dynamic>> filteredTemplates = [];
  Future<void> fetchTenants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http.get(
        Uri.parse("${Api_url}/api/tenant/lease-tenant/${adminId}"),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $adminId",
        });
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["data"] != null) {
        setState(() {
          tenants = List<Map<String, dynamic>>.from(data["data"]);
        });
      }
    } else {
      throw Exception("Failed to load tenants");
    }
  }

//for templet
  Future<void> fetchTemplates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http.get(
        Uri.parse("${Api_url}/api/templates/get/1736503150202"),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $adminId",
        });
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // if (data["statusCode"] == 200) {
      //   setState(() {
      //     templates = List<Map<String, dynamic>>.from(data["data"]);
      //     events = templates.map((t) => t["name"] as String).toList();
      //   });
      // }
      if (data["statusCode"] == 200 && data.containsKey("template")) {
        setState(() {
          templates = [data["template"]]; // Store the single template in a list
          events = [data["template"]["name"] as String]; // Extract event name
        });
      }
    } else {
      print("Failed to load templates");
    }
  }

  void onEventSelected(String? value) {
    setState(() {
      selectedEvent = value;
      filteredTemplates = templates.where((t) => t["name"] == value).toList();
      selectedTemplateName = filteredTemplates.isNotEmpty
          ? filteredTemplates.first["name"] as String
          : null;
      updateQuillBody(selectedTemplateName);
    });
  }

  void onTemplateSelected(String? value) {
    setState(() {
      selectedTemplateName = value;
      updateQuillBody(value);
    });
  }

  void updateQuillBody(String? templateName) {
    if (templateName == null || filteredTemplates.isEmpty) return;

    final selectedTemplate = filteredTemplates.firstWhere(
      (t) => t["name"] == templateName,
      orElse: () => {},
    );

    if (selectedTemplate.isNotEmpty && selectedTemplate.containsKey("body")) {
      String htmlBody = selectedTemplate["body"] ?? "";

      // Convert HTML to Quill Delta
      quill.Document document = htmlToQuillDelta(htmlBody);

      setState(() {
        _quillController.document = document;
      });
    }
  }

  // void updateQuillBody(String? templateName) {
  //   if (templateName == null || filteredTemplates.isEmpty) return;
  //
  //   final selectedTemplate = filteredTemplates.firstWhere(
  //         (t) => t["name"] == templateName,
  //     orElse: () => {},
  //   );
  //
  //   if (selectedTemplate.isNotEmpty && selectedTemplate.containsKey("body")) {
  //     String htmlBody = selectedTemplate["body"] ?? "";
  //
  //     // Convert HTML to Markdown
  //     //String markdownText = html2md.convert(htmlBody);
  //     String markdownText = html2md.convert(htmlBody);
  //
  //     setState(() {
  //       // Set the Quill editor with converted Markdown content
  //       _quillController.document = quill.Document()..insert(0, markdownText);
  //     });
  //   }
  // }

  quill.Document htmlToQuillDelta(String html) {
    dom.Document doc = htmlParser.parse(html);
    var delta = Delta();

    void parseNode(dom.Node node, {Map<String, dynamic>? parentAttributes}) {
      if (node is dom.Element) {
        Map<String, dynamic> attributes = {};

        // Inherit styles from parent
        if (parentAttributes != null) {
          attributes.addAll(parentAttributes);
        }

        String tag = node.localName ?? '';

        // Apply text formatting
        if (tag == "b" || tag == "strong") attributes["bold"] = true;
        if (tag == "i" || tag == "em") attributes["italic"] = true;
        if (tag == "u") attributes["underline"] = true;
        if (tag == "h1") attributes["header"] = 1;
        if (tag == "h2") attributes["header"] = 2;
        if (tag == "h3") attributes["header"] = 3;
        if (tag == "blockquote") attributes["blockquote"] = true;

        // Handle alignment styles
        if (node.attributes.containsKey("style")) {
          String style = node.attributes["style"] ?? "";

          // Extract text alignment
          final alignMatch = RegExp(r"text-align:\s*([^;]+);?").firstMatch(style);
          if (alignMatch != null) {
            attributes["align"] = alignMatch.group(1);
          }
        }

        // Handle lists
        if (tag == "ul") {
          node.children.forEach((child) {
            if (child.localName == "li") {
              // Insert list item with inherited attributes
              delta.insert(child.text + "\n", {"list": "bullet", ...attributes});
            }
          });
          return;
        }

        if (tag == "ol") {
          node.children.asMap().forEach((index, child) {
            if (child.localName == "li") {
              // Insert ordered list item with inherited attributes
              delta.insert(child.text + "\n", {"list": "ordered", ...attributes});
            }
          });
          return;
        }

        // Recursively parse children
        if (node.nodes.isNotEmpty) {
          for (var child in node.nodes) {
            parseNode(child, parentAttributes: attributes);
          }
        } else {
          String text = node.text.trim();
          if (text.isNotEmpty) {
            delta.insert(text + "\n", attributes);
          }
        }
      } else if (node is dom.Text) {
        String text = node.text.trim();
        if (text.isNotEmpty) {
          delta.insert(text + "\n", parentAttributes ?? {});
        }
      }
    }

    doc.body?.nodes.forEach(parseNode);

    return quill.Document.fromDelta(delta);
  }

  void loadTemplateIntoQuill(
      quill.QuillController controller, String htmlBody) {
    String markdownText = html2md.convert(htmlBody); // Convert HTML to Markdown

    // Set the converted text in Quill Editor
    controller.document = quill.Document()..insert(0, markdownText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Send New E-mail"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tenant Dropdown
            DropdownButtonHideUnderline(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: PopupMenuButton<String>(
                  onSelected: (String
                      tenantId) {}, // Do nothing here, handle in onChanged
                  itemBuilder: (context) {
                    return tenants.map((tenant) {
                      return PopupMenuItem<String>(
                        value: tenant['tenant_id'],
                        child: StatefulBuilder(
                          builder: (context, setStatePopup) {
                            return InkWell(
                              onTap: () {
                                setStatePopup(() {
                                  if (selectedTenants
                                      .contains(tenant['tenant_id'])) {
                                    selectedTenants.remove(tenant['tenant_id']);
                                  } else {
                                    selectedTenants.add(tenant['tenant_id']);
                                  }
                                });
                                setState(() {}); // Update parent widget
                              },
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: selectedTenants
                                        .contains(tenant['tenant_id']),
                                    onChanged: (bool? value) {
                                      setStatePopup(() {
                                        if (value == true) {
                                          selectedTenants
                                              .add(tenant['tenant_id']);
                                        } else {
                                          selectedTenants
                                              .remove(tenant['tenant_id']);
                                        }
                                      });
                                      setState(() {}); // Ensure UI updates
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      tenant['tenant_firstName'] +
                                          " " +
                                          tenant['tenant_lastName'],
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    }).toList();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedTenants.isEmpty
                            ? "Select Tenants"
                            : selectedTenants
                                .map((id) {
                                  final tenant = tenants.firstWhere(
                                      (tenant) => tenant['tenant_id'] == id);
                                  return tenant != null
                                      ? "${tenant['tenant_firstName']} ${tenant['tenant_lastName']}"
                                      : "";
                                })
                                .where((name) => name.isNotEmpty)
                                .join(", "),
                      ),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),

            // Subject Input Field
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Subject",
              ),
            ),
            SizedBox(height: 10),

            // Event Type Dropdown
            DropdownButtonFormField<String>(
              value: selectedEvent,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                // labelText: "Select Event",
              ),
              items: events.map((event) {
                return DropdownMenuItem(
                  value: event,
                  child: Text(event),
                );
              }).toList(),
              onChanged: onEventSelected,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedTemplateName,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                //  labelText: "Select Template",
              ),
              items: filteredTemplates.map((template) {
                return DropdownMenuItem(
                  value: template["name"] as String,
                  child: Text(template["name"] as String),
                );
              }).toList(),
              onChanged: onTemplateSelected,
            ),
            SizedBox(height: 10),
            // Email Body Label
            Text("Body", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),

            // CKEditor-style Rich Text Editor
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: [
                  quill.QuillSimpleToolbar(
                      controller: _quillController,
                      configurations: quill.QuillSimpleToolbarConfigurations(
                        multiRowsDisplay: false, // Keep toolbar in one row
                        showAlignmentButtons: true,
                        showFontFamily: true,
                        showFontSize: true,
                        showColorButton: true,
                        showBackgroundColorButton: true,
                        showListCheck: true,
                        showSubscript: true,
                        showSuperscript: true,
                        showHeaderStyle: true,
                        showDirection: true,
                        showInlineCode: true,
                      )),
                  SizedBox(
                    height: 300,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 8, right: 10, left: 10),
                      child: quill.QuillEditor.basic(
                        controller: _quillController,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    print("Send Email");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text("Send", style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {
                    _subjectController.clear();
                    _quillController.clear();
                    setState(() {
                      selectedTenant = null;
                      selectedEvent = null;
                    });
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text("Cancel"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
