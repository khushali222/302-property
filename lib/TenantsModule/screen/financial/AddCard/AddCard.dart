import 'dart:convert';
import 'dart:math';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_actions/keyboard_actions_config.dart';
import 'package:keyboard_actions/keyboard_actions_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/screens/Leasing/RentalRoll/Financial.dart';

import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_drawer.dart';
import '../../../widgets/drawer_tiles.dart';

import 'CardModel.dart';
import 'Service.dart';

class AddCard extends StatefulWidget {
  @override
  State<AddCard> createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
  TextEditingController cardNumber = TextEditingController();
  TextEditingController expirationDate = TextEditingController();
  TextEditingController cvv = TextEditingController();
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
  bool isLoading1 = false;
  String? selectedTenantId;
  int? customervaultid;
  List<BillingData> cardDetails = [];
  Map<String, dynamic> profiledata = {};
  @override
  void initState() {
    super.initState();
    fetchProfile();
    fetchTenants();
  }

  Future<void> fetchProfile() async {
    //  String? token = prefs.getString('token');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final String apiUrl = "${Api_url}/api/tenant/tenant_profile/$id";
    final response = await http.get(
      Uri.parse('$apiUrl'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    print('hello$apiUrl');
    print(response.body);
    final response_Data = jsonDecode(response.body);
    if (response_Data["statusCode"] == 200) {
      print("hello");
      setState(() {
        profiledata = response_Data["data"];
        firstName.text = "${profiledata["tenant_firstName"]}";
        lastName.text = profiledata["tenant_lastName"];
        email.text = profiledata["tenant_email"];
        phoneNumber.text = profiledata["tenant_phoneNumber"];
        address.text = profiledata['leaseData']['rental_adress'];

        //  _isLoading = false;
      });
      // return profile.fromJson(jsonDecode(response.body)["data"]);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<void> fetchTenants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    print("token $token");
    print("Admin $id");
    fetchcreditcard(id!);
    /*  final response = await http.get(
      Uri.parse('$Api_url/api/leases/lease_tenant/${id}'),
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
    }*/
  }

  Future<String> fetchCompanyName(String adminId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final String apiUrl = '${Api_url}/api/admin/admin_profile/$admin_id';

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
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    setState(() {
      isLoading = true;
      cardDetails = []; // Clear previous card details
    });

    final response = await http.get(
      Uri.parse('$Api_url/api/creditcard/getCreditCards/$tenantId'),
      headers: {"id": "CRM $id", "authorization": "CRM $token"},
    );

    print('$Api_url/api/creditcard/getCreditCards/$tenantId');
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
          await postBillingCustomerVault(customervaultid.toString(),cardDetailsList);

      if (customerData != null) {
        setState(() {
          customervaultid = jsonResponse['customer_vault_id'];
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

  Future<CustomerData?> postBillingCustomerVault(String customerVaultId,List<dynamic> cardDetailsList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    print(admin_id);
    Map<String, String> requestBody = {
      "customer_vault_id": customerVaultId,
      "admin_id": admin_id.toString(),
    };
    print(requestBody);
    final response = await http.post(
      Uri.parse('$Api_url/api/nmipayment/get-billing-customer-vault'),
      headers: {
        'Content-Type': 'application/json',
        "id": "CRM $id",
        "authorization": "CRM $token",
      },
      body: json.encode(requestBody),
    );
    print(response.body);
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);

      var customerJson = jsonResponse['data']['customer'];
      if (customerJson == null) {
        print('Failed to post data: ${response.statusCode}');
        return null;
      }
      CustomerData customerData = CustomerData.fromJson(customerJson);

      customerData.billing.forEach((billing) {
        print('CC Bin: ${billing.ccBin}');
      });
      Set<String> cardBillingIds = cardDetailsList
          .map((card) => card['billing_id'].toString()) // Ensure conversion to string
          .toSet();

      // Filter customerData.billing to only include matching billing IDs
      List<BillingData> filteredCards = customerData.billing
          .where((billing) => cardBillingIds.contains(billing.billingId))
          .toList();
      customerData.billing = filteredCards;
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
      for (int i = 0; i < cardDetailsList.length; i++) {
        customerData.billing[i].binResult = cardDetailsList[i]["card_type"];
      }


      return customerData;
    } else {
      print('Failed to post data: ${response.statusCode}');
      return null;
    }
  }

  Future<void> deleteCardaction(
      BillingData billingData, String customervaultid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('adminId');

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
        Fluttertoast.showToast(msg: "Card Deleted Successfully");
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
        Fluttertoast.showToast(msg: "Card Deleted Successfully");
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
  String? _errorMessage;
  String? _cardNumberError;
  String? _cvvError;
  // Callback to handle error messages
  void handleError
      (String? error) {
    setState(() {
      _errorMessage = error;
    });
  }
  bool showmessage = true;
  String? errorMessageDropdown = 'Please select any one Tenant.';
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: widget_302.App_Bar(
        context: context,
        onDrawerIconPressed: () {
          key.currentState!.openDrawer();
        },
      ),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: 'Financial',
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
                            color: blueColor,
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
                      formatter: [
                        CardNumberInputFormatter(),
                        LengthLimitingTextInputFormatter(19),
                      ],
                      label: "enter card number",
                      keyboardType: TextInputType.number,
                      hintText: '0000 0000 0000 0000',
                      controller: cardNumber,
                      cardnum: true,
                      optional: false,
                      allerror: true,
                      onErrorcard:  (String? error) {
                        setState(() {
                          _cardNumberError = error;
                        });
                      },
                    ),
                    if (_cardNumberError != null)
                      Text(
                        _cardNumberError!,
                        style: TextStyle(color: Colors.red, fontSize: 12),
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
                      hintText: 'MM/YYYY',
                      controller: expirationDate,
                      label: "Enter Expiration Date",
                    //  allerror: true,
                      //isexpirydate: true,
                      formatter: [ExpiryDateInputFormatter()],
                      expirydate: true,
                      optional: false,
                      allerror: true,
                      onError: (String? error) {
                        setState(() {
                          _errorMessage = error;
                        });
                      },
                    ),
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text('CVV *',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    CustomTextField(
                      keyboardType: TextInputType.text,
                      hintText: 'CVV',
                      allerror: true,
                      controller: cvv,
                      optional: false,
                      label: "Enter CVV",
                      cvv: true,
                      //isexpirydate: true,
                      formatter: [CVVFormatter()],
                      onErrorcvv: (String? error) {
                        setState(() {
                          _cvvError = error;
                        });
                      },
                    ),
                    if (_cvvError != null)
                      Text(
                        _cvvError!,
                        style: TextStyle(color: Colors.red, fontSize: 12),
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
                      keyboardType: TextInputType.emailAddress,
                      hintText: 'Enter Email',
                      email: true,
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
                      formatter: [
                        FilteringTextInputFormatter
                            .digitsOnly,
                        LengthLimitingTextInputFormatter(
                            10),
                        PhoneNumberFormatter(),
                      ],
                      keyboardType: TextInputType.number,
                      // keyboardType: TextInputType.numberWithOptions(signed: true,decimal: true),
                      hintText: 'Enter Phone Number',
                      controller: phoneNumber,
                      phone: true,
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
                    const Text('City *',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    CustomTextField(
                      keyboardType: TextInputType.text,
                      hintText: 'Enter City',
                      controller: city,
                      optional: false,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text('State *',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    CustomTextField(
                      keyboardType: TextInputType.text,
                      hintText: 'Enter State',
                      controller: state,
                      optional: false,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text('Country *',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    CustomTextField(
                      keyboardType: TextInputType.text,
                      hintText: 'Enter Country',
                      controller: country,
                      optional: false,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text('Zip *',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    CustomTextField(
                      keyboardType: TextInputType.number,
                      hintText: 'Enter Zip',
                      controller: zip,
                      optional: false,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
              selectedTenantId == null && cardDetails.isEmpty
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('Cards',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: blueColor)),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                  'Note: Swipe right on the card to delete it.',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: blueColor)),
                            ],
                          ),
                        ],
                      ),
                    ),
              SizedBox(height: 8),
              Padding(
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
                                    child: _buildCreditCard(cardDetails[index],
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
              SizedBox(height: 15),
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
                                backgroundColor: blueColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0))),
                            // onPressed: () async {
                            //   print(_formKey.currentState!.validate());
                            //   if (_formKey.currentState!.validate()) {
                            //     setState(() {
                            //       isLoading1 = true;
                            //     });
                            //     print("calling");
                            //     SharedPreferences prefs =
                            //         await SharedPreferences.getInstance();
                            //     String? id = prefs.getString("adminId");
                            //     String? token = prefs.getString('token');
                            //     selectedTenantId = prefs.getString('tenant_id');
                            //     String randomNumber = generateRandomNumber(10);
                            //
                            //     String? comapanyName =
                            //         await fetchCompanyName(id!);
                            //
                            //     CardModel cardwithOutVaultId = CardModel(
                            //       firstName: firstName.text,
                            //       lastName: lastName.text,
                            //       ccnumber: cardNumber.text,
                            //       cvv: cvv.text,
                            //       ccexp: expirationDate.text,
                            //       address1: address.text,
                            //       address2: '',
                            //       city: city.text,
                            //       state: state.text,
                            //       zip: zip.text,
                            //       country: country.text,
                            //       phone: phoneNumber.text,
                            //       email: email.text,
                            //       company: comapanyName,
                            //       billingId: randomNumber,
                            //       adminId: id,
                            //     );
                            //
                            //     CardModel cardwithVaultId = CardModel(
                            //         phone: phoneNumber.text,
                            //         adminId: id,
                            //         cvv: cvv.text,
                            //         company: comapanyName,
                            //         firstName: firstName.text,
                            //         lastName: lastName.text,
                            //         ccnumber: cardNumber.text,
                            //         ccexp: expirationDate.text,
                            //         address1: address.text,
                            //         address2: '',
                            //         zip: zip.text,
                            //         state: state.text,
                            //         city: city.text,
                            //         billingId: randomNumber,
                            //         email: email.text,
                            //         country: country.text,
                            //         customervaultid:
                            //             customervaultid.toString());
                            //
                            //     AddCardService addCardService =
                            //         AddCardService();
                            //
                            //     if (messageCardAvailable ==
                            //         "No card found for this tenant") {
                            //       print('create api and billing post api both');
                            //       // await addCardService
                            //       //     .postCardDetails(cardwithOutVaultId);
                            //       CardResponse? cardResponse =
                            //           await addCardService
                            //               .postCardDetails(cardwithOutVaultId);
                            //
                            //       if (cardResponse != null) {
                            //         print(
                            //             'Customer Vault ID: ${cardResponse.customerVaultId}');
                            //         print(
                            //             'Response Code: ${cardResponse.responseCode}');
                            //       } else {
                            //         print('Failed to get card response');
                            //       }
                            //       AddCreditCard addcard = AddCreditCard(
                            //         tenantId: selectedTenantId,
                            //         billingId: randomNumber,
                            //         customerVaultId:
                            //             cardResponse?.customerVaultId,
                            //         responseCode: cardResponse?.responseCode,
                            //       );
                            //
                            //       await addCardService
                            //           .postAddCreditCard(addcard)
                            //           .then((value) {
                            //         setState(() {
                            //           isLoading1 = false;
                            //         });
                            //       });
                            //       Navigator.pop(context);
                            //       Fluttertoast.showToast(
                            //           msg: 'Add Card Successfully');
                            //     } else {
                            //       CardResponse? cardResponses =
                            //           await addCardService
                            //               .postCardWithVaultId(cardwithVaultId);
                            //       if (cardResponses != null) {
                            //         print(
                            //             'Customer Vault ID: ${cardResponses.customerVaultId}');
                            //         print(
                            //             'Response Code: ${cardResponses.responseCode}');
                            //       } else {
                            //         print('Failed to get card response');
                            //       }
                            //       AddCreditCard addcards = AddCreditCard(
                            //         tenantId: selectedTenantId,
                            //         billingId: randomNumber,
                            //         customerVaultId:
                            //             cardResponses?.customerVaultId,
                            //         responseCode: cardResponses?.responseCode,
                            //       );
                            //       await addCardService
                            //           .postAddCreditCard(addcards)
                            //           .then((value) {
                            //         setState(() {
                            //           isLoading1 = false;
                            //         });
                            //       });
                            //       Navigator.pop(context, true);
                            //       Fluttertoast.showToast(
                            //           msg: 'Add Card Successfully');
                            //     }
                            //
                            //     //charges
                            //   } else {
                            //     setState(() {
                            //       isLoading1 = false;
                            //     });
                            //     print("invalid");
                            //   }
                            // },
                            onPressed: () async {
                              print(_formKey.currentState!.validate());
                              if (_formKey.currentState!.validate()) {

                                print(_cardNumberError != null);
                                print(_errorMessage =="");
                                print(_cvvError != null);
                                print(_errorMessage!.isNotEmpty);
                                if(_cardNumberError != null || _errorMessage!.isNotEmpty || _cvvError != null ){

                                  Fluttertoast.showToast(msg: "Add Card faileds");
                                }
                                else{
                                  setState(() {
                                    isLoading1 = true;
                                  });
                                  try
                                  {
                                    print("calling");

                                    SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                    String? id = prefs.getString("adminId");
                                    String? token = prefs.getString('token');
                                    selectedTenantId = prefs.getString('tenant_id');
                                    String randomNumber = generateRandomNumber(10);

                                    String? comapanyName =
                                    await fetchCompanyName(id!);

                                    CardModel cardwithOutVaultId = CardModel(
                                      firstName: firstName.text.trim(),
                                      lastName: lastName.text.trim(),
                                      ccnumber: cardNumber.text.trim(),
                                      cvv: cvv.text.trim(),
                                      ccexp: expirationDate.text.trim(),
                                      address1: address.text.trim(),
                                      address2: '',
                                      city: city.text.trim(),
                                      state: state.text.trim(),
                                      zip: zip.text.trim(),
                                      country: country.text.trim(),
                                      phone: phoneNumber.text.trim(),
                                      email: email.text.trim(),
                                      company: comapanyName,
                                      billingId: randomNumber,
                                      adminId: id,
                                    );

                                    CardModel cardwithVaultId = CardModel(
                                        phone: phoneNumber.text.trim(),
                                        adminId: id,
                                        cvv: cvv.text.trim(),
                                        company: comapanyName,
                                        firstName: firstName.text.trim(),
                                        lastName: lastName.text.trim(),
                                        ccnumber: cardNumber.text.trim(),
                                        ccexp: expirationDate.text.trim(),
                                        address1: address.text.trim(),
                                        address2: '',
                                        zip: zip.text.trim(),
                                        state: state.text.trim(),
                                        city: city.text.trim(),
                                        billingId: randomNumber,
                                        email: email.text.trim(),
                                        country: country.text.trim(),
                                        customervaultid:
                                        customervaultid.toString());

                                    AddCardService addCardService =
                                    AddCardService();

                                    if (messageCardAvailable == "No card found for this tenant") {
                                      print('create api and billing post api both');
                                      CardResponse? cardResponse =
                                      await addCardService.postCardDetails(cardwithOutVaultId);

                                      if (cardResponse != null) {
                                        print('Customer Vault ID: ${cardResponse.customerVaultId}');
                                        print('Response Code: ${cardResponse.responseCode}');

                                        AddCreditCard addcard = AddCreditCard(
                                          tenantId: selectedTenantId,
                                          billingId: randomNumber,
                                          customerVaultId:
                                          cardResponse?.customerVaultId,
                                          responseCode: cardResponse?.responseCode,
                                            ccNumber: cardNumber.text
                                        );

                                        await addCardService.postAddCreditCard(addcard).then((value) {
                                          setState(() {
                                            isLoading1 = false;
                                          });
                                        });

                                        Navigator.pop(context);
                                        Fluttertoast.showToast(msg: 'Add Card Successfully');
                                      } else {
                                        setState(() {
                                          isLoading1 = false;
                                        });
                                        Fluttertoast.showToast(msg: 'Failed to add card');
                                      }
                                    }
                                    else {
                                      CardResponse? cardResponses =
                                      await addCardService.postCardWithVaultId(cardwithVaultId);

                                      if (cardResponses != null) {
                                        print('Customer Vault ID: ${cardResponses.customerVaultId}');
                                        print('Response Code: ${cardResponses.responseCode}');

                                        AddCreditCard addcards = AddCreditCard(
                                          tenantId: selectedTenantId,
                                          billingId: randomNumber,
                                          customerVaultId: cardResponses.customerVaultId,
                                          responseCode: cardResponses.responseCode,

                                            ccNumber: cardNumber.text
                                        );

                                        await addCardService.postAddCreditCard(addcards).then((value) {
                                          setState(() {
                                            isLoading1 = false;
                                          });
                                        });

                                        Navigator.pop(context, true);
                                        Fluttertoast.showToast(msg: 'Add Card Successfully');
                                      }
                                      // else {
                                      //   setState(() {
                                      //     isLoading1 = false;
                                      //   });
                                      //   Fluttertoast.showToast(msg: 'Failed to add card');
                                      // }
                                    }
                                  } catch (e) {
                                    setState(() {
                                      isLoading1 = false;
                                    });
                                    print("Error occurred: $e");
                                    Fluttertoast.showToast(msg: 'An error occurred, please try again');
                                  }
                                }

                              } else {
                                // Handle the case where form validation fails
                                setState(() {
                                  isLoading1 = false;
                                });
                                Fluttertoast.showToast(msg: 'Form is invalid. Please check the details.');
                              }
                            },

                            child: isLoading1
                                ? Center(
                                    child: SpinKitFadingCircle(
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                  )
                                : const Text(
                                    'Add Card',
                                    style: TextStyle(color: Color(0xFFf7f8f9)),
                                  ))),
                    const SizedBox(
                      width: 8,
                    ),
                    Container(
                        height: 42,
                        width: 120,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0)),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFffffff),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0))),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
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

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove any existing spaces in the input
    String newText = newValue.text.replaceAll(' ', '');

