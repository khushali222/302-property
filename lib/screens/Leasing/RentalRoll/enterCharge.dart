import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/lease.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';

import '../../../model/EnterChargeModel.dart';
import '../../../widgets/custom_drawer.dart';
class enterCharge extends StatefulWidget {
  final String leaseId;

  const enterCharge({required this.leaseId});

  @override
  State<enterCharge> createState() => _enterChargeState();
}

class _enterChargeState extends State<enterCharge> {
  bool _isLoading = false;
  final TextEditingController _startDate = TextEditingController();
  final TextEditingController Amount = TextEditingController();
  final TextEditingController Memo = TextEditingController();
  late Future<Map<String, List<String>>> futureDropdownData;
  String? validationMessage;
  Map<String, List<String>> categorizedData = {};
  String? selectedAccount;
  bool isLoading = true;
  bool hasError = false;

  List<Map<String, String>> tenants = [];
  String? selectedTenantId;

  @override
  void initState() {
    super.initState();
    fetchTenants();
    fetchDropdownData();
  }

  Future<void> fetchTenants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString("adminId");
    final response = await http.get(
      Uri.parse('$Api_url/api/leases/lease_tenant/${widget.leaseId}'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      final List<Map<String, String>> fetchedTenants = [];

      for (var tenant in data['data']['tenants']) {
        fetchedTenants.add({
          'tenant_id': tenant['tenant_id'],
          'tenant_name':
              '${tenant['tenant_firstName']} ${tenant['tenant_lastName']}',
        });
      }

      setState(() {
        tenants = fetchedTenants;
      });
    } else {
      throw Exception('Failed to load tenants');
    }
  }

