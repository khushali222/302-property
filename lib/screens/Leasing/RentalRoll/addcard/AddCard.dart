import 'dart:convert';
import 'dart:math';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';

import 'CardModel.dart';
import 'Service.dart';

class AddCard extends StatefulWidget {
  final String leaseId;
  AddCard({required this.leaseId});

  @override
  State<AddCard> createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
  TextEditingController cardNumber = TextEditingController();
  TextEditingController expirationDate = TextEditingController();
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController zip = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? messageCardAvailable;

  List<Map<String, String>> tenants = [];
  bool isLoading = false;
  String? selectedTenantId;
  int? customervaultid;
  List<BillingData> cardDetails = [];

  @override
  void initState() {
    super.initState();
    fetchTenants();
  }

  Future<void> fetchTenants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    print("token $token");
    print("Admin $id");
    final response = await http.get(
      Uri.parse('$Api_url/api/leases/lease_tenant/${widget.leaseId}'),
      headers: {"id": "CRM $id", "authorization": "CRM $token"},
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

  Future<String> fetchCompanyName(String adminId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    final String apiUrl = '${Api_url}/api/admin/admin_profile/$adminId';

    try {
      final http.Response response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        // Check if company_name exists in response and is not null
        if (data.containsKey('data') &&
            data['data'] != null &&
            data['data']['company_name'] != null) {
          return data['data']['company_name'].toString();
        } else {
          throw Exception('Company name not found in response');
        }
      } else {
        throw Exception(
            'Failed to fetch company name. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch company name: $e');
    }
  }

  Future<void> fetchcreditcard(String tenantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    setState(() {
      isLoading = true;
      cardDetails = []; // Clear previous card details
    });

    final response = await http.get(
      Uri.parse('$Api_url/api/creditcard/getCreditCards/$tenantId'),
      headers: {"id": "CRM $id", "authorization": "CRM $token"},
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      customervaultid = jsonResponse['customer_vault_id'];
      List<dynamic> cardDetailsList = jsonResponse['card_detail'];

      // Debug print to check the response structure
      print('JSON Response: $jsonResponse');

      for (var cardDetail in cardDetailsList) {
        // Debug print to check each card detail
        print('Card Detail: $cardDetail');

        //  BillingData billingData = BillingData.fromJson(cardDetail);
        // print('Parsed Billing ID: ${billingData.billingId}');

        // Assuming this is part of the logic to print billing_id
        print('Billing ID: ${cardDetail['billing_id']}');
      }

      CustomerData? customerData =
          await postBillingCustomerVault(customervaultid.toString());

      if (customerData != null) {
        setState(() {
          cardDetails = customerData.billing;
          messageCardAvailable = '';
        });
      }
    } else if (response.statusCode == 404) {
      print('customer_vault_id not found');
      setState(() {
        messageCardAvailable = 'No card found for this tenant';
      });
    } else {
      throw Exception('Failed to load credit card data');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<String> binCheck(String ccBin) async {
    final String apiUrl = 'https://bin-ip-checker.p.rapidapi.com/?bin=$ccBin';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'X-RapidAPI-Key': '1bd772d3c3msh11c1022dee1c2aep1557bajsn0ac41ea04ef7',
        'X-RapidAPI-Host': 'bin-ip-checker.p.rapidapi.com',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print('BIN check successful: ${jsonResponse['BIN']['type']}');
      return jsonResponse['BIN']['type'];
    } else {
      print('Failed to check BIN: ${response.statusCode}');
      return '';
    }
  }

  Future<CustomerData?> postBillingCustomerVault(String customerVaultId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');

    Map<String, String> requestBody = {
      "customer_vault_id": customerVaultId,
      "admin_id": adminId.toString(),
    };

    final response = await http.post(
      Uri.parse('$Api_url/api/nmipayment/get-billing-customer-vault'),
      headers: {
        'Content-Type': 'application/json',
        "id": "CRM $adminId",
        "authorization": "CRM $token",
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      var customerJson = jsonResponse['data']['customer'];
      CustomerData customerData = CustomerData.fromJson(customerJson);

      customerData.billing.forEach((billing) {
        print('CC Bin: ${billing.ccBin}');
      });

      List<String> binResults = await performBinChecks(customerData);

      for (int i = 0; i < customerData.billing.length; i++) {
        customerData.billing[i].binResult = binResults[i];
      }

      print('Number of BIN check results: ${binResults.length}');
      binResults.forEach((result) {
        print('BIN Check Result: $result');
      });

      return customerData;
    } else {
      print('Failed to post data: ${response.statusCode}');
      return null;
    }
  }

  Future<void> deleteCardaction(
      BillingData billingData, String customervaultid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");

    cardModelFordelete cardmodelfordelete = cardModelFordelete(
      adminId: id,
      billingId: billingData.billingId,
      customerVaultId: customervaultid,
    );

    if (cardDetails.length == 1) {
      AddCardService apiService = AddCardService();
      int deleteResponse =
          await apiService.deleteOneCardDelete(customervaultid);

      if (deleteResponse == 200) {
        await apiService.deleteOneCardfromdatabase(customervaultid);
        setState(() {
          cardDetails
              .remove(billingData); // Remove the deleted card from the list
        });
      } else {
        // Handle the error case
      }
    } else {
      AddCardService apiService = AddCardService();
      int deleteResponse = await apiService.deleteCard(cardmodelfordelete);

      if (deleteResponse == 200) {
        await apiService
            .deletefromdatabaseCard(billingData.billingId.toString());
        setState(() {
          cardDetails
              .remove(billingData); // Remove the deleted card from the list
        });
      } else {
        // Handle the error case
      }
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

  String _formatCardNumber(String cardNumber) {
    if (cardNumber.length != 16) {
      return cardNumber;
    }

    String maskedNumber = '';
    maskedNumber += cardNumber.substring(0, 1);

    for (int i = 1; i < cardNumber.length - 4; i++) {
      if (i % 4 == 0) {
        maskedNumber += ' ';
      }
      maskedNumber += 'x';
    }

    maskedNumber += ' ' + cardNumber.substring(cardNumber.length - 4);
    return maskedNumber;
  }

  bool isValidLuhn(String number) {
    int sum = 0;
    bool alternate = false;

    for (int i = number.length - 1; i >= 0; i--) {
      int n = int.parse(number[i]);

      if (alternate) {
        n *= 2;
        if (n > 9) {
          n -= 9;
        }
      }

      sum += n;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  String generateRandomNumber(int length) {
    print(10);
    String randomNumber = "";
    for (int i = 0; i < length; i++) {
      randomNumber += (Random().nextInt(9) + 1).toString();
    }
    print(randomNumber);
    return randomNumber;
  }

  bool showmessage = true;
  String? errorMessageDropdown = 'Please select any one Tenant.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: Drawer(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              const SizedBox(height: 40),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.circle_grid_3x3,
                    color: Colors.black,
                  ),
                  "Dashboard",
                  false),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.house,
                    color: Colors.black,
                  ),
                  "Add Property Type",
                  false),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.person_add,
                    color: Colors.black,
                  ),
                  "Add Staff Member",
                  false),
              buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.key,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Rental",
                  ["Properties", "RentalOwner", "Tenants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.thumbsUp,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Leasing",
                  ["Rent Roll", "Applicants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"],
                  selectedSubtopic: "Properties"),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Container(
                          height: 50.0,
                          padding: EdgeInsets.only(top: 14, left: 10),
                          width: MediaQuery.of(context).size.width * .91,
                          margin: const EdgeInsets.only(bottom: 6.0),
                          //Same as `blurRadius` i guess
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
                          child: Text(
                            "Add Card",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    showmessage
                        ? Text('${errorMessageDropdown.toString()}',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.red))
                        : Container(),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text('Recieved From *',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    tenants.isEmpty
                        ? Center(
                            child: SpinKitFadingCircle(
                              color: Colors.black,
                              size: 55.0,
                            ),
                          )
                        : DropdownButtonHideUnderline(
                            child: DropdownButtonFormField2<String>(
                              decoration:
                                  InputDecoration(border: InputBorder.none),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select resident';
                                }
                                return null;
                              },
                              isExpanded: true,
                              hint: const Text('Select Resident'),
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
                                  showmessage = false;
                                });
                                fetchcreditcard(value!);
                                print('Selected tenant_id: $selectedTenantId');
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 45,
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.only(left: 14, right: 14),
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
                                padding: EdgeInsets.only(left: 14, right: 14),
                              ),
                            ),
                          ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text('Card Number *',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    CustomTextField(
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty &&
                                !isValidLuhn(value.replaceAll(' ', ''))) {
                          return !isValidLuhn(value!.replaceAll(' ', ''))
                              ? 'Invalid credit card number'
                              : 'Please enter a credit card number';
                        } else if (!isValidLuhn(value.replaceAll(' ', ''))) {
                          return 'Invalid credit card number';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      hintText: '0000 0000 0000 0000',
                      controller: cardNumber,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text('Expiration Date *',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    CustomTextField(
                      keyboardType: TextInputType.text,
                      hintText: 'Enter Expiration Date',
                      controller: expirationDate,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text('First Name *',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    CustomTextField(
                      keyboardType: TextInputType.text,
                      hintText: 'Enter First Name',
                      controller: firstName,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text('Last Name *',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    CustomTextField(
                      keyboardType: TextInputType.text,
                      hintText: 'Enter Last Name',
                      controller: lastName,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text('Email *',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    CustomTextField(
                      keyboardType: TextInputType.text,
                      hintText: 'Enter Email',
                      controller: email,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text('Phone Number*',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    CustomTextField(
                      keyboardType: TextInputType.text,
                      hintText: 'Enter Phone Number',
                      controller: phoneNumber,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text('Address *',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    CustomTextField(
                      keyboardType: TextInputType.text,
                      hintText: 'Enter Address',
                      controller: address,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text('City',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    CustomTextField(
                      keyboardType: TextInputType.text,
                      hintText: 'Enter City',
                      controller: city,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text('State',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    CustomTextField(
                      keyboardType: TextInputType.text,
                      hintText: 'Enter State',
                      controller: state,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text('Country',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    CustomTextField(
                      keyboardType: TextInputType.text,
                      hintText: 'Enter Country',
                      controller: country,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text('Zip',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    CustomTextField(
                      keyboardType: TextInputType.text,
                      hintText: 'Enter Zip',
                      controller: zip,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
              selectedTenantId == null
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: const Text('Cards',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF152b51))),
                    ),
              selectedTenantId == null ? Container() : SizedBox(height: 8),
              selectedTenantId == null
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: isLoading
                          ? const Center(
                              child: SpinKitFadingCircle(
                                color: Colors.black,
                                size: 55.0,
                              ),
                            )
                          : cardDetails.isEmpty
                              ? Center(
                                  child: Text(messageCardAvailable ??
                                      'No card details available'),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: cardDetails.length,
                                  itemBuilder: (context, index) {
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: _buildCreditCard(
                                              cardDetails[index],
                                              customervaultid.toString()),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                    ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                child: Row(
                  children: [
                    Container(
                        height: 42,
                        width: 110,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0)),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(21, 43, 83, 1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0))),
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String? id = prefs.getString("adminId");
                                String? token = prefs.getString('token');

                                String randomNumber = generateRandomNumber(10);

                                String? comapanyName =
                                    await fetchCompanyName(id!);

                                CardModel cardwithOutVaultId = CardModel(
                                  firstName: firstName.text,
                                  lastName: lastName.text,
                                  ccnumber: cardNumber.text,
                                  ccexp: expirationDate.text,
                                  address1: address.text,
                                  address2: '',
                                  city: city.text,
                                  state: state.text,
                                  zip: zip.text,
                                  country: country.text,
                                  phone: phoneNumber.text,
                                  email: email.text,
                                  company: comapanyName,
                                  billingId: randomNumber,
                                  adminId: id,
                                );

                                CardModel cardwithVaultId = CardModel(
                                    phone: phoneNumber.text,
                                    adminId: id,
                                    company: comapanyName,
                                    firstName: firstName.text,
                                    lastName: lastName.text,
                                    ccnumber: cardNumber.text,
                                    ccexp: expirationDate.text,
                                    address1: address.text,
                                    address2: '',
                                    zip: zip.text,
                                    state: state.text,
                                    city: city.text,
                                    billingId: randomNumber,
                                    email: email.text,
                                    country: country.text,
                                    customervaultid:
                                        customervaultid.toString());

                                AddCardService addCardService =
                                    AddCardService();

                                if (messageCardAvailable ==
                                    "No card found for this tenant") {
                                  print('create api and billing post api both');
                                  // await addCardService
                                  //     .postCardDetails(cardwithOutVaultId);
                                  CardResponse? cardResponse =
                                      await addCardService
                                          .postCardDetails(cardwithOutVaultId);

                                  if (cardResponse != null) {
                                    print(
                                        'Customer Vault ID: ${cardResponse.customerVaultId}');
                                    print(
                                        'Response Code: ${cardResponse.responseCode}');
                                  } else {
                                    print('Failed to get card response');
                                  }
                                  AddCreditCard addcard = AddCreditCard(
                                    tenantId: selectedTenantId,
                                    billingId: randomNumber,
                                    customerVaultId:
                                        cardResponse!.customerVaultId,
                                    responseCode: cardResponse.responseCode,
                                  );

                                  await addCardService
                                      .postAddCreditCard(addcard);
                                  Navigator.pop(context);
                                  Fluttertoast.showToast(
                                      msg: 'Add Card Successfully');
                                } else {
                                  CardResponse? cardResponses =
                                      await addCardService
                                          .postCardWithVaultId(cardwithVaultId);
                                  if (cardResponses != null) {
                                    print(
                                        'Customer Vault ID: ${cardResponses.customerVaultId}');
                                    print(
                                        'Response Code: ${cardResponses.responseCode}');
                                  } else {
                                    print('Failed to get card response');
                                  }
                                  AddCreditCard addcards = AddCreditCard(
                                    tenantId: selectedTenantId,
                                    billingId: randomNumber,
                                    customerVaultId:
                                        cardResponses!.customerVaultId,
                                    responseCode: cardResponses.responseCode,
                                  );
                                  await addCardService
                                      .postAddCreditCard(addcards);
                                  Navigator.pop(context);
                                  Fluttertoast.showToast(
                                      msg: 'Add Card Successfully');
                                }

                                //charges
                              } else {}
                            },
                            child: const Text(
                              'Add Card',
                              style: TextStyle(color: Color(0xFFf7f8f9)),
                            ))),
                    const SizedBox(
                      width: 8,
                    ),
                    Container(
                        height: 42,
                        width: 80,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0)),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFffffff),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0))),
                            onPressed: () {},
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Color(0xFF748097)),
                            )))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? validateExpirationDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a date';
    }

    final RegExp dateRegex = RegExp(r'^(0[1-9]|1[0-2])/(\d{4})$');
    if (!dateRegex.hasMatch(value)) {
      return 'Invalid date format';
    }

    return null;
  }

  void formatExpiryDateForTextField(
      TextEditingController controller, String expiryDate) {
    if (expiryDate.length == 4) {
      String month = expiryDate.substring(0, 2);
      String year = expiryDate.substring(2, 4);
      controller.text = '$month/$year';
    } else {
      controller.text = expiryDate; // Set as is if not 4 characters long
    }
  }

  Widget _buildCreditCard(BillingData billingData, String customervaultid) {
    print("billingData.billingId: ${billingData.billingId}");
    String _formatCardNumber(String cardNumber) {
      if (cardNumber.length != 16) {
        return cardNumber; // If the card number length is not 16, return as-is
      }

      String maskedNumber = '';

      // Show the first character
      maskedNumber += cardNumber.substring(0, 1);

      // Add spaces after every 4 characters
      for (int i = 1; i < cardNumber.length - 4; i++) {
        if (i % 4 == 0) {
          maskedNumber += ' ';
        }
        maskedNumber += 'x'; // Mask middle digits with 'x'
      }

      // Show the last 4 characters
      maskedNumber += ' ' + cardNumber.substring(cardNumber.length - 4);

      return maskedNumber;
    }

    String formatExpiryDate(String expiryDate) {
      if (expiryDate.length == 4) {
        String month = expiryDate.substring(0, 2);
        String year = expiryDate.substring(2, 4);
        return '$month/$year';
      } else {
        return expiryDate; // Return as is if not 4 characters long
      }
    }

    print('card type :' + billingData.ccType.toString());
    return Slidable(
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            borderRadius: BorderRadius.circular(10.0),
            onPressed: (context) async {
              await deleteCardaction(billingData, customervaultid);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete Card',
          ),
        ],
      ),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Container(
          height: 210,
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 22.0),
          decoration: BoxDecoration(
            gradient: _getCardGradient(billingData.ccType ?? ''),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: _buildLogosBlock(
                    '${billingData.binResult!} CARD', billingData.ccType ?? ''),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _formatCardNumber(billingData.ccNumber ?? ''),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _buildDetailsBlock(
                    label: 'CARDHOLDER',
                    value:
                        '${billingData.firstName ?? ''} ${billingData.lastName ?? ''}',
                  ),
                  _buildDetailsBlock(
                      label: 'VALID THRU',
                      value: formatExpiryDate(billingData.ccExp ?? '')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Row _buildLogosBlock(String cardType, String ccType) {
  String logoUrl =
      'https://logo.clearbit.com/${ccType.replaceAll(RegExp(r'[-\s]'), "").toLowerCase()}.com';
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Image.network(
        logoUrl,
        height: 40,
        width: 40,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.credit_card,
            color: Colors.white,
            size: 30,
          );
        },
      ),
      Text(
        cardType,
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12),
      ),
    ],
  );
}

Widget _buildDetailsBlock({required String label, required String value}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
      ),
      SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    ],
  );
}

LinearGradient _getCardGradient(String cardType) {
  print(cardType);
  if (cardType.toLowerCase() == "mastercard" ||
      cardType.toLowerCase() == "discover") {
    return LinearGradient(
      colors: [Color(0xFF121E2E), Color(0xFF3A6194)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  } else if (cardType.toLowerCase() == "visa" ||
      cardType.toLowerCase() == "jcb") {
    return LinearGradient(
      colors: [Color(0xFF000000), Color(0xFF666666)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  } else {
    return LinearGradient(
      colors: [Color(0xFF949BA5), Color(0xFF393B3F)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}