    // Add a space after every 4 digits
    if (newText.length > 4) {
      final StringBuffer buffer = StringBuffer();
      for (int i = 0; i < newText.length; i++) {
        buffer.write(newText[i]);
        if ((i + 1) % 4 == 0 && i + 1 != newText.length) {
          buffer.write(' ');
        }
      }
      newText = buffer.toString();
    }

    // Return the new value with the formatting applied
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Function(String)? onChanged;
  final Function(String)? onChanged2;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final void Function()? onSuffixIconPressed;
  final void Function()? onTap;
  final String? label;
  final bool readOnnly;
  final bool? amount_check;
  final String? max_amount;
  final String? error_mess;
  final bool? optional;
  final bool? phone;
  final bool? cvv;
  final bool? expirydate;
  final bool? allerror;
  final bool? cardnum;
  final List<TextInputFormatter>? formatter;
  final bool? email;
  final Function(String?)? onError;
  final Function(String?)? onErrorcard;
  final Function(String?)? onErrorcvv;

  CustomTextField({
    Key? key,
    this.onChanged,
    this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.emailAddress,
    this.readOnnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onSuffixIconPressed,
    this.label,
    this.onTap,
    this.onChanged2,
    this.amount_check,
    this.max_amount,
    this.error_mess,
    this.formatter,
    this.phone,
    this.cvv,
    this.cardnum,
    this.expirydate,
    this.allerror,
    this.optional = false,
    this.email,
    this.onError,
    this.onErrorcard,
    this.onErrorcvv,
    // Initialize onTap
  }) : super(key: key);

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  String? _errorMessage;
  TextEditingController _textController =
      TextEditingController(); // Add this line

