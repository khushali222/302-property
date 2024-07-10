import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:http/http.dart' as http;

import '../Rental/Tenants/add_tenants.dart';

void main() {
  runApp(MaterialApp(
    home: DynamicCardScreen(),
  ));
}

class DynamicCardScreen extends StatefulWidget {

  @override
  _DynamicCardScreenState createState() => _DynamicCardScreenState();
}

class _DynamicCardScreenState extends State<DynamicCardScreen> {
  List<Map<String, dynamic>> rows = [];


  Map<String, List<Map<String, dynamic>>> groupedCharges = {};
  void addRow() {
    setState(() {
      rows.add({
        "accountController": TextEditingController(),
        "balanceController": TextEditingController(),
        "amountController": TextEditingController(),
        "selectedChargeId": null,
      });
    });
  }


  void removeRow(int index) {
    setState(() {
      rows.removeAt(index);
    });
  }

  List<DropdownMenuItem<String>> groupedItems = [];

  Future<void> fetchCharges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String adminId = prefs.getString('adminId').toString();
    final response = await http.get(Uri.parse('$Api_url/api/accounts/accounts/$adminId'), headers: {"authorization" : "CRM $token"});

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      categorizeCharges(data);
    } else {
      throw Exception('Failed to load charges');
    }
  }

  void categorizeCharges(List<dynamic> data) {
    final Map<String, List<Map<String, dynamic>>> categorizedData = {};

    categorizedData['LIABILITY ACCOUNT'] = [
      {'_id': 'static_1', 'account': 'Last-month payment'},
      {'_id': 'static_3', 'account': 'Pre-payment'},
      {'_id': 'static_2', 'account': 'Security deposit liability'},
    ];

    for (var charge in data) {
      String chargeType = charge['charge_type'];
      if (!categorizedData.containsKey(chargeType)) {
        categorizedData[chargeType] = [];
      }
      categorizedData[chargeType]!.add(charge);
    }

    setState(() {
      groupedCharges = categorizedData;
    });
  }
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _startDate = TextEditingController();
  final TextEditingController Amount = TextEditingController();
  final TextEditingController Memo = TextEditingController();
  List<Map<String, String>> tenants = [];
  String? selectedTenantId;

  @override
  void initState() {
    super.initState();
    fetchTenants();
    fetchCharges();
    /* fetchDropdownData().then((fetchedItems) {
      setState(() {
        items = fetchedItems;
        groupedItems = buildGroupedItems(items);
      });
    });*/
  }

  Future<void> fetchTenants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http
        .get(Uri.parse('$Api_url/api/leases/lease_tenant/${widget.hashCode}'),
      headers: {"authorization" : "CRM $token"},);

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

  String? _selectedChargeId;

  String? selectedValue;
  List<String> items = [];



  /*Future<List<String>> fetchDropdownData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String adminId = prefs.getString('adminId').toString();
    String? token = prefs.getString('token');
    print("$Api_url/api/accounts/accounts/$adminId");
    print("headers: {authorization : CRM $token}");
    final response =
    await http.get(Uri.parse('$Api_url/api/accounts/accounts/$adminId'),  headers: {"authorization" : "CRM $token"},);
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      List<String> fetchedItems =
      jsonResponse.map((item) => item['name'] as String).toList();

      // Add static items
      fetchedItems.addAll(['Yash', 'Jay']);

      return fetchedItems;
    } else {
      throw Exception('Failed to load data');
    }
  }*/

  List<DropdownMenuItem<String>> buildGroupedItems(List<String> items) {
    List<DropdownMenuItem<String>> result = [];

    // Add the Local group
    result.add(
      const DropdownMenuItem<String>(
        enabled: false,
        child: Text(
          'LIABILITY ACCOUNT',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color.fromRGBO(21, 43, 83, 1),
          ),
        ),
      ),
    );
    result.addAll(
      items.where((item) => item == 'Yash' || item == 'Jay').map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );

    // Add the Dynamic group
    result.add(
      const DropdownMenuItem<String>(
        enabled: false,
        child: Text(
          'RECURRING CHARGES',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color.fromRGBO(21, 43, 83, 1),
          ),
        ),
      ),
    );
    result.addAll(
      items.where((item) => item != 'Yash' && item != 'Jay').map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
    result.add(
      const DropdownMenuItem<String>(
        enabled: false,
        child: Text(
          'ONE TIME CHARGES',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color.fromRGBO(21, 43, 83, 1),
          ),
        ),
      ),
    );
    result.addAll(
      items.where((item) => item != 'Yash' && item != 'Jay').map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );

    return result;
  }
  String? _selectedPaymentMethod;
  final List<String> _paymentMethods = ['Card', 'Check', 'Cash', 'Ash'];

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic Card View'),
      ),
      body: SingleChildScrollView(
        controller:_scrollController,
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.only(left: 16,right: 16,top: 13,bottom: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Container(
                          height: 50.0,
                          padding: const EdgeInsets.only(top: 14, left: 10),
                          width: MediaQuery.of(context).size.width * .91,
                          margin: const EdgeInsets.only(bottom: 6.0),
                          //Same as `blurRadius` i guess
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: const Color.fromRGBO(21, 43, 81, 1),
                            boxShadow: [
                              const BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 1.0), //(x,y)
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          child: const Text(
                            "Add Payment",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromRGBO(21, 43, 83, 1),
                          ),
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            const Text('Received From *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(
                              height: 8,
                            ),
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
                                hint: Text('Select Resident'),
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
                            SizedBox(
                              height: 10,
                            ),
                            /*  DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: const Text('Select Name'),
                              value: selectedValue,
                              items: groupedItems,
                              onChanged: (value) {
                                setState(() {
                                  selectedValue = value;
                                });
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 45,
                                width: 160,
                                padding:
                                const EdgeInsets.only(left: 14, right: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
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
                                padding: EdgeInsets.only(left: 14, right: 14),
                              ),
                            ),
                          ),*/
                            groupedCharges.isEmpty
                                ? CircularProgressIndicator()
                                : DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: Text('Select Charge'),
                                value: _selectedChargeId,
                                items: groupedCharges.entries.expand((entry) {
                                  List<DropdownMenuItem<String>> items = [];
                                  items.add(DropdownMenuItem<String>(
                                    enabled: false,
                                    value: entry.key,
                                    child: Text(
                                      entry.key,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ));
                                  items.addAll(entry.value.map((charge) {
                                    return DropdownMenuItem<String>(
                                      value: charge['_id'],
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 16.0),
                                        child: Text(charge['account']),
                                      ),
                                    );
                                  }));
                                  return items;
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedChargeId = newValue;
                                  });
                                  print('Selected charge_id: $_selectedChargeId');
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 45,
                                  width: 200,
                                  padding: const EdgeInsets.only(left: 14, right: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
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
                                    borderRadius: BorderRadius.circular(6),
                                    color: Colors.white,
                                  ),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(6),
                                    thickness: MaterialStateProperty.all(6),
                                    thumbVisibility: MaterialStateProperty.all(true),
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 40,
                                  padding: EdgeInsets.only(left: 14, right: 14),
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 10,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            const Text('Date',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(
                              height: 8,
                            ),
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
                                                21,
                                                43,
                                                83,
                                                1), // button text color
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
                            const SizedBox(
                              height: 8,
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
                              keyboardType: TextInputType.text,
                              hintText: 'Enter Amount',
                              controller: Amount,
                            ),

                            const SizedBox(
                              height: 8,
                            ),
                            const Text('Payment Method',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(
                              height: 8,
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: Text('Select Method'),
                                value: _selectedPaymentMethod,
                                items: _paymentMethods.map((method) {
                                  return DropdownMenuItem<String>(
                                    value: method,
                                    child: Text(method),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedPaymentMethod = newValue;
                                    //_selectedPaymentMethod = addRow();
                                    if(_selectedPaymentMethod == 'Card')
                                    addRow();
                                    if(_selectedPaymentMethod == 'Check')
                                     Text("hello");
                                  });
                                  print('Selected payment method: $_selectedPaymentMethod');
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 45,
                                  width: 200,
                                  padding: const EdgeInsets.only(left: 14, right: 14),
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
                                    thumbVisibility: MaterialStateProperty.all(true),
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 40,
                                  padding: EdgeInsets.only(left: 14, right: 14),
                                ),
                              ),
                            ),
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
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                              height: 50,
                              width: 150,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF67758e),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8.0))),
                                  onPressed: () async {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      print('valid');
                                      print(selectedTenantId);

                                      //charges
                                    } else {
                                      print('invalid');
                                      print(selectedTenantId);
                                    }
                                  },
                                  child: const Text(
                                    'Create Applicant',
                                    style: TextStyle(color: Color(0xFFf7f8f9)),
                                  ))),
                          const SizedBox(
                            width: 8,
                          ),
                          Container(
                              height: 50,
                              width: 120,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFffffff),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8.0))),
                                  onPressed: () {
                                    // Navigator.pop(context);
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
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Color(0xFF748097)),
                                  ))),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...rows.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> row = entry.value;
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Card ${index + 1}', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    removeRow(index);
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.0),
                          Text("Account", style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 12,),
                          DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: Text('Select Charge'),
                              value: row['selectedChargeId'],
                              items: groupedCharges.entries.expand((entry) {
                                List<DropdownMenuItem<String>> items = [];
                                items.add(DropdownMenuItem<String>(
                                  enabled: false,
                                  value: entry.key,
                                  child: Text(
                                    entry.key,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ));
                                items.addAll(entry.value.map((charge) {
                                  return DropdownMenuItem<String>(
                                    value: charge['_id'],
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 16.0),
                                      child: Text(charge['account']),
                                    ),
                                  );
                                }));
                                return items;
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  row['selectedChargeId'] = newValue;
                                });
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 45,
                                width: 200,
                                padding: const EdgeInsets.only(left: 14, right: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
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
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                ),
                                scrollbarTheme: ScrollbarThemeData(
                                  radius: const Radius.circular(6),
                                  thickness: MaterialStateProperty.all(6),
                                  thumbVisibility: MaterialStateProperty.all(true),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                                padding: EdgeInsets.only(left: 14, right: 14),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.0),
                          buildTextField('Balance', 'Enter Balance', row['balanceController']),
                          SizedBox(height: 12.0),
                          buildTextField('Amount', 'Enter Amount', row['amountController']),
                          SizedBox(height: 12.0),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width: 10,),
                GestureDetector(
                  onTap: () async {
                    addRow();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height * .06,
                     // width: MediaQuery.of(context).size.width * .36,
                      width: MediaQuery.of(context).size.width * .36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Color.fromRGBO(21, 43, 81, 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: isLoading
                            ? SpinKitFadingCircle(
                          color: Colors.white,
                          size: 25.0,
                        )
                            : Text(
                          "Add Card",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context)
                                  .size
                                  .width *
                                  .035),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, String hintText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8.0),
        Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(5),
          child: Container(
            padding: EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: TextFormField(
              controller: controller,
             focusNode: FocusNode(),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
