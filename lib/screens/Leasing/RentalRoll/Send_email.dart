import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

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
  @override
  void initState() {
    super.initState();

    fetchTenants();
  }

  List<String> events = ['Invitation', 'Lease Creation', 'Lease and Reminder'];
  List<Map<String, dynamic>> tenants = [];
  List selectedTenants = [];

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
                  onSelected: (String tenantId) {}, // Do nothing here, handle in onChanged
                  itemBuilder: (context) {
                    return tenants.map((tenant) {
                      return PopupMenuItem<String>(
                        value: tenant['tenant_id'],
                        child: StatefulBuilder(
                          builder: (context, setStatePopup) {
                            return InkWell(
                              onTap: () {
                                setStatePopup(() {
                                  if (selectedTenants.contains(tenant['tenant_id'])) {
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
                                    value: selectedTenants.contains(tenant['tenant_id']),
                                    onChanged: (bool? value) {
                                      setStatePopup(() {
                                        if (value == true) {
                                          selectedTenants.add(tenant['tenant_id']);
                                        } else {
                                          selectedTenants.remove(tenant['tenant_id']);
                                        }
                                      });
                                      setState(() {}); // Ensure UI updates
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      tenant['tenant_firstName'] + " " + tenant['tenant_lastName'],
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
                            : selectedTenants.map((id) {
                          final tenant = tenants.firstWhere(
                                (tenant) => tenant['tenant_id'] == id);
                          return tenant != null ? "${tenant['tenant_firstName']} ${tenant['tenant_lastName']}" : "";
                        }).where((name) => name.isNotEmpty).join(", "),
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
                labelText: "Event Type",
              ),
              items: events.map((event) {
                return DropdownMenuItem(value: event, child: Text(event));
              }).toList(),
              onChanged: (value) => setState(() => selectedEvent = value),
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
                  quill.QuillToolbar.simple(
                      configurations: quill.QuillSimpleToolbarConfigurations(
                    controller: _quillController,
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
                  Container(
                    height: 250,
                    child: quill.QuillEditor.basic(
                      controller: _quillController,
                      // readOnly: false, // Allow editing
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
