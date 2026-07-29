import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/tenants.dart';
import '../../../Model/setting.dart';
import '../../../constant/constant.dart';
import '../../../screens/Leasing/RentalRoll/addcard/CardModel.dart';
import '../../../model/LeaseSummary.dart';
import '../../../repository/lease.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_drawer.dart';
import '../../../widgets/titleBar.dart';
import '../../../screens/Leasing/RentalRoll/addcard/AddCard.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';

class RecurringPayment extends StatefulWidget {
  String leaseId;
  String tenantId;
  Data leaseData;
  RecurringPayment(
      {super.key,
      required this.leaseData,
      required this.leaseId,
      required this.tenantId});

  @override
  State<RecurringPayment> createState() => _RecurringPaymentState();
}

class _RecurringPaymentState extends State<RecurringPayment> {
  List<int> customervaultid = [];
  List<BillingData> cardDetails = [];
  Map<int, List<Map<String?, dynamic?>>> tenantDropdowns = {};
  double totalAmount = 0.0;
  List<Setting4> accounts = [];

  @override
  void initState() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        print(result);
        //  _connectivityResult = result;
      });
    });
    //checkInternet();
    // getAllTenantCardData();

    fetchAccounts();
    fetchExistingCards(widget.tenantId, widget.leaseId, 0);
    super.initState();
  }

  void fetchAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');

    final response = await apiGet(
      Uri.parse('${Api_url}/api/accounts/accounts/$id'),
      headers: {
        'authorization': 'CRM $token',
        'id': 'CRM ${prefs.getString("tenant_id") ?? id}',
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
    }
  }

  void getcards() {
    for (int i = 0; i < widget.leaseData.tenantData!.length; i++) {
      fetchExistingCards(widget.leaseData.tenantData![i].tenantId!,
          widget.leaseData.leaseId!, i);
    }
  }

  void fetchExistingCards(String tenantid, String leaseid, int index) async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');

    final response = await apiPost(
      Uri.parse('${Api_url}/api/recurring-cards/get-cards'),
      headers: {
        'authorization': 'CRM $token',
        'id': 'CRM ${prefs.getString("tenant_id") ?? id}',
      },
      body: {
        "lease_id": leaseid,
        "tenant_id": tenantid,
      },
    );

    print(response.body);
    Map<String, dynamic> Response = json.decode(response.body);

    if (Response["statusCode"] == 200) {
      Map<String, dynamic> jsonResponse = Response['data'];

      setState(() {
        final recurring = jsonResponse["recurrings"][0];

        String? fetchedBillingId = recurring['billing_id'];
        String? fetchedCardType = recurring['card_type'];

        bool cardExists =
            cardDetails.any((card) => card.billingId == fetchedBillingId);
        String selectedCard =
            cardExists && fetchedBillingId != null && fetchedCardType != null
                ? "${fetchedBillingId}_${fetchedCardType}"
                : "";

        List<Setting4> accountMatches = accounts
            .where((acc) => acc.account == recurring['account'])
            .toList();
        Setting4? fetchaccount =
            accountMatches.isNotEmpty ? accountMatches.first : null;

        tenantDropdowns[index] = [
          {
            "selectedCard": selectedCard,
            "selectedDay": recurring['date'] ?? "",
            "selectedAccount": fetchaccount != null
                ? "${fetchaccount.account}_${fetchaccount.createdAt}"
                : "",
            "amount": TextEditingController(
                text: recurring['amount']?.toString() ?? ""),
            "scrollController": ScrollController(),
          }
        ];

        isScrollLeft.add(false);
      });

      calculateTotal();
      checkFieldsFilled();
    } else {
      print('Failed to fetch settings: ${response.body}');
    }
  }

  Map<int, String?> selectedCard = {};
  Map<int, int?> selectedDay = {};
  bool isLoading = false;
  bool isloading = false;
  String? messageCardAvailable;
  List<List<ScrollController>> rowControllers = [];
  List<bool> isScrollLeft = [];

  void scrollAllRows(int index) {
    double offsetChange = 400;
    List rowscroll = tenantDropdowns[index]!;

    for (int i = 0; i < rowscroll.length; i++) {
      ScrollController controller =
          tenantDropdowns[index]?[i]["scrollController"];

      if (isScrollLeft[index]) {
        controller.jumpTo(controller.offset - offsetChange);
      } else {
        controller.jumpTo(controller.offset + offsetChange);
      }
    }

    setState(() {
      this.isScrollLeft[index] = !this.isScrollLeft[index];
    });
  }

  bool isButtonEnabled = false;

  void checkFieldsFilled() {
    bool allFieldsFilled = true;

    tenantDropdowns.forEach((index, tenantData) {
      print(index);
      for (int i = 0; i < tenantData.length; i++) {
        if (tenantData[i]['selectedCard'] == null ||
            tenantData[i]['selectedAccount'] == null ||
            tenantData[i]['amount']?.text.isEmpty == true ||
            tenantData[i]['selectedDay'] == null) {
          allFieldsFilled = false;
        }
      }
    });

    setState(() {
      isButtonEnabled = allFieldsFilled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Leases",
        dropdown: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: blueColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Text(
                          "Configure Recurring Payment",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: blueColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Text(
                          "Total Rent Amount : \$${(widget.leaseData.amount ?? 0).toStringAsFixed(2)}",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: blueColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 17),
                    isLoading
                        ? Center(
                            child: SpinKitFadingCircle(
                              color: blueColor,
                              size: 40.0,
                            ),
                          )
                        : Column(
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
                                      card.customerVaultId ==
                                      vaultId.toString())
                                  .toList();

                              return Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Tenant Name Header
                                    Text(
                                      '${tenant.tenantFirstName ?? 'N/A'} ${tenant.tenantLastName ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: blueColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      height: 1,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 16),

                                    // Payment Rows
                                    Column(
                                      children: List.generate(
                                        tenantDropdowns[index]!.length,
                                        (rowIndex) {
                                          return Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 16),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.grey.shade200,
                                                width: 1,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Payment Title Row
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Payment ${rowIndex + 1}",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: blueColor,
                                                      ),
                                                    ),
                                                    if (tenantDropdowns[index]!
                                                            .length >
                                                        1)
                                                      GestureDetector(
                                                        onTap: () {
                                                          calculateTotal();
                                                          setState(() {
                                                            tenantDropdowns[
                                                                    index]!
                                                                .removeAt(
                                                                    rowIndex);
                                                            checkFieldsFilled();
                                                          });
                                                        },
                                                        child: const FaIcon(
                                                          FontAwesomeIcons
                                                              .trashCan,
                                                          size: 16,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),

                                                // Form Fields in Column Layout
                                                Column(
                                                  children: [
                                                    // Choose Card Field
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Choose Card *",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors
                                                                .grey.shade700,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 4),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                            border: Border.all(
                                                              color: Colors.grey
                                                                  .shade300,
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child:
                                                              DropdownButtonHideUnderline(
                                                            child:
                                                                DropdownButton2<
                                                                    String>(
                                                              hint: const Text(
                                                                'Select card',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                              isExpanded: true,
                                                              value: tenantDropdowns[
                                                                          index]![
                                                                      rowIndex][
                                                                  "selectedCard"],
                                                              items: [
                                                                if (tenantCards
                                                                    .isNotEmpty)
                                                                  ...tenantCards
                                                                      .map(
                                                                          (card) {
                                                                    String
                                                                        uniqueKey =
                                                                        "${card.billingId}_${card.binResult}";
                                                                    return DropdownMenuItem<
                                                                        String>(
                                                                      value:
                                                                          uniqueKey,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Container(
                                                                            height:
                                                                                24,
                                                                            width:
                                                                                24,
                                                                            child:
                                                                                Image.network("https://logo.clearbit.com/${card.ccType!.replaceAll(RegExp(r'[-\s]'), "").toLowerCase()}.com"),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 8),
                                                                          Expanded(
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  "${card.ccNumber}",
                                                                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                                                ),
                                                                                Text(
                                                                                  "${card.binResult != null ? card.binResult : "N/A"} • ${card.ccExp}",
                                                                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  }).toList()
                                                                else
                                                                  const DropdownMenuItem<
                                                                      String>(
                                                                    value: '',
                                                                    child: Text(
                                                                        'No cards available'),
                                                                  ),
                                                                DropdownMenuItem<
                                                                    String>(
                                                                  value: 'Add',
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap:
                                                                        () async {
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              AddCard(
                                                                            leaseId:
                                                                                widget.leaseData.leaseId ?? "",
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          40,
                                                                      color:
                                                                          blueColor,
                                                                      child:
                                                                          const Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          SizedBox(
                                                                              width: 10),
                                                                          Text(
                                                                            'Add Card',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.white,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  tenantDropdowns[
                                                                              index]![
                                                                          rowIndex]
                                                                      [
                                                                      "selectedCard"] = value;
                                                                });
                                                              },
                                                              selectedItemBuilder:
                                                                  (BuildContext
                                                                      context) {
                                                                return tenantCards
                                                                    .map(
                                                                        (card) {
                                                                  return Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child: Text(
                                                                      card.ccNumber!,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  );
                                                                }).toList();
                                                              },
                                                              menuItemStyleData:
                                                                  const MenuItemStyleData(
                                                                height: 40,
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                              ),
                                                              buttonStyleData:
                                                                  const ButtonStyleData(
                                                                height: 50,
                                                              ),
                                                              iconStyleData:
                                                                  const IconStyleData(
                                                                icon: Icon(
                                                                  Icons
                                                                      .keyboard_arrow_down,
                                                                ),
                                                                iconSize: 20,
                                                                iconEnabledColor:
                                                                    Colors.grey,
                                                                iconDisabledColor:
                                                                    Colors.grey,
                                                              ),
                                                              dropdownStyleData:
                                                                  DropdownStyleData(
                                                                maxHeight: 200,
                                                                width: 300,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              6),
                                                                ),
                                                                offset:
                                                                    const Offset(
                                                                        0, -5),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    const SizedBox(height: 16),

                                                    // Choose Day of Month Field
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Choose Day of Month *",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors
                                                                .grey.shade700,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 4),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                            border: Border.all(
                                                              color: Colors.grey
                                                                  .shade300,
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child:
                                                              DropdownButtonHideUnderline(
                                                            child:
                                                                DropdownButton2<
                                                                    String>(
                                                              hint: const Text(
                                                                'Select Day of Month',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                              isExpanded: true,
                                                              value: tenantDropdowns[index]![
                                                                              rowIndex]
                                                                          [
                                                                          "selectedDay"] !=
                                                                      null
                                                                  ? tenantDropdowns[
                                                                              index]![rowIndex]
                                                                          [
                                                                          "selectedDay"]
                                                                      .toString()
                                                                  : null,
                                                              items: List
                                                                      .generate(
                                                                          28,
                                                                          (i) =>
                                                                              i +
                                                                              1)
                                                                  .map((day) =>
                                                                      DropdownMenuItem<
                                                                          String>(
                                                                        value: day
                                                                            .toString(),
                                                                        child: Text(
                                                                            '$day'),
                                                                      ))
                                                                  .toList(),
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  tenantDropdowns[
                                                                              index]![
                                                                          rowIndex]
                                                                      [
                                                                      "selectedDay"] = value;
                                                                  checkFieldsFilled();
                                                                });
                                                              },
                                                              buttonStyleData:
                                                                  const ButtonStyleData(
                                                                height: 50,
                                                              ),
                                                              iconStyleData:
                                                                  const IconStyleData(
                                                                icon: Icon(
                                                                  Icons
                                                                      .keyboard_arrow_down,
                                                                ),
                                                                iconSize: 20,
                                                                iconEnabledColor:
                                                                    Colors.grey,
                                                                iconDisabledColor:
                                                                    Colors.grey,
                                                              ),
                                                              dropdownStyleData:
                                                                  DropdownStyleData(
                                                                maxHeight: 200,
                                                                width: 150,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              6),
                                                                ),
                                                                offset:
                                                                    const Offset(
                                                                        0, -5),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    const SizedBox(height: 16),

                                                    // Account Field
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Account *",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors
                                                                .grey.shade700,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 4),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                            border: Border.all(
                                                              color: Colors.grey
                                                                  .shade300,
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child:
                                                              DropdownButtonHideUnderline(
                                                            child:
                                                                DropdownButton2<
                                                                    String>(
                                                              hint: const Text(
                                                                'Rent Income',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                              isExpanded: true,
                                                              value: tenantDropdowns[
                                                                          index]![
                                                                      rowIndex][
                                                                  "selectedAccount"],
                                                              items: accounts
                                                                      .isNotEmpty
                                                                  ? accounts.map(
                                                                      (card) {
                                                                      String
                                                                          uniqueKey =
                                                                          "${card.account}_${card.createdAt}";
                                                                      return DropdownMenuItem<
                                                                          String>(
                                                                        value:
                                                                            uniqueKey,
                                                                        child: Text(
                                                                            "${card.account}"),
                                                                      );
                                                                    }).toList()
                                                                  : [
                                                                      const DropdownMenuItem<
                                                                          String>(
                                                                        value:
                                                                            '',
                                                                        child: Text(
                                                                            'No accounts available'),
                                                                      ),
                                                                    ],
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  tenantDropdowns[
                                                                              index]![
                                                                          rowIndex]
                                                                      [
                                                                      "selectedAccount"] = value;
                                                                  checkFieldsFilled();
                                                                });
                                                              },
                                                              buttonStyleData:
                                                                  const ButtonStyleData(
                                                                height: 50,
                                                              ),
                                                              iconStyleData:
                                                                  const IconStyleData(
                                                                icon: Icon(
                                                                  Icons
                                                                      .keyboard_arrow_down,
                                                                ),
                                                                iconSize: 20,
                                                                iconEnabledColor:
                                                                    Colors.grey,
                                                                iconDisabledColor:
                                                                    Colors.grey,
                                                              ),
                                                              dropdownStyleData:
                                                                  DropdownStyleData(
                                                                maxHeight: 200,
                                                                width: 200,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              6),
                                                                ),
                                                                offset:
                                                                    const Offset(
                                                                        0, -5),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    const SizedBox(height: 16),

                                                    // Amount Field
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Amount *",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors
                                                                .grey.shade700,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                            border: Border.all(
                                                              color: Colors.grey
                                                                  .shade300,
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: TextField(
                                                            controller:
                                                                tenantDropdowns[
                                                                            index]![
                                                                        rowIndex]
                                                                    ["amount"],
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            onChanged: (value) {
                                                              calculateTotal();
                                                              checkFieldsFilled();
                                                            },
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                            decoration:
                                                                const InputDecoration(
                                                              hintText:
                                                                  "\$0.00",
                                                              hintStyle:
                                                                  TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 14,
                                                              ),
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .symmetric(
                                                                vertical: 12,
                                                                horizontal: 12,
                                                              ),
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            6)),
                                                                borderSide:
                                                                    BorderSide
                                                                        .none,
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            6)),
                                                                borderSide:
                                                                    BorderSide
                                                                        .none,
                                                              ),
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            6)),
                                                                borderSide:
                                                                    BorderSide
                                                                        .none,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    // Add Row Button
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          tenantDropdowns[index]!.add({
                                            "selectedCard": null,
                                            "selectedDay": null,
                                            "selectedAccount": null,
                                            "amount": TextEditingController(),
                                            "scrollController":
                                                ScrollController(),
                                          });
                                          checkFieldsFilled();
                                        });
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: const Color(
                                                0xFF0078D4), // Azure blue
                                            width: 1,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add,
                                              color: Color(
                                                  0xFF0078D4), // Azure blue
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Add Row",
                                              style: TextStyle(
                                                color: Color(
                                                    0xFF0078D4), // Azure blue
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                    Center(
                        child: Text(
                      "Total Amount : \$${totalAmount}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: blueColor,
                          fontSize: 14.5),
                    )),
                    const SizedBox(height: 10),
                    // Azure-style Action Buttons
                    Column(
                      children: [
                        // Cancel and Save buttons in a row
                        Row(
                          children: [
                            // Cancel Button - Azure style
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Color(0xFF0078D4), // Azure blue
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Save Button - Azure style (disabled state)
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  if (!isButtonEnabled || isloading) return;

                                  setState(() {
                                    isloading = true;
                                  });

                                  List<Map<String, dynamic>>
                                      selectedTenantsData = [];

                                  for (int i = 0;
                                      i < widget.leaseData.tenantData!.length;
                                      i++) {
                                    var tenant =
                                        widget.leaseData.tenantData![i];
                                    int? vaultId = customervaultid.length > i
                                        ? customervaultid[i]
                                        : null;
                                    List<Map<String, dynamic>> recurringsList =
                                        [];

                                    for (var row in tenantDropdowns[i]!) {
                                      if (row['selectedCard'] != null &&
                                          row['selectedAccount'] != null &&
                                          row['amount'].text.isNotEmpty &&
                                          row['selectedDay'] != null) {
                                        var cardData =
                                            row['selectedCard']!.split('_');
                                        String billingId = cardData.length > 1
                                            ? cardData[0]
                                            : "";
                                        String cardtype = cardData.length > 1
                                            ? cardData[1]
                                            : "";
                                        var rec_accounts =
                                            row['selectedAccount']!.split('_');
                                        String selectedacc =
                                            rec_accounts.length > 1
                                                ? rec_accounts[0]
                                                : '';
                                        String amount = row['amount'].text;

                                        recurringsList.add({
                                          "billing_id": billingId,
                                          "amount": amount,
                                          "card_type": cardtype,
                                          "account": selectedacc,
                                          "date":
                                              row['selectedDay']?.toString() ??
                                                  "",
                                        });
                                      }
                                    }

                                    if (recurringsList.isNotEmpty) {
                                      selectedTenantsData.add({
                                        "tenant_id": tenant.tenantId,
                                        "lease_id": widget.leaseData.leaseId!,
                                        "customer_vault_id":
                                            vaultId?.toString() ?? "",
                                        "recurrings": recurringsList,
                                      });
                                    }
                                  }

                                  if (isButtonEnabled) {
                                    try {
                                      await postLease(selectedTenantsData);
                                    } catch (e) {
                                      print("Error: $e");
                                    } finally {
                                      setState(() {
                                        isloading = false;
                                      });
                                      Navigator.pop(context);
                                    }
                                  }
                                },
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isButtonEnabled
                                        ? const Color(
                                            0xFF6C757D) // Azure grey for disabled
                                        : const Color(0xFF6C757D),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: isloading
                                      ? const Center(
                                          child: SpinKitFadingCircle(
                                            color: Colors.white,
                                            size: 20.0,
                                          ),
                                        )
                                      : const Center(
                                          child: Text(
                                            "Save",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Disable Button - Azure style (full width, primary)
                        GestureDetector(
                          onTap: () {
                            disablecards(widget.leaseData!.leaseId!);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 40,
                            decoration: BoxDecoration(
                              color: blueColor, // Azure primary blue
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Center(
                              child: Text(
                                "Disable",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
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
      headers: {"id": "CRM ${prefs.getString('tenant_id') ?? id}", "authorization": "CRM $token"},
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
        print('Customer vault ID not found for tenant: $tenantId');
        setState(() {
          customervaultid.add(0);
        });
      }
    } else if (response.statusCode == 404) {
      print('Customer vault ID not found for tenant: $tenantId');
      setState(() {
        customervaultid.add(0);
      });
    } else {
      print('Failed to load credit card data');
    }

    setState(() {
      isLoading = false;
    });
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
        "id": "CRM ${prefs.getString('tenant_id') ?? adminId}",
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

        for (int i = 0; i < cardDetailsList.length; i++) {
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    try {
      final response = await apiPost(
        url,
        headers: {
          "authorization": "CRM $token",
          "id": "CRM ${prefs.getString('tenant_id') ?? id}",
          'Content-Type': 'application/json'
        },
        body: jsonEncode(lease),
      );

      var responseData = jsonDecode(response.body);
      print('Response body of the lease :${response.body}');
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    try {
      final response = await apiPut(
        url,
        headers: {
          "authorization": "CRM $token",
          "id": "CRM ${prefs.getString('tenant_id') ?? id}",
          'Content-Type': 'application/json'
        },
      );

      var responseData = jsonDecode(response.body);
      print('Response body of the lease :${response.body}');
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

}