  Future<void> fetchDropdownData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String adminId = prefs.getString('adminId') ?? '';
      String? token = prefs.getString('token');
      print(token);
      print('lease ${widget.leaseId}');
      String? id = prefs.getString("adminId");
      final response = await http.get(
        Uri.parse('$Api_url/api/accounts/accounts/$adminId'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body)['data'];
        Map<String, List<String>> fetchedData = {};
        // Adding static items to the "LIABILITY ACCOUNT" category
        fetchedData["Liability Account"] = [
          "Late Fee Income",
          "Pre-payments",
          "Security Deposit",
          'Rent Income'
        ];

        for (var item in jsonResponse) {
          String chargeType = item['charge_type'];
          String account = item['account'];

          if (!fetchedData.containsKey(chargeType)) {
            fetchedData[chargeType] = [];
          }
          fetchedData[chargeType]!.add(account);
        }

        setState(() {
          categorizedData = fetchedData;
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> rows = [];
  double totalAmount = 0.0;
  void addRow() {
    setState(() {
      rows.add({
        'account': null,
        'charge_type': null,
        'amount': 0.0,
        'memo': Memo.text,
        'date': _startDate.text,
      });
    });
  }

  void deleteRow(int index) {
    setState(() {
      totalAmount -= rows[index]['amount'];
      rows.removeAt(index);
    });
    validateAmounts();
  }

  void updateAmount(int index, String value) {
    setState(() {
      double amount = double.tryParse(value) ?? 0.0;
      totalAmount -= rows[index]['amount'];
      rows[index]['amount'] = amount;
      totalAmount += amount;
    });
    validateAmounts();
  }

  void validateAmounts() {
    double enteredAmount = double.tryParse(Amount.text) ?? 0.0;
    if (enteredAmount != totalAmount) {
      setState(() {
        validationMessage =
            "The charge's amount must match the total applied to balance. The difference is ${(enteredAmount - totalAmount).abs().toStringAsFixed(2)}";
      });
    } else {
      setState(() {
        validationMessage = null;
      });
    }
  }

  List<File> _pdfFiles = [];

  List<String> _uploadedFileNames = [];

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
        if (fileName != null) {
          _uploadedFileNames.add(fileName);
        }
      });
    } catch (e) {
      print('PDF upload failed: $e');
    }
  }

  Future<String?> uploadPdf(File pdfFile) async {
    print(pdfFile.path);
    //final String uploadUrl = '${Api_url}/api/images/upload';
    final String uploadUrl = '${image_upload_url}/api/images/upload';

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

  final _formKey = GlobalKey<FormState>();
  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText1,
        ),

      ],
    );
  }
  final FocusNode _nodeText1 = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget_302.App_Bar(context: context),
        backgroundColor: Colors.white,
        drawer:CustomDrawer(currentpage: "Rent Roll",dropdown: true,),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding:  EdgeInsets.only(left:MediaQuery.of(context).size.width < 500 ? 16 : 35,right:MediaQuery.of(context).size.width < 500 ? 16 : 35 ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Container(
                        height: 50.0,
                        padding: const EdgeInsets.only(top: 10, left: 10),
                        width: MediaQuery.of(context).size.width * .91,
                        margin: const EdgeInsets.only(bottom: 6.0),
                        //Same as `blurRadius` i guess
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: const Color.fromRGBO(21, 43, 81, 1),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: const Text(
                          "Add Charge",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const SizedBox(
                          height: 8,
                        ),
                        if(MediaQuery.of(context).size.width < 500)
                        const Text('Received From *',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        if(MediaQuery.of(context).size.width < 500)
                        const SizedBox(
                          height: 8,
                        ),
                        if(MediaQuery.of(context).size.width < 500)
                        tenants.isEmpty
                            ? const Center(
                                child: SpinKitFadingCircle(
                                  color: Colors.black,
                                  size: 50.0,
                                ),
                              )
                            : DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: const Text('Select Tenant'),
                                  value: selectedTenantId,
                                  items: tenants.map((tenant) {
                                    return DropdownMenuItem<String>(
                                      value: tenant['tenant_id'],
                                      child: Text(tenant['tenant_name']!),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedTenantId = value;
                                    });
                                    print(
                                        'Selected tenant_id: $selectedTenantId');
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    height: 45,
                                    width: 170,
                                    padding: const EdgeInsets.only(
                                        left: 14, right: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: Colors.white,
                                    ),
                                    elevation: 2,
                                  ),
                                  iconStyleData: const IconStyleData(
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                    ),
                                    iconSize: 24,
                                    iconEnabledColor: Color(0xFFb0b6c3),
                                    iconDisabledColor: Colors.grey,
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: Colors.white,
                                    ),
                                    scrollbarTheme: ScrollbarThemeData(
                                      radius: const Radius.circular(6),
                                      thickness: MaterialStateProperty.all(6),
                                      thumbVisibility:
                                          MaterialStateProperty.all(true),
                                    ),
                                  ),
                                  menuItemStyleData: const MenuItemStyleData(
                                    height: 40,
                                    padding:
                                        EdgeInsets.only(left: 14, right: 14),
                                  ),
                                ),
                              ),
                        if(MediaQuery.of(context).size.width < 500)
                        const SizedBox(
                          height: 20,
                        ),
                        if(MediaQuery.of(context).size.width < 500)
                        const Text('Date',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        if(MediaQuery.of(context).size.width < 500)
                        const SizedBox(
                          height: 8,
                        ),
                        if(MediaQuery.of(context).size.width < 500)
                        CustomTextField(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                              locale: const Locale('en', 'US'),
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Color.fromRGBO(21, 43, 83,
                                          1), // header background color
                                      onPrimary:
                                          Colors.white, // header text color
                                      onSurface: Color.fromRGBO(
                                          21, 43, 83, 1), // body text color
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: const Color.fromRGBO(
                                            21, 43, 83, 1), // button text color
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedDate != null) {
                              String formattedDate =
                                  "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                              setState(() {
                                _startDate.text = formattedDate;
                              });
                            }
                          },
                          readOnnly: true,
                          suffixIcon: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.date_range_rounded)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select start date';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                          hintText: 'dd-mm-yyyy',
                          controller: _startDate,
                        ),
                        if(MediaQuery.of(context).size.width < 500)
                        const SizedBox(
                          height: 8,
                        ),
                        if(MediaQuery.of(context).size.width > 500)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // First Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Received From *',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey)),
                                      SizedBox(height: 8),
                                      tenants.isEmpty
                                          ? const Center(
                                        child: SpinKitFadingCircle(
                                          color: Colors.black,
                                          size: 50.0,
                                        ),
                                      )
                                          : DropdownButtonHideUnderline(
                                        child: DropdownButton2<String>(
                                          isExpanded: true,
                                          hint: const Text('Select Tenant'),
                                          value: selectedTenantId,
                                          items: tenants.map((tenant) {
                                            return DropdownMenuItem<String>(
                                              value: tenant['tenant_id'],
                                              child: Text(tenant['tenant_name']!),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedTenantId = value;
                                            });
                                            print(
                                                'Selected tenant_id: $selectedTenantId');
                                          },
                                          buttonStyleData: ButtonStyleData(
                                            height: 50,
                                            width: 200,
                                            padding: const EdgeInsets.only(
                                                left: 14, right: 14),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(6),
                                              color: Colors.white,
                                            ),
                                            elevation: 2,
                                          ),
                                          iconStyleData: const IconStyleData(
                                            icon: Icon(
                                              Icons.arrow_drop_down,
                                            ),
                                            iconSize: 24,
                                            iconEnabledColor: Color(0xFFb0b6c3),
                                            iconDisabledColor: Colors.grey,
                                          ),
                                          dropdownStyleData: DropdownStyleData(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(6),
                                              color: Colors.white,
                                            ),
                                            scrollbarTheme: ScrollbarThemeData(
                                              radius: const Radius.circular(6),
                                              thickness: MaterialStateProperty.all(6),
                                              thumbVisibility:
                                              MaterialStateProperty.all(true),
                                            ),
                                          ),
                                          menuItemStyleData: const MenuItemStyleData(
                                            height: 40,
                                            padding:
                                            EdgeInsets.only(left: 14, right: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                // Second Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Date',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey)),
                                      SizedBox(height: 5),
                                      CustomTextField(
                                        onTap: () async {
                                          DateTime? pickedDate = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2101),
                                            locale: const Locale('en', 'US'),
                                            builder: (BuildContext context, Widget? child) {
                                              return Theme(
                                                data: ThemeData.light().copyWith(
                                                  colorScheme: const ColorScheme.light(
                                                    primary: Color.fromRGBO(21, 43, 83,
                                                        1), // header background color
                                                    onPrimary:
                                                    Colors.white, // header text color
                                                    onSurface: Color.fromRGBO(
                                                        21, 43, 83, 1), // body text color
                                                  ),
                                                  textButtonTheme: TextButtonThemeData(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: Colors.white,
                                                      backgroundColor: const Color.fromRGBO(
                                                          21, 43, 83, 1), // button text color
                                                    ),
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );
                                          if (pickedDate != null) {
                                            String formattedDate =
                                                "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                                            setState(() {
                                              _startDate.text = formattedDate;
                                            });
                                          }
                                        },
                                        readOnnly: true,
                                        suffixIcon: IconButton(
                                            onPressed: () {},
                                            icon: const Icon(Icons.date_range_rounded)),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please select start date';
                                          }
                                          return null;
                                        },
                                        keyboardType: TextInputType.text,
                                        hintText: 'dd-mm-yyyy',
                                        controller: _startDate,
                                      ),
                                      SizedBox(height: 5),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text('Amount',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        const SizedBox(
                          height: 8,
                        ),
                        CustomTextField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter amount';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          hintText: 'Enter Amount',
                          controller: Amount,
                          onChanged: (value) => validateAmounts(),
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(
                          height: 8,
                        ),
                        const Text('Memo',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        const SizedBox(
                          height: 8,
                        ),
                        CustomTextField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter memo';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                          hintText: 'Enter Memo',
                          controller: Memo,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('Apply Payment to Balances',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  const SizedBox(
                    height: 10,
                  ),
                  // isLoading
                  //     ? const Center(
                  //         child: SpinKitFadingCircle(
                  //           color: Colors.black,
                  //           size: 50.0,
                  //         ),
                  //       )
                  //     : hasError
                  //         ? const Center(child: Text('Failed to load data'))
                  //         : Table(
                  //             border: TableBorder.all(width: 1),
                  //             columnWidths: const {
                  //               0: FlexColumnWidth(2),
                  //               1: FlexColumnWidth(2),
                  //               2: FlexColumnWidth(1),
                  //             },
                  //             children: [
                  //               const TableRow(children: [
                  //                 Padding(
                  //                   padding: EdgeInsets.all(8.0),
                  //                   child: Center(
                  //                     child: Text('Account',
                  //                         style: TextStyle(
                  //                             color:
                  //                                 Color.fromRGBO(21, 43, 83, 1),
                  //                             fontWeight: FontWeight.bold)),
                  //                   ),
                  //                 ),
                  //                 Padding(
                  //                   padding: EdgeInsets.all(8.0),
                  //                   child: Center(
                  //                     child: Text('Amount',
                  //                         style: TextStyle(
                  //                             color:
                  //                                 Color.fromRGBO(21, 43, 83, 1),
                  //                             fontWeight: FontWeight.bold)),
                  //                   ),
                  //                 ),
                  //                 Padding(
                  //                   padding: EdgeInsets.all(8.0),
                  //                   child: Center(
                  //                     child: Text('Actions',
                  //                         style: TextStyle(
                  //                             color:
                  //                                 Color.fromRGBO(21, 43, 83, 1),
                  //                             fontWeight: FontWeight.bold)),
                  //                   ),
                  //                 ),
                  //               ]),
                  //               ...rows.asMap().entries.map((entry) {
                  //                 int index = entry.key;
                  //                 Map<String, dynamic> row = entry.value;
                  //                 return TableRow(children: [
                  //                   Padding(
                  //                     padding: const EdgeInsets.all(8.0),
                  //                     child: DropdownButtonHideUnderline(
                  //                       child: DropdownButton2<String>(
                  //                         isExpanded: true,
                  //                         value: row['account'],
                  //                         items: [
                  //                           ...categorizedData.entries
                  //                               .expand((entry) {
                  //                             return [
                  //                               DropdownMenuItem<String>(
                  //                                 enabled: false,
                  //                                 child: Text(
                  //                                   entry.key,
                  //                                   style: const TextStyle(
                  //                                     fontWeight:
                  //                                         FontWeight.bold,
                  //                                     color: Color.fromRGBO(
                  //                                         21, 43, 81, 1),
                  //                                   ),
                  //                                 ),
                  //                               ),
                  //                               ...entry.value.map((item) {
                  //                                 return DropdownMenuItem<
                  //                                     String>(
                  //                                   value: item,
                  //                                   child: Padding(
                  //                                     padding:
                  //                                         const EdgeInsets.only(
                  //                                             left: 16.0),
                  //                                     child: Text(
                  //                                       item,
                  //                                       style: const TextStyle(
                  //                                         color: Colors.black,
                  //                                         fontWeight:
                  //                                             FontWeight.w400,
                  //                                       ),
                  //                                     ),
                  //                                   ),
                  //                                 );
                  //                               }).toList(),
                  //                             ];
                  //                           }).toList(),
                  //                         ],
                  //                         onChanged: (value) {
                  //                           String? chargeType;
                  //                           for (var entry
                  //                               in categorizedData.entries) {
                  //                             if (entry.value.contains(value)) {
                  //                               chargeType = entry.key;
                  //                               break;
                  //                             }
                  //                           }
                  //                           setState(() {
                  //                             rows[index]['account'] = value;
                  //                             rows[index]['charge_type'] =
                  //                                 chargeType;
                  //                           });
                  //                         },
                  //                         buttonStyleData: ButtonStyleData(
                  //                           height: 45,
                  //                           width: 220,
                  //                           padding: const EdgeInsets.only(
                  //                               left: 14, right: 14),
                  //                           decoration: BoxDecoration(
                  //                             borderRadius:
                  //                                 BorderRadius.circular(6),
                  //                             color: Colors.white,
                  //                           ),
                  //                           elevation: 2,
                  //                         ),
                  //                         iconStyleData: const IconStyleData(
                  //                           icon: Icon(Icons.arrow_drop_down),
                  //                           iconSize: 24,
                  //                           iconEnabledColor: Color(0xFFb0b6c3),
                  //                           iconDisabledColor: Colors.grey,
                  //                         ),
                  //                         dropdownStyleData: DropdownStyleData(
                  //                           width: 250,
                  //                           decoration: BoxDecoration(
                  //                             borderRadius:
                  //                                 BorderRadius.circular(6),
                  //                             color: Colors.white,
                  //                           ),
                  //                           scrollbarTheme: ScrollbarThemeData(
                  //                             radius: const Radius.circular(6),
                  //                             thickness:
                  //                                 MaterialStateProperty.all(6),
                  //                             thumbVisibility:
                  //                                 MaterialStateProperty.all(
                  //                                     true),
                  //                           ),
                  //                         ),
                  //                         hint: const Text('Select an account'),
                  //                       ),
                  //                     ),
                  //                   ),
                  //                   Padding(
                  //                     padding: const EdgeInsets.all(8.0),
                  //                     child: TextField(
                  //                       keyboardType: TextInputType.number,
                  //                       onChanged: (value) =>
                  //                           updateAmount(index, value),
                  //                       decoration: const InputDecoration(
                  //                         border: OutlineInputBorder(),
                  //                         hintText: 'Enter amount',
                  //                       ),
                  //                     ),
                  //                   ),
                  //                   Padding(
                  //                     padding: const EdgeInsets.all(8.0),
                  //                     child: IconButton(
                  //                       icon: const Icon(Icons.delete,
                  //                           color: Colors.red),
                  //                       onPressed: () => deleteRow(index),
                  //                     ),
                  //                   ),
                  //                 ]);
                  //               }).toList(),
                  //               TableRow(children: [
                  //                 const Padding(
                  //                   padding: EdgeInsets.all(8.0),
                  //                   child: Text('Total',
                  //                       style: TextStyle(
                  //                           fontWeight: FontWeight.bold)),
                  //                 ),
                  //                 Padding(
                  //                   padding: const EdgeInsets.all(8.0),
                  //                   child: Text(
                  //                       '\$${totalAmount.toStringAsFixed(2)}'),
                  //                 ),
                  //                 const SizedBox.shrink(),
                  //               ]),
                  //               TableRow(children: [
                  //                 Padding(
                  //                   padding: const EdgeInsets.all(8.0),
                  //                   child: Container(
                  //                     height: 34,
                  //                     decoration: BoxDecoration(
                  //                         color: Colors.white,
                  //                         border: Border.all(width: 1),
                  //                         borderRadius:
                  //                             BorderRadius.circular(10.0)),
                  //                     child: ElevatedButton(
                  //                       style: ElevatedButton.styleFrom(
                  //                           shape: RoundedRectangleBorder(
                  //                               borderRadius:
                  //                                   BorderRadius.circular(
                  //                                       10.0)),
                  //                           elevation: 0,
                  //                           backgroundColor: Colors.white),
                  //                       onPressed: addRow,
                  //                       child: const Text(
                  //                         'Add Row',
                  //                         style: TextStyle(
                  //                           color:
                  //                               Color.fromRGBO(21, 43, 83, 1),
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ),
                  //                 const SizedBox.shrink(),
                  //                 const SizedBox.shrink(),
                  //               ]),
                  //             ],
                  //           ),
                  isLoading
                      ? const Center(
                    child: SpinKitFadingCircle(
                      color: Colors.black,
                      size: 50.0,
                    ),
                  )
                      : hasError
                      ? const Center(child: Text('Failed to load data'))
                      : Table(
                    border: TableBorder.all(width: 1),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(1),
                    },
                    children: [
                      const TableRow(children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text('Account',
                                style: TextStyle(
                                    color:
                                    Color.fromRGBO(21, 43, 83, 1),
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text('Amount',
                                style: TextStyle(
                                    color:
                                    Color.fromRGBO(21, 43, 83, 1),
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text('Actions',
                                style: TextStyle(
                                    color:
                                    Color.fromRGBO(21, 43, 83, 1),
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ]),
                      ...rows.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, dynamic> row = entry.value;
                        return TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                style: TextStyle(fontSize: 14),
                                value: row['account'],
                                items: [
                                  ...categorizedData.entries
                                      .expand((entry) {
                                    return [
                                      DropdownMenuItem<String>(
                                        enabled: false,
                                        child: Text(
                                          entry.key,
                                          style: const TextStyle(
                                            fontWeight:
                                            FontWeight.bold,
                                            color: Color.fromRGBO(
                                                21, 43, 81, 1),
                                          ),
                                        ),
                                      ),
                                      ...entry.value.map((item) {
                                        return DropdownMenuItem<
                                            String>(
                                          value: item,
                                          child: Padding(
                                            padding:
                                            const EdgeInsets.only(
                                                left: 0.0),
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight:
                                                FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ];
                                  }).toList(),
                                ],
                                onChanged: (value) {
                                  String? chargeType;
                                  for (var entry
                                  in categorizedData.entries) {
                                    if (entry.value.contains(value)) {
                                      chargeType = entry.key;
                                      break;
                                    }
                                  }
                                  setState(() {
                                    rows[index]['account'] = value;
                                    rows[index]['charge_type'] =
                                        chargeType;
                                  });
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 50,
                                  width: 220,
                                  padding: const EdgeInsets.only(
                                      left: 8, right: 5),
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
                                  width: 250,
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
                                hint: const Text('Select an account'),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height:40,
                                child: KeyboardActions(
                                  config: _buildConfig(context),
                                  child: TextField(
                                    focusNode: _nodeText1,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) =>
                                        updateAmount(index, value),
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Enter amount',
                                        hintStyle: TextStyle(fontSize: 14),

                                        contentPadding: EdgeInsets.only(top: 7,left: 7)
                                    ),

                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () => deleteRow(index),
                            ),
                          ),
                        ]);
                      }).toList(),
                      TableRow(children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Total',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              '\$${totalAmount.toStringAsFixed(2)}'),
                        ),
                        const SizedBox.shrink(),
                      ]),
                      TableRow(children: [
                        Padding(
                          padding:  EdgeInsets.only(left: MediaQuery.of(context).size.width < 500 ? 16 : 70,right: MediaQuery.of(context).size.width < 500 ? 16 : 70,top: 10,bottom: 10),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(width: 1),
                                borderRadius:
                                BorderRadius.circular(10.0)),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(
                                          10.0)),
                                  elevation: 0,
                                  backgroundColor: Colors.white),
                              onPressed: addRow,
                              child:  Text(
                                'Add Row',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width < 500 ? 16 : 18,
                                  color:
                                  Color.fromRGBO(21, 43, 83, 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox.shrink(),
                        const SizedBox.shrink(),
                      ]),
                    ],
                  ),
                  if (validationMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        validationMessage!,
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(21, 43, 83, 1),
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const Text('Upload Files',
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

                          const SizedBox(height: 10),
                          // Flexible(
                          //   fit: FlexFit.loose,
                          //   child: ListView.builder(
                          //     shrinkWrap: true,
                          //     itemCount: _uploadedFileNames.length,
                          //     itemBuilder: (context, index) {
                          //       return ListTile(
                          //         title: Text(_uploadedFileNames[index],
                          //             style: const TextStyle(
                          //                 fontSize: 16,
                          //                 fontWeight: FontWeight.w500,
                          //                 color: Color(0xFF748097))),
                          //         trailing: IconButton(
                          //             onPressed: () {
                          //               setState(() {
                          //                 _uploadedFileNames.removeAt(index);
                          //               });
                          //             },
                          //             icon: const FaIcon(
                          //               FontAwesomeIcons.remove,
                          //               color: Color(0xFF748097),
                          //             )),
                          //       );
                          //     },
                          //   ),
                          // ),
                          if (_uploadedFileNames.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Flexible(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _uploadedFileNames.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                      _uploadedFileNames[index],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF748097),
                                      ),
                                    ),
                                    trailing: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _uploadedFileNames.removeAt(index);
                                        });
                                      },
                                      icon: const FaIcon(
                                        FontAwesomeIcons.remove,
                                        color: Color(0xFF748097),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],

                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                     // SizedBox(width: 5,),
                      Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width < 500 ? 130 :150,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0)),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:blueColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8.0))),
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  String adminId =
                                      prefs.getString('adminId').toString();

                                  List<Entry> entryList = rows.map((row) {
                                    return Entry(
                                      account: row['account'],
                                      amount: row['amount']?.toInt() ?? 0,
                                      dueAmount:
                                          0, // Adjust according to your requirement
                                      memo: row['memo'],
                                      date: reverseFormatDate(row['date']),
                                      chargeType: row['charge_type'],
                                      isRepeatable:
                                          false, // Adjust according to your requirement
                                    );
                                  }).toList();

                                  int totalAmount =
                                      int.tryParse(Amount.text) ?? 0;
                                  Charge charge = Charge(
                                    adminId: adminId,
                                    isLeaseAdded: false,
                                    leaseId: widget.leaseId,
                                    tenantId: selectedTenantId!,
                                    totalAmount: totalAmount,
                                    uploadedFile: _uploadedFileNames,
                                    entry: entryList,
                                  );
                               print('file ${_uploadedFileNames}');

                                  LeaseRepository apiService =
                                      LeaseRepository();
                                  int statusCode =
                                      await apiService.postCharge(charge);

                                  if (statusCode == 200) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    Fluttertoast.showToast(
                                      msg: "Charge posted successfully",
                                    );
                                    Navigator.pop(context);
                                  } else {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    Fluttertoast.showToast(
                                      msg: "Failed to post charge",
                                    );
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }

                                  print('valid');
                                  print(selectedTenantId);
                                  print(rows);
                                  print(totalAmount);
                                  print(_startDate.text);
                                  print(Amount.text);
                                  print(Memo.text);
                                  print(_uploadedFileNames);

                                  //charges
                                } else {
                                  print('invalid');
                                  print(selectedTenantId);
                                  print(rows);
                                  print(totalAmount);
                                  print(_startDate.text);
                                  print(Amount.text);
                                  print(Memo.text);
                                }
                              },
                              child:  Text(
                                'Add charge',
                                style: TextStyle(color: Color(0xFFf7f8f9),
                                fontSize: MediaQuery.of(context).size.width < 500 ? 16 :18),
                              ))),
                      const SizedBox(
                        width: 8,
                      ),
                      Container(
                          height: 50,
                          width: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0)),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFffffff),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8.0))),
                              onPressed: () {
                                Navigator.pop(context);
                                // firstName.clear();
                                // lastName.clear();
                                // email.clear();
                                // mobileNumber.clear();
                                // bussinessNumber.clear();
                                // homeNumber.clear();
                                // telePhoneNumber.clear();
                                // _selectedProperty = null;
                                // _selectedUnit = null;
                              },
                              child:  Text(
                                'Cancel',
                                style: TextStyle(color:blueColor),
                              )))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