  late FocusNode _focusNode;
  @override
  @override
  void initState() {
    super.initState();
    _textController = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      actions: [
        KeyboardActionsItem(
          focusNode: _focusNode,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () {
                  if (widget.onChanged2 != null) {
                    widget.onChanged2!(_textController.text);
                  }
                  node.unfocus(); // Dismiss the keyboard
                },
                child: Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Text(
                    "Done",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ],
        ),
      ],
    );
  }
  String exprmessage = "";
  bool isValidLuhn(String input) {
    input = input.replaceAll(RegExp(r'\D'), ''); // Remove non-digit characters
    int sum = 0;
    bool alternate = false;

    for (int i = input.length - 1; i >= 0; i--) {
      int digit = int.parse(input[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  @override
  Widget build(BuildContext context) {
    final shouldUseKeyboardActions =
        widget.keyboardType == TextInputType.number;
    Widget textfield = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        FormField<String>(
          validator: widget.optional!
              ? null
              : (value) {
                  if (widget.controller!.text.isEmpty) {
                    setState(() {
                      if (widget.label == null)
                        _errorMessage = 'Please ${widget.hintText}';
                      else
                        _errorMessage = 'Please ${widget.label}';
                    });
                    return '';
                  }
                  // else if (widget.cvv != null) {
                  //   String formattedCVV =
                  //   widget.controller!.text.replaceAll(RegExp(r'\D'), '');
                  //
                  //   // Removed the empty check
                  //   if (formattedCVV.length != 3) {
                  //     setState(() {
                  //       _errorMessage = "Cvv number must be 3 digits";
                  //     });
                  //     return '';
                  //   }
                  // }
                  // else if (widget.cardnum != null) {
                  //   String? validationMessage =
                  //   ValidateExpirationDate(widget.controller!.text);
                  //   if (validationMessage != null) {
                  //     setState(() {
                  //       _errorMessage = validationMessage;
                  //     });
                  //     return '';
                  //   }
                  // }
                  // if (widget.cardnum != null) {
                  //   final sanitizedValue =widget.controller!.text.replaceAll(' ', '');
                  //
                  //   // Check if the card number length is less than 16
                  //   if (sanitizedValue == null || sanitizedValue.length < 16) {
                  //     return 'Card number must be at least 16 digits';
                  //   }
                  //
                  //   // Validate using the Luhn algorithm
                  //   if (!isValidLuhn(sanitizedValue)) {
                  //     return 'Invalid credit card number';
                  //   }
                  // }
                  // else if (widget.cardnum != null) {
                  //   String cardNumber = widget.controller!.text.replaceAll(RegExp(r'\D'), '');
                  //
                  //   // Removed the empty check
                  //   if (cardNumber.length != 16) {
                  //     setState(() {
                  //       _errorMessage = "Card number must be 16 digits";
                  //     });
                  //     return '';
                  //   }
                  //   if (!isValidLuhn(cardNumber)) {
                  //     setState(() {
                  //       _errorMessage = "Invalid credit card number";
                  //     });
                  //     return '';
                  //   }
                  // }
                  else if (widget.phone != null) {
                    String formattedPhoneNumber =
                        widget.controller!.text.replaceAll(RegExp(r'\D'), '');

                    // Removed the empty check
                    if (formattedPhoneNumber.length != 10) {
                      setState(() {
                        _errorMessage = "Phone number must be 10 digits";
                      });
                      return '';
                    }
                  } else if (widget.email != null) {
                    if (!EmailValidator.validate(widget.controller!.text)) {
                      setState(() {
                        _errorMessage = "Email is not valid";
                      });
                      return '';
                    }
                  } else if (widget.amount_check != null &&
                      double.parse(widget.controller!.text) >
                          double.parse(widget.max_amount!))
                    setState(() {
                      _errorMessage = '${widget.error_mess}';
                    });
                  return null;
                },
          builder: (FormFieldState<String> state) {
            return Column(
              children: <Widget>[
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    height: 50,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
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
                      /*    onFieldSubmitted: (value){
                        if(value.isNotEmpty){

                          if(widget.amount_check != null){
                            if(int.parse(value) > int.parse(widget.max_amount!)){
                              setState(() {
                                _errorMessage = '${widget.error_mess}';
                              });
                            }
                          }
                          else{
                            setState(() {
                              _errorMessage = null;
                            });
                          }

                        }
                        print(value);
                        widget.onChanged2;
                      },*/
                      inputFormatters: widget.formatter ?? [],
                      onFieldSubmitted: widget.onChanged2,
                      onChanged: (value) {
                        //  print("object calin $value");
                        if (widget.expirydate == true ) {
                          String? validationMessage;

                          // If the field is empty, set the error message to null
                          if (value == null || value.isEmpty) {
                            validationMessage = null;
                          } else {
                            // If not empty, validate the expiration date
                            validationMessage = ValidateExpirationDate(value); // Assuming ValidateExpirationDate() checks for expiration date format
                          }

                          print(validationMessage);

                          setState(() {
                            if (validationMessage != null) {
                              exprmessage = validationMessage; // Display error message if invalid
                            } else {
                              exprmessage = ""; // Clear error message if valid or empty
                              _errorMessage = null; // Clear general error message
                            }
                          });

                          if (widget.onError != null) {
                            widget.onError!(exprmessage); // Pass the error message to the parent
                          }
                        }
                        if (widget.cardnum != null && widget.allerror != null) {
                          String cardNumber = value.replaceAll(RegExp(r'\D'), ''); // Remove non-digit characters

                          // If the card number is empty, clear the error message
                          if (cardNumber.isEmpty) {
                            setState(() {
                              _errorMessage = null; // Clear error message if the field is empty
                            });
                          } else if (cardNumber.length != 16) {
                            setState(() {
                              exprmessage = "Card number must be 16 digits";
                              _errorMessage = "Card number must be 16 digits";
                            });
                          } else if (!isValidLuhn(cardNumber)) {
                            setState(() {
                              _errorMessage = "Invalid credit card number";
                              exprmessage = "Invalid credit card number";
                            });
                          } else {
                            // Clear error message if the card number is valid
                            setState(() {
                              _errorMessage = null;
                              exprmessage = "";
                            });
                          }

                          // Notify parent about the error message (if any)
                          if (widget.onErrorcard != null ) {
                            widget.onErrorcard!(_errorMessage); // Pass the error message to the parent
                          }
                        }
                         if (widget.cvv != null&& widget.allerror != null) {
                          String formattedCVV = widget.controller!.text.replaceAll(RegExp(r'\D'), ''); // Remove non-digit characters

                          // Check if the CVV field is empty
                          if (formattedCVV.isEmpty) {
                            setState(() {
                              _errorMessage = null; // Clear error message if the field is empty
                            });
                          } else if (formattedCVV.length != 3) {
                            setState(() {
                              _errorMessage = "Cvv number must be 3 digits";
                              exprmessage = "Cvv number must be 3 digits";
                            });
                          } else {
                            // Clear error message if the CVV is valid
                            setState(() {
                              _errorMessage = null;
                              exprmessage = "";
                            });
                          }

                          // Notify parent about the error message (if any)
                          if (widget.onErrorcvv != null) {
                            widget.onErrorcvv!(_errorMessage); // Pass the error message to the parent
                          }
                        }


                        if (value.isNotEmpty) {
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                        if (widget.onChanged != null) widget.onChanged!(value);
                        // print("callllll");
                      },
                      focusNode: _focusNode,
                      onTap: () {
                        if (widget.onTap != null) {
                          widget.onTap!();
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                      },
                      obscureText: widget.obscureText,
                      readOnly: widget.readOnnly,
                      keyboardType: widget.keyboardType,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          state.validate();
                        }
                        return null;
                      },

                      controller: widget.controller,
                      decoration: InputDecoration(
                        suffixIcon: widget.suffixIcon,
                        hintStyle:
                            TextStyle(fontSize: 13, color: Color(0xFFb0b6c3)),
                        border: InputBorder.none,
                        hintText: widget.hintText,

                      ),
                      style: TextStyle(
                        color: widget.allerror ==true?exprmessage != ""? Colors.red : Colors.green : Colors.black
                      ),
                    ),
                  ),
                ),
                if (state.hasError && _errorMessage != null ||
                    widget.amount_check != null)
                  SizedBox(height: 24),
                // Reserve space for error message
              ],
            );
          },
        ),
        if (_errorMessage != null)
          Positioned(
            top: 60,
            left: 8,
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red,
                fontSize: 12.0,
              ),
            ),
          ),
      ],
    );
    return shouldUseKeyboardActions
        ? SizedBox(
            height: widget.amount_check != null
                ? widget.amount_check!
                    ? 75
                    : 60
                : _errorMessage != null
                    ? 75
                    : 60,
            width: MediaQuery.of(context).size.width * .98,
            child: KeyboardActions(
              config: _buildConfig(context),
              child: textfield,
            ),
          )
        : textfield;
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll('/', '');

    if (newText.length > 6) {
      newText = newText.substring(0, 6);
    }

    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(newText[i]);
    }

    return newValue.copyWith(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
