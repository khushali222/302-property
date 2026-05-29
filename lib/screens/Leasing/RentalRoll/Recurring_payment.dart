import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/tenants.dart';
import '../../../Model/setting.dart';
import '../../../constant/constant.dart';
import 'addcard/CardModel.dart';
import '../../../model/LeaseSummary.dart';
import '../../../repository/lease.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_drawer.dart';
import '../../../widgets/titleBar.dart';
import 'addcard/AddCard.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';

class RecurringPayment extends StatefulWidget {
  // String leaseId;
  Data leaseData;
  RecurringPayment({super.key, required this.leaseData});

  @override
  State<RecurringPayment> createState() => _RecurringPaymentState();
}

class _RecurringPaymentState extends State<RecurringPayment> {
  // late Future<LeaseLedger?> _leaseLedgerFuture;

  List<int> customervaultid = [];
  List<BillingData> cardDetails = [];
  Map<int, List<Map<String?, dynamic?>>> tenantDropdowns =
      {}; // Stores dropdown values per tenant
  double totalAmount = 0.0; // Store total amount
  List<Setting4> accounts = [];
  @override
  void initState() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        print(result);
        _connectivityResult = result;
      });
    });
    checkInternet();
    // TODO: implement initState
    fetchAccounts();
    getAllTenantCardData();

    super.initState();
  }

  void getAllTenantCardData() async {
    setState(() {
      isLoading = true;
    });
    if (widget.leaseData.tenantData != null &&
        widget.leaseData.tenantData!.isNotEmpty) {
      List<String> tenantIds = widget.leaseData.tenantData!
          .map((tenant) => tenant.tenantId!)
          .toList();

      for (String tenantId in tenantIds) {
        await fetchcreditcard(tenantId);
        // fetchExistingCards(tenantId,widget.leaseData.leaseId!);
      }

      print(cardDetails.length);
      print(customervaultid);
      print(tenantIds);
      // getcards();
      setState(() {
        for (int i = 0; i < tenantIds.length; i++) {
          tenantDropdowns[i] = [
            {
              "selectedCard": null,
              "selectedDay": null,
              "selectedAccount": null,
              "amount": TextEditingController()
            }
          ];
        }

        isLoading = false;
      });
    }
  }

  String totalamount = '';
  ConnectivityResult? _connectivityResult;
  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  void fetchAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');

    final response = await apiGet(
      Uri.parse('${Api_url}/api/accounts/accounts/$id'),
      headers: {
        'authorization': 'CRM $token',
        'id': 'CRM $id',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      setState(() {
        accounts.add(Setting4(
            account: 'Rent Income',
            chargeType: 'Recurring Charge',
            createdAt: "123"));
        accounts.addAll(
            jsonResponse.map((data) => Setting4.fromJson(data)).toList());
        accounts = accounts
            .where((account) => account.chargeType == "Recurring Charge")
            .toList();
      });
    } else {
      print('Failed to fetch settings: ${response.body}');
      //return [];
    }
  }

  void getcards() {
    for (int i = 0; i < widget.leaseData.tenantData!.length; i++) {
      fetchExistingCards(widget.leaseData.tenantData![i].tenantId!,
          widget.leaseData.leaseId!, i);
    }
  }

  void fetchExistingCards(String tenantid, String leaseid, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');

    final response = await http
        .post(Uri.parse('${Api_url}/api/recurring-cards/get-cards'), headers: {
      'authorization': 'CRM $token',
      'id': 'CRM $id',
    }, body: {
      "lease_id": leaseid,
      "tenant_id": tenantid
    });
    print(response.body);
    Map<String, dynamic> Response = json.decode(response.body);
    if (Response["statusCode"] == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body)['data'];
      setState(() {
        List<dynamic> recurrings = jsonResponse["recurrings"];
        tenantDropdowns[index] = [];
        for (int i = 0; i < recurrings!.length; i++) {
          List<Setting4> account = accounts
              .where((acc) =>
                  acc.account == jsonResponse["recurrings"][i]['account'])
              .toList();

          Setting4? fetchaccount = account.length > 0 ? account[0] : null;
          tenantDropdowns[index]!.add({
            "selectedCard":
                "${jsonResponse["recurrings"][i]['billing_id']}_${jsonResponse["recurrings"][i]['card_type']}",
            "selectedDay": "${jsonResponse["recurrings"][i]['date']}",
            "selectedAccount":
                "${fetchaccount!.account}_${fetchaccount!.createdAt}",
            "amount": TextEditingController(
                text: jsonResponse["recurrings"][i]['amount'].toString())
          });
          // tenantDropdowns[index] = [
          //
          // ];
        }
      });
      calculateTotal();
    } else {
      print('Failed to fetch settings: ${response.body}');
      //return [];
    }
  }

  Map<int, String?> selectedCard = {};
  Map<int, int?> selectedDay = {};
  bool isLoading = false;
  String? messageCardAvailable;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Leases",
        dropdown: true,
      ),
      body: isLoading
          ? CircularProgressIndicator()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: widget.leaseData.tenantData!
                          .asMap()
                          .entries
                          .map((entry) {
                        int index = entry.key;

                        var tenant = widget.leaseData.tenantData![index];
                        int? vaultId = customervaultid.length > index
                            ? customervaultid[index]
                            : null;
                        List<BillingData> tenantCards = cardDetails
                            .where((card) =>
                                card.customerVaultId == vaultId.toString())
                            .toList();

                        return Padding(
                          padding: EdgeInsets.all(0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tenant.tenantFirstName ?? 'Unknown Tenant',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Column(
                                children: List.generate(
                                  tenantDropdowns[index]!.length,
                                  (rowIndex) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          // Card Dropdown
                                          Container(
                                            width: 200,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.grey.shade400),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                hint: Text('Select a Card'),
                                                isExpanded: true,
                                                value: tenantDropdowns[index]![
                                                    rowIndex]["selectedCard"],
                                                items: tenantCards.isNotEmpty
                                                    ? tenantCards.map((card) {
                                                        String uniqueKey =
                                                            "${card.billingId}_${card.binResult}"; // Unique key
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: uniqueKey,
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                height: 30,
                                                                width: 30,
                                                                child: Image
                                                                    .network(
                                                                        "https://logo.clearbit.com/${card.ccType!.replaceAll(RegExp(r'[-\s]'), "").toLowerCase()}.com"),
                                                              ),
                                                              SizedBox(
                                                                  width: 5),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                      "${card.ccNumber}",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12)),
                                                                  Text(
                                                                      "${card.billingId}",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12)),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        );
                                                      }).toList()
                                                    : [
                                                        DropdownMenuItem<
                                                            String>(
                                                          value: '',
                                                          child: Text(
                                                              'No cards available'),
                                                        ),
                                                      ],
                                                onChanged: (value) {
                                                  setState(() {
                                                    print(value);
                                                    tenantDropdowns[index]![
                                                                rowIndex]
                                                            ["selectedCard"] =
                                                        value;
                                                  });
                                                },
                                                selectedItemBuilder:
                                                    (BuildContext context) {
                                                  return tenantCards
                                                      .map((card) {
                                                    String uniqueKey =
                                                        "${card.ccNumber}_${card.billingId}";
                                                    return Align(
                                                      alignment: Alignment
                                                          .center, // ✅ Center the selected card number
                                                      child: Text(
                                                        card.ccNumber!, // Show only CC number after selection
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    );
                                                  }).toList();
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),

                                          // Day Dropdown
                                          Container(
                                            width: 200,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.grey.shade400),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                hint: Text('Day'),
                                                isExpanded: true,
                                                menuMaxHeight: 200,
                                                value: tenantDropdowns[index]![
                                                    rowIndex]["selectedDay"],
                                                items: List.generate(
                                                        28, (i) => i + 1)
                                                    .map((day) =>
                                                        DropdownMenuItem<
                                                            String>(
                                                          value: day.toString(),
                                                          child: Text('$day'),
                                                        ))
                                                    .toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    tenantDropdowns[index]![
                                                            rowIndex]
                                                        ["selectedDay"] = value;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Container(
                                            width: 200,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.grey.shade400),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                hint: Text('select Account'),
                                                isExpanded: true,
                                                menuMaxHeight: 200,
                                                value: tenantDropdowns[index]![
                                                        rowIndex]
                                                    ["selectedAccount"],
                                                items: accounts.isNotEmpty
                                                    ? accounts.map((card) {
                                                        String uniqueKey =
                                                            "${card.account}_${card.createdAt}"; // Unique key
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: uniqueKey,
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                child: Text(
                                                                    "${card.account}",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16)),
                                                              ),
                                                              SizedBox(
                                                                  width: 5),
                                                              // Column(
                                                              //   crossAxisAlignment: CrossAxisAlignment.start,
                                                              //   children: [
                                                              //     Text("${card.billingId}", style: TextStyle(fontSize: 12)),
                                                              //   ],
                                                              // )
                                                            ],
                                                          ),
                                                        );
                                                      }).toList()
                                                    : [
                                                        DropdownMenuItem<
                                                            String>(
                                                          value: '',
                                                          child: Text(
                                                              'No cards available'),
                                                        ),
                                                      ],
                                                onChanged: (value) {
                                                  setState(() {
                                                    tenantDropdowns[index]![
                                                                rowIndex][
                                                            "selectedAccount"] =
                                                        value;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            width:
                                                120, // Adjust width as needed
                                            child: TextField(
                                              controller: tenantDropdowns[index]
                                                  ?[rowIndex]["amount"],
                                              keyboardType: TextInputType
                                                  .number, // Ensures numeric input
                                              // textAlign: TextAlign.center, // Centers the text inside the field
                                              onChanged: (value) {
                                                calculateTotal();
                                              },
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight
                                                      .w500), // Custom font styling
                                              decoration: InputDecoration(
                                                labelText: "Amount",
                                                labelStyle: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize:
                                                        12), // Subtle label styling
                                                hintText: "Enter amount",
                                                hintStyle: TextStyle(
                                                    color: Colors.grey.shade400,
                                                    fontSize:
                                                        12), // Lighter hint text
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal:
                                                            10), // Padding for better spacing
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8), // Rounded corners
                                                  borderSide: BorderSide(
                                                      color: Colors.grey
                                                          .shade400), // Border color
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Colors.blue,
                                                      width:
                                                          2), // Highlight on focus
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Colors.grey
                                                          .shade300), // Default border
                                                ),
                                                // prefixIcon: Icon(Icons.attach_money, size: 18, color: Colors.green), // Money icon
                                              ),
                                            ),
                                          ),
                                          // Remove Row Icon
                                          if (tenantDropdowns[index]!.length >
                                              0)
                                            IconButton(
                                              icon: Icon(Icons.close,
                                                  color: Colors.red),
                                              onPressed: () {
                                                calculateTotal();
                                                setState(() {
                                                  tenantDropdowns[index]!
                                                      .removeAt(rowIndex);
                                                });
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Add Row Button
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    tenantDropdowns[index]!.add({
                                      "selectedCard": null,
                                      "selectedDay": null,
                                      "selectedAccount": null,
                                      "amount": TextEditingController()
                                    });
                                  });
                                },
                                icon: Icon(Icons.add, color: Colors.blue),
                                label: Text("Add Row",
                                    style: TextStyle(color: Colors.blue)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    Text("Total Amount : ${totalAmount}"),
                    ElevatedButton(
                      onPressed: () {
                        List<Map<String, dynamic>> selectedTenantsData = [];

                        for (int i = 0;
                            i < widget.leaseData.tenantData!.length;
                            i++) {
                          var tenant = widget.leaseData.tenantData![i];
                          int? vaultId = customervaultid.length > i
                              ? customervaultid[i]
                              : null;

                          // Creating recurrings list
                          List<Map<String, dynamic>> recurringsList = [];

                          for (var row in tenantDropdowns[i]!) {
                            print(row['selectedCard']);
                            if (row['selectedCard'] != null) {
                              var cardData = row['selectedCard']!
                                  .split('_'); // Splitting "ccNumber_billingId"
                              String billingId =
                                  cardData.length > 1 ? cardData[0] : "";
                              String cardtype =
                                  cardData.length > 1 ? cardData[1] : "";
                              var rec_accounts =
                                  row['selectedAccount']!.split('_');
                              String selectedacc = rec_accounts.length > 1
                                  ? rec_accounts[0]
                                  : '';
                              String amount = row['amount'].text;
                              recurringsList.add({
                                "billing_id": billingId,
                                "amount":
                                    amount, // Amount can be added dynamically if needed
                                "card_type":
                                    cardtype, // Get card type if required
                                "account": selectedacc, // CC Number
                                "date": row['selectedDay']?.toString() ??
                                    "", // Selected day
                              });
                            }
                          }

                          // Add only if recurrings list is not empty
                          if (recurringsList.isNotEmpty) {
                            selectedTenantsData.add({
                              "tenant_id": tenant.tenantId,
                              "lease_id": widget.leaseData.leaseId!,
                              "customer_vault_id": vaultId?.toString() ?? "",
                              "date": "", // Add the date if applicable
                              "recurrings": recurringsList,
                            });
                          }
                        }

                        // Print the final JSON object
                        print(selectedTenantsData);
                        postLease(selectedTenantsData);
                      },
                      child: Text("Save Cards"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        disablecards(widget.leaseData!.leaseId!);
                      },
                      child: Text("Disable Cards"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void calculateTotal() {
    double total = 0.0;
    for (int i = 0; i < widget.leaseData.tenantData!.length; i++) {
      for (var element in tenantDropdowns[i]!) {
        double value = double.tryParse(element["amount"].text) ?? 0.0;
        total += value;
      }
    }

    setState(() {
      totalAmount = total;
    });
  }

  Future<void> fetchcreditcard(String tenantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    setState(() {
      isLoading = true;
    });

    final response = await apiGet(
      Uri.parse('$Api_url/api/creditcard/getCreditCards/$tenantId'),
      headers: {"id": "CRM $id", "authorization": "CRM $token"},
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      int? custvaultid = jsonResponse['customer_vault_id'];

      if (custvaultid != null) {
        customervaultid.add(custvaultid);
        List<dynamic> cardDetailsList = jsonResponse['card_detail'];

        for (var cardDetail in cardDetailsList) {
          print('Billing ID: ${cardDetail['billing_id']}');
        }

        CustomerData? customerData = await postBillingCustomerVault(
            custvaultid.toString(), cardDetailsList);

        if (customerData != null) {
          setState(() {
            cardDetails.addAll(customerData.billing);
          });
        }
      } else {
        // Handle case where customer_vault_id is not found
        print('Customer vault ID not found for tenant: $tenantId');
        setState(() {
          customervaultid.add(0); // Adding 0 if vault ID is not found
        });
      }
    } else if (response.statusCode == 404) {
      print('Customer vault ID not found for tenant: $tenantId');
      setState(() {
        customervaultid.add(0); // Adding 0 if vault ID is not found
      });
    } else {
      print('Failed to load credit card data');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<String> binCheck(String ccBin) async {
    final String apiUrl = 'https://bin-ip-checker.p.rapidapi.com/?bin=$ccBin';

    final response = await apiPost(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'X-RapidAPI-Key': '1bd772d3c3msh11c1022dee1c2aep1557bajsn0ac41ea04ef7',
        'X-RapidAPI-Host': 'bin-ip-checker.p.rapidapi.com',
      },
    );
    print("bin api ${response.body}");
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print('BIN check successful: ${jsonResponse['BIN']['type']}');
      return jsonResponse['BIN']['type'];
    } else {
      print('Failed to check BIN: ${response.statusCode}');
      return '';
    }
  }

  Future<CustomerData?> postBillingCustomerVault(
      String customerVaultId, List<dynamic> cardDetailsList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');

    Map<String, String> requestBody = {
      "customer_vault_id": customerVaultId,
      "admin_id": adminId.toString(),
    };
    print(requestBody);
    final response = await apiPost(
      Uri.parse('$Api_url/api/nmipayment/get-billing-customer-vault'),
      headers: {
        'Content-Type': 'application/json',
        "id": "CRM $adminId",
        "authorization": "CRM $token",
      },
      body: json.encode(requestBody),
    );
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      print(jsonResponse['data'].toString() == "{}");
      if (jsonResponse['data'].toString() == "{}") {
        return null;
      } else {
        var customerJson = jsonResponse['data']['customer'];
        CustomerData customerData = CustomerData.fromJson(customerJson);

        customerData.billing.forEach((billing) {
          print('CC Bin: ${billing.ccBin}');
        });

        // List<String> binResults = await performBinChecks(customerData);
        //
        // for (int i = 0; i < customerData.billing.length; i++) {
        //   customerData.billing[i].binResult = binResults[i];
        // }
        //
        // print('Number of BIN check results: ${binResults.length}');
        // binResults.forEach((result) {
        //   print('BIN Check Result: $result');
        // });
        for (int i = 0; i < customerData.billing.length; i++) {
          customerData.billing[i].binResult = cardDetailsList[i]["card_type"];
        }

        return customerData;
      }
    } else {
      print('Failed to post data: ${response.statusCode}');
      return null;
    }
  }

  postLease(List<Map<String, dynamic>> lease) async {
    final url = Uri.parse('${Api_url}/api/recurring-cards/add-cards');
    print(url);
    //log(jsonEncode(lease.toJson()));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    try {
      final response = await apiPost(
        url,
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          'Content-Type': 'application/json'
        },
        body: jsonEncode(lease),
      );

      var responseData = jsonDecode(response.body);
      print('Response body of the lease :${response.body}');
      //  log(response.body);
      //   print('Lease Object: ${jsonEncode(lease.toJson())}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['statusCode'] == 200) {
          print('Response successfully: ${responseData['data']}');

          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Successfully added lease');

          return true;
        } else {
          print('Failed to add lease: ${responseData}');
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Failed to add lease');
          return false;
        }
      } else {}
    } catch (error) {
      print('Exception occurred: $error');
      Fluttertoast.showToast(msg: 'An error occurred');
      return false;
    }
  }

  disablecards(String leaseid) async {
    final url =
        Uri.parse('${Api_url}/api/recurring-cards/disable-cards/${leaseid}');
    print(url);
    //log(jsonEncode(lease.toJson()));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    try {
      final response = await apiPut(
        url,
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          'Content-Type': 'application/json'
        },
        // body: jsonEncode(lease),
      );

      var responseData = jsonDecode(response.body);
      print('Response body of the lease :${response.body}');
      //  log(response.body);
      //   print('Lease Object: ${jsonEncode(lease.toJson())}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['statusCode'] == 200) {
          print('Response successfully: ${responseData['data']}');

          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Successfully added lease');

          return true;
        } else {
          print('Failed to add lease: ${responseData}');
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Failed to add lease');
          return false;
        }
      } else {}
    } catch (error) {
      print('Exception occurred: $error');
      Fluttertoast.showToast(msg: 'An error occurred');
      return false;
    }
  }

  Future<List<String>> performBinChecks(CustomerData customerData) async {
    List<String> binResults = [];
    for (BillingData billing in customerData.billing) {
      String binResult = await binCheck(billing.ccBin ?? '');
      binResults.add(binResult);
    }
    return binResults;
  }
}
