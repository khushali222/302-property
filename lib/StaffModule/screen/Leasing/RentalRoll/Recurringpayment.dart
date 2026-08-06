import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/setting.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'addcard/CardModel.dart';
import '../../../../model/LeaseSummary.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_drawer.dart';
import 'addcard/AddCard.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';

class RecurringPayment extends StatefulWidget {
  Data leaseData;
  RecurringPayment({super.key, required this.leaseData});

  @override
  State<RecurringPayment> createState() => _RecurringPaymentState();
}

class _RecurringPaymentState extends State<RecurringPayment> {
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
      isButtonEnabled = true;
    });
    if (widget.leaseData.tenantData != null &&
        widget.leaseData.tenantData!.isNotEmpty) {
      List<String> tenantIds = widget.leaseData.tenantData!
          .map((tenant) => tenant.tenantId!)
          .toList();

      for (String tenantId in tenantIds) {
        await fetchcreditcard(tenantId);
      }

      getcards();
      setState(() {
        for (int i = 0; i < tenantIds.length; i++) {
          tenantDropdowns[i] = [
            {
              "selectedCard": null,
              "selectedDay": null,
              "selectedAccount": null,
              "amount": TextEditingController(),
              "scrollController": ScrollController(),
            }
          ];
          isScrollLeft.add(false);
        }

        isLoading = false;
      });
      checkFieldsFilled();
    } else {
      setState(() {
        isLoading = false;
        isButtonEnabled = false; // No tenants = Button remains disabled
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
    String? adminid = prefs.getString('adminId');
    String? id = prefs.getString("staff_id");
    final response = await apiGet(
      Uri.parse('${Api_url}/api/accounts/accounts/$adminid'),
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
    String? id = prefs.getString("staff_id");
    try {
      final requestBody = {
        "lease_id": leaseid,
        "tenant_id": tenantid,
        "is_web": true,
        "user_active_recently": true,
      };

      final response = await apiPost(
        Uri.parse('${Api_url}/api/recurring-cards/get-cards'),
        headers: {
          'authorization': 'CRM $token',
          'id': 'CRM $id',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );


      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return;
      }

      final statusCode = decoded["statusCode"];
      if (statusCode != 200) {
        final msg = decoded["message"]?.toString();
        messageCardAvailable = msg;
        return;
      }

      final data = decoded['data'];
      if (data is! Map<String, dynamic>) {
        return;
      }

      final recurrings = data["recurrings"];
      if (recurrings is! List || recurrings.isEmpty) {
        return;
      }

      final recurring = recurrings.first;
      if (recurring is! Map<String, dynamic>) {
        return;
      }

      setState(() {
        final fetchedBillingId = recurring['billing_id']?.toString();
        final fetchedCardType = recurring['card_type']?.toString();

        final accountName = recurring['account']?.toString();
        final matches = accountName == null
            ? <Setting4>[]
            : accounts.where((acc) => acc.account == accountName).toList();
        final fetchaccount = matches.isNotEmpty ? matches.first : null;

        tenantDropdowns[index] = [
          {
            "selectedCard":
                (fetchedBillingId != null && fetchedCardType != null)
                    ? "${fetchedBillingId}_${fetchedCardType}"
                    : null,
            "selectedDay": recurring['date'],
            "selectedAccount": fetchaccount != null
                ? "${fetchaccount.account}_${fetchaccount.createdAt}"
                : null,
            "amount": TextEditingController(
                text: recurring['amount']?.toString() ?? ""),
            "scrollController": ScrollController(),
          }
        ];
      });

      calculateTotal();
      checkFieldsFilled();
    } catch (e, st) {
      Fluttertoast.showToast(msg: 'Could not load saved cards.');
    }
  }

  Map<int, String?> selectedCard = {};
  Map<int, int?> selectedDay = {};
  bool isLoading = false;
  bool isloading = false;
  String? messageCardAvailable;
  List<List<ScrollController>> rowControllers =
      []; // List of List for ScrollControllers
  List<bool> isScrollLeft = [];
  // Function to scroll all rows
  void scrollAllRows(int index) {
    double offsetChange = 400; // Amount to scroll by
    List rowscroll = tenantDropdowns[index]!;

    for (int i = 0; i < rowscroll.length; i++) {
      ScrollController controller =
          tenantDropdowns[index]?[i]["scrollController"];

      if (isScrollLeft[index]) {
        controller.jumpTo(controller.offset - offsetChange); // Scroll left
      } else {
        controller.jumpTo(controller.offset + offsetChange); // Scroll right
      }
    }

    // Toggle scroll direction after scrolling
    setState(() {
      this.isScrollLeft[index] = !this.isScrollLeft[index];
    });
  }

  bool isButtonEnabled = false;

  void checkFieldsFilled() {
    bool allFieldsFilled = true;

    // Loop through all tenant data and check the fields

    tenantDropdowns.forEach((index, tenantData) {
      for (int i = 0; i < tenantData.length; i++) {
        if (tenantData[i]['selectedCard'] == null ||
            tenantData[i]['selectedAccount'] == null ||
            tenantData[i]['amount']?.text.isEmpty == true ||
            tenantData[i]['selectedDay'] == null) {
          allFieldsFilled = false; // If any field is empty, set to false
        }
      }

//
    });

    setState(() {
      isButtonEnabled =
          allFieldsFilled; // Enable button if all fields are filled
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302_Staff.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawerStaff(
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
                        Material(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new,
                                  color: Colors.black87, size: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Configure Recurring Payment",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: blueColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 17),

                    Row(
                      children: [
                        SizedBox(width: 8),
                        Text(
                          "Total Rent Amount : ${formatMoney(widget.leaseData.amount ?? 0)}",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: blueColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                              final tenantCards = cardDetails
                                  .where((card) =>
                                      card.customerVaultId ==
                                      (vaultId == null
                                          ? null
                                          : vaultId.toString()))
                                  .where((card) =>
                                      (card.ccType ?? '').trim().isNotEmpty &&
                                      (card.ccNumber ?? '').trim().isNotEmpty)
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
                                                                  vertical: 1),
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
                                                                                Image.network(
                                                                              "https://logo.clearbit.com/${(card.ccType ?? '').replaceAll(RegExp(r'[-\s]'), '').toLowerCase()}.com",
                                                                              errorBuilder: (context, error, stackTrace) {
                                                                                return const Icon(Icons.credit_card, size: 20, color: Colors.grey);
                                                                              },
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 8),
                                                                          Expanded(
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  "${card.ccNumber ?? ''}",
                                                                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                                                ),
                                                                                Text(
                                                                                  "${(card.binResult == null || card.binResult == "Unknown") ? (card.ccType ?? "N/A") : card.binResult} • ${card.ccExp ?? ''}",
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
                                                                      card.ccNumber ??
                                                                          '',
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
                                                                  vertical: 1),
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
                                                                            '$day', style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),),
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
                                                         padding: EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                                                        
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
                                                                            "${card.account}", style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),),
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
                                                              color: Colors.black,
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
                                                                vertical: 15,
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
                      "Total Amount : ${formatMoney(totalAmount)}",
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
                    const SizedBox(height: 10),
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
    // Staff's OWN id in the `id` header (adminId is rejected for staff).
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    final slotIndex = customervaultid.length;
    customervaultid.add(0); // keep tenant index alignment even on errors

    try {
      final response = await apiGet(
        Uri.parse('$Api_url/api/creditcard/getCreditCards/$tenantId'),
        headers: {"id": "CRM $id", "authorization": "CRM $token"},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is! Map<String, dynamic>) {
          return;
        }

        final custvaultid = decoded['customer_vault_id'];
        if (custvaultid is int) {
          customervaultid[slotIndex] = custvaultid;
          final cardDetailsList = (decoded['card_detail'] is List)
              ? (decoded['card_detail'] as List<dynamic>)
              : <dynamic>[];

          for (var cardDetail in cardDetailsList) {
            if (cardDetail is Map) {
            }
          }

          CustomerData? customerData = await postBillingCustomerVault(
              custvaultid.toString(), cardDetailsList);

          if (customerData != null) {
            setState(() {
              cardDetails.addAll(customerData.billing);
            });
          }
        } else {
        }
      } else if (response.statusCode == 404) {
      } else {
      }
    } catch (e, st) {
      Fluttertoast.showToast(msg: 'Could not load saved cards.');
    }
  }

  Future<CustomerData?> postBillingCustomerVault(
      String customerVaultId, List<dynamic> cardDetailsList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    // The `id` header must be the staff's OWN id; the company adminId still
    // goes in the request body's admin_id below.
    String? staffId = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    Map<String, String> requestBody = {
      "customer_vault_id": customerVaultId,
      "admin_id": adminId.toString(),
    };
    final response = await apiPost(
      Uri.parse('$Api_url/api/nmipayment/get-billing-customer-vault'),
      headers: {
        'Content-Type': 'application/json',
        "id": "CRM $staffId",
        "authorization": "CRM $token",
      },
      body: json.encode(requestBody),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['data'].toString() == "{}") {
        return null;
      } else {
        var customerJson = jsonResponse['data']['customer'];
        CustomerData customerData = CustomerData.fromJson(customerJson);

        customerData.billing.forEach((billing) {
        });

        final billingById = <String, BillingData>{};
        for (final b in customerData.billing) {
          final id = b.billingId;
          if (id != null) billingById[id] = b;
        }

        for (final detail in cardDetailsList) {
          if (detail is! Map) continue;
          final billingId = detail["billing_id"]?.toString();
          if (billingId == null) continue;
          final cardType = detail["card_type"]?.toString();
          final matched = billingById[billingId];
          if (matched != null) {
            matched.binResult = cardType;
          }
        }

        return customerData;
      }
    } else {
      return null;
    }
  }

  postLease(List<Map<String, dynamic>> lease) async {
    final url = Uri.parse('${Api_url}/api/recurring-cards/add-cards');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    // Staff's OWN id in the `id` header (adminId is rejected for staff).
    String? id = prefs.getString('staff_id');
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['statusCode'] == 200) {

          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Successfully added lease');

          return true;
        } else {
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Failed to add lease');
          return false;
        }
      } else {}
    } catch (error) {
      Fluttertoast.showToast(msg: 'An error occurred');
      return false;
    }
  }

  disablecards(String leaseid) async {
    final url =
        Uri.parse('${Api_url}/api/recurring-cards/disable-cards/${leaseid}');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    // Staff's OWN id in the `id` header (adminId is rejected for staff).
    String? id = prefs.getString('staff_id');
    try {
      final response = await apiPut(
        url,
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          'Content-Type': 'application/json'
        },
      );

      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['statusCode'] == 200) {

          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Successfully added lease');

          return true;
        } else {
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Failed to add lease');
          return false;
        }
      } else {}
    } catch (error) {
      Fluttertoast.showToast(msg: 'An error occurred');
      return false;
    }
  }

}
