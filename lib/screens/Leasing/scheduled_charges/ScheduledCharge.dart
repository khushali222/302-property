import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Model/Scheduled_Payment_model.dart';
import '../../../Model/schduled_charge.dart';
import '../../../constant/constant.dart';
import '../../../provider/dateProvider.dart';
import '../../../repository/ScheduledChargesRepository.dart';
import '../../../repository/Scheduled_Payment_repo.dart';
import '../../../widgets/CustomTableShimmer.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_drawer.dart';
import '../../../widgets/titleBar.dart';
import '../RentalRoll/SummeryPageLease.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';

import 'package:http/http.dart' as http;
class ScheduledChargeTable extends StatefulWidget {
  String? leaseID;
   ScheduledChargeTable({super.key,this.leaseID});

  @override
  State<ScheduledChargeTable> createState() => _ScheduledChargeTableState();
}

class _ScheduledChargeTableState extends State<ScheduledChargeTable> {
  int totalrecords = 0;
  late Future<List<ScheduledCharges>> futurescheduledpayment;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  int currentPage = 0;
  int itemsPerPage = 10;
  List<int> itemsPerPageOptions = [
    10,
    25,
    50,
    100,
  ]; // Options for items per page

  int? expandedIndex;
  Set<int> expandedIndices = {};
  late bool isExpanded;
  bool sorting1 = false;
  bool sorting2 = false;
  bool sorting3 = false;
  bool ascending1 = false;
  bool ascending2 = false;
  bool ascending3 = false;
  Widget _buildHeaders() {
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: blueColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(13),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        // leading: Container(
        //   child: Icon(
        //     Icons.expand_less,
        //     color: Colors.transparent,
        //   ),
        // ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Icon(
                Icons.expand_less,
                color: Colors.transparent,
              ),
            ),
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sorting1 == true) {
                      sorting2 = false;
                      sorting3 = false;
                      ascending1 = sorting1 ? !ascending1 : true;
                      ascending2 = false;
                      ascending3 = false;
                    } else {
                      sorting1 = !sorting1;
                      sorting2 = false;
                      sorting3 = false;
                      ascending1 = sorting1 ? !ascending1 : true;
                      ascending2 = false;
                      ascending3 = false;
                    }

                    // Sorting logic here
                  });
                },
                child: Row(
                  children: [
                    width < 400 ? Text("Date ", style: TextStyle(color: Colors.white)) : Text("Date", style: TextStyle(color: Colors.white)),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 3),
                    // ascending1
                    //     ? Padding(
                    //         padding: const EdgeInsets.only(top: 7, left: 2),
                    //         child: FaIcon(
                    //           FontAwesomeIcons.sortUp,
                    //           size: 20,
                    //           color: Colors.white,
                    //         ),
                    //       )
                    //     : Padding(
                    //         padding: const EdgeInsets.only(bottom: 7, left: 2),
                    //         child: FaIcon(
                    //           FontAwesomeIcons.sortDown,
                    //           size: 20,
                    //           color: Colors.white,
                    //         ),
                    //       ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sorting2) {
                      sorting1 = false;
                      sorting2 = sorting2;
                      sorting3 = false;
                      ascending2 = sorting2 ? !ascending2 : true;
                      ascending1 = false;
                      ascending3 = false;
                    } else {
                      sorting1 = false;
                      sorting2 = !sorting2;
                      sorting3 = false;
                      ascending2 = sorting2 ? !ascending2 : true;
                      ascending1 = false;
                      ascending3 = false;
                    }
                    // Sorting logic here
                  });
                },
                child: Row(
                  children: [
                    Text("   Account", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 5),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sorting3) {
                      sorting1 = false;
                      sorting2 = false;
                      sorting3 = sorting3;
                      ascending3 = sorting3 ? !ascending3 : true;
                      ascending2 = false;
                      ascending1 = false;
                    } else {
                      sorting1 = false;
                      sorting2 = false;
                      sorting3 = !sorting3;
                      ascending3 = sorting3 ? !ascending3 : true;
                      ascending2 = false;
                      ascending1 = false;
                    }

                    // Sorting logic here
                  });
                },
                child: Row(
                  children: [
                    Text("Amount", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<String> items = ['Residential', "Commercial", "All"];
  String? selectedValue;
  String? selectedChargeType;
  String searchvalue = "";
  ConnectivityResult? _connectivityResult;
  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        print(result);
        _connectivityResult = result;
      });
    });
    checkInternet();
    fetchDropdownData();
    futurescheduledpayment = ScheduledChargesRepository().fetchScheduledCharges(leaseid: widget.leaseID);
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  void _showAlert(BuildContext context, String id, ScheduledCharges payment) {
    TextEditingController reason = TextEditingController();
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      content: Column(
        children: <Widget>[
          if(widget.leaseID == null)
          Text(
            "You want to delete this scheduled charge for ${payment.rentalAddress} in the amount of \$${payment.amount} on ${payment.actionDate}?",
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 16),
          ),
          if(widget.leaseID != null)
            Text(
              "You want to delete this scheduled charge for the amount of \$${payment.amount} on ${payment.actionDate}?",
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16),
            ),
          SizedBox(height: 10),
          SizedBox(
            height: 45,
            child: TextField(
              controller: reason,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter reason for deletion',
                contentPadding: EdgeInsets.only(top: 8, left: 15),
              ),
            ),
          ),
        ],
      ),
      style: AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            var data =  await ScheduledChargesRepository().deleteNote( noteid: id);
            if(data != null)
              setState(() {
                futurescheduledpayment = ScheduledChargesRepository().fetchScheduledCharges(leaseid: widget.leaseID);
              });
            Navigator.pop(context);
          },
          color:blueColor,
        ),
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.grey,
        ),
      ],
    ).show();

  }
   List<Map<String,dynamic>> accountOptions = [

  ];
  Future<void> fetchDropdownData() async {
    // try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String adminId = prefs.getString('adminId') ?? '';
    String? token = prefs.getString('token');
    print(token);
 //   print('lease ${widget.leaseId}');
    String? id = prefs.getString("adminId");
    final response = await http.get(
      Uri.parse('$Api_url/api/accounts/accounts/$adminId'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body)['data'];
    //  log("accounts data $jsonResponse");
      Map<String, List<String>> fetchedData = {};
      // Adding static items to the "LIABILITY ACCOUNT" category


      for (var item in jsonResponse) {
        String chargeType = item['charge_type'] ?? "One Time Charge";
        String account = item['account'];
      setState(() {
        accountOptions.add({
          "account": account,
          "value": chargeType,
        });
      });




      }


    } else {
      setState(() {

      });
    }
    // } catch (e) {
    //   print(e);
    //   setState(() {
    //     hasError = true;
    //     isLoading = false;
    //   });
    // }
  }
  EditCharge(){

  print(accountOptions);
   return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Scheduled Charge',style: TextStyle(color: blueColor,fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Date",style: TextStyle(color: blueColor,fontWeight: FontWeight.bold),),
                  CustomTextField(
                    onTap: _pickDate,
                    readOnnly: true,
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.date_range_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select start date';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    hintText: 'YYYY-MM-DD',
                    controller: dateController,
                  ),
                ],
              ),
              // Date Picker

              SizedBox(height: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Account",style: TextStyle(color: blueColor,fontWeight: FontWeight.bold),),
                  DropdownButtonHideUnderline(
                    child: DropdownButtonFormField2<String>(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      isExpanded: true,
                      hint: const Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Select Account',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFFb0b6c3),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      items: accountOptions.map((account) {
                        return DropdownMenuItem<String>(
                          value: account["account"],
                          child: Text(account["account"]),
                        );
                      }).toList(),
                      value: selectedAccount != null &&
                          accountOptions.any((account) => account["account"] == selectedAccount)
                          ? selectedAccount
                          : null,
                      onChanged: (value) {
                        setState(() {
                          // Find the selected account in the accountOptions list
                          var selectedOption = accountOptions.firstWhere(
                                (account) => account["account"] == value,
                           // orElse: () => null,
                          );

                          if (selectedOption != null) {
                            // Extract the charge type from the selected account
                            String chargeType = selectedOption["charge_type"] ?? "One Time Charge";

                            print("Selected Account: $value");
                            print("Charge Type: $chargeType");
                            selectedChargeType = chargeType;
                            selectedAccount = value;
                          }
                        });
                      },
                      buttonStyleData: ButtonStyleData(
                        height: 45,
                        width: 160,
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

                ],
              ),
              // Account Dropdown

              SizedBox(height: 10),

              // Amount Input
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Amount",style: TextStyle(color: blueColor,fontWeight: FontWeight.bold),),
                  CustomTextField(
                   // onTap: _pickDate,
                    readOnnly: false,

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select start date';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    hintText: '',
                    controller: amountController,
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Memo Input
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Memo",style: TextStyle(color: blueColor,fontWeight: FontWeight.bold),),
                  CustomTextField(
                  //  onTap: _pickDate,
                    readOnnly: false,

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select start date';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    hintText: '',
                    controller: memoController,
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Save'),
            onPressed: ()async{
             var response= await ScheduledChargesRepository().submitCharge(amount: amountController.text,account: selectedAccount,chargeType: selectedChargeType,action_date: dateController.text,description: memoController.text,charge_id: charge_id);
              if(response != null)
                {
                  Fluttertoast.showToast(msg: "Charge updated successfully");
                  setState(() {
                    futurescheduledpayment = ScheduledChargesRepository().fetchScheduledCharges(leaseid: widget.leaseID);
                  });
                  Navigator.of(context).pop();
                }
            },
          ),
        ],
      ),
    );
  }
  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        dateController.text = DateFormat("yyyy-MM-dd").format(selectedDate!);
      });
    }
  }

  DateTime? selectedDate;
  String? selectedAccount;
  String? charge_id;
  TextEditingController amountController = TextEditingController();
  TextEditingController memoController = TextEditingController();
  TextEditingController dateController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Scheduled Charges",
        dropdown: true,
      ),
      body: _connectivityResult != ConnectivityResult.none
          ? SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            //add propertytype
            Padding(
              padding: const EdgeInsets.only(left: 0, right: 0),
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: titleBar(
                      width: MediaQuery.of(context).size.width * .91,
                      title: 'Scheduled Charges',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            //search
            Padding(
              padding: const EdgeInsets.only(left: 11, right: 11),
              child: Row(
                children: [
                  if (MediaQuery.of(context).size.width < 500) SizedBox(width: 1),
                  if (MediaQuery.of(context).size.width > 500) SizedBox(width: 24),
                  Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      // height: 40,
                      height: MediaQuery.of(context).size.width < 500 ? 45 : 50,
                      width: MediaQuery.of(context).size.width < 500 ? MediaQuery.of(context).size.width * .52 : MediaQuery.of(context).size.width * .49,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          // border: Border.all(color: Colors.grey),
                          border: Border.all(color: Color(0xFF8A95A8))),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: TextField(
                              style: TextStyle(fontSize: MediaQuery.of(context).size.width < 500 ? 15 : 14),
                              // onChanged: (value) {
                              //   setState(() {
                              //     cvverror = false;
                              //   });
                              // },
                              // controller: cvv,
                              onChanged: (value) {
                                setState(() {
                                  searchvalue = value;
                                  if(currentPage != 0)
                                    currentPage = 0;
                                });
                              },
                              cursorColor: blueColor,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Search here...",
                                  hintStyle: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width < 500 ? 14 : 18,
                                    // fontWeight: FontWeight.bold,
                                    color: Color(0xFF8A95A8),
                                  ),
                                  contentPadding: EdgeInsets.only(left: 5, bottom: 12, top: 5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (MediaQuery.of(context).size.width > 500) SizedBox(height: 25),
            if (MediaQuery.of(context).size.width < 500)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: FutureBuilder<List<ScheduledCharges>>(
                  future: futurescheduledpayment,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ColabShimmerLoadingWidget();
                    }  else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container(
                        height: MediaQuery.of(context).size.height * .5,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/no_data.jpg",
                                height: 200,
                                width: 200,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "No Data Available",
                                style: TextStyle(fontWeight: FontWeight.bold, color: blueColor, fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      );
                    } else {
                       var data = snapshot.data!;
                      // if (selectedValue == null && searchvalue.isEmpty) {
                      //   data = snapshot.data!;
                      // } else if (selectedValue == "All") {
                      //   data = snapshot.data!;
                      // } else if (searchvalue.isNotEmpty) {
                      //   data = snapshot.data!
                      //       .where((applicant) =>
                      //   applicant.rentalAddress!
                      //       .toLowerCase()
                      //       .contains(searchvalue.toLowerCase()) ||
                      //       applicant.rentalAddress!.toString()
                      //           .toLowerCase()
                      //           .contains(searchvalue.toLowerCase()) ||
                      //       applicant.tenant!.tenantName.toString()
                      //           .toLowerCase()
                      //           .contains(searchvalue.toLowerCase())||
                      //       applicant.totalAmount.toString()
                      //           .toLowerCase()
                      //           .contains(searchvalue.toLowerCase())||
                      //       applicant.date.toString()
                      //           .toLowerCase()
                      //           .contains(searchvalue.toLowerCase())
                      //   )
                      //       .toList();
                      // } else {
                      //   data = snapshot.data!.where((applicant) => applicant.rentalAddress == selectedValue).toList();
                      // }
                      if (data.isEmpty) {
                        return Center(
                          child:
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/no_data.jpg",
                                height: 200,
                                width: 200,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "No Data Available",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: blueColor,
                                    fontSize: 16),
                              )
                            ],
                          ),
                        );
                      }
                      /* if (selectedValue == null && searchvalue!.isEmpty) {
                        data = snapshot.data!;
                      } else if (selectedValue == "All") {
                        data = snapshot.data!;
                      } else if (searchvalue!.isNotEmpty) {
                        data = snapshot.data!
                            .where((property) =>
                        property.propertyType!
                            .toLowerCase()
                            .contains(searchvalue!.toLowerCase()) ||
                            property.propertysubType!
                                .toLowerCase()
                                .contains(searchvalue!.toLowerCase()))
                            .toList();
                      } else {
                        data = snapshot.data!
                            .where((property) =>
                        property.propertyType == selectedValue)
                            .toList();
                      }*/
                      //sortData(data);
                      final totalPages = (data.length / itemsPerPage).ceil();
                      final currentPageData = data.skip(currentPage * itemsPerPage).take(itemsPerPage).toList();
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            _buildHeaders(),
                            SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(border: Border.all(color: Color.fromRGBO(152, 162, 179, .5))),
                              // decoration: BoxDecoration(
                              //     border: Border.all(color: blueColor)),
                              child: Column(
                                children: currentPageData.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  bool isExpanded = expandedIndex == index;
                                  ScheduledCharges Propertytype = entry.value;

                                  //return CustomExpansionTile(data: Propertytype, index: index);
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: index % 2 != 0 ? Colors.white : blueColor.withOpacity(0.09),
                                      border: Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
                                    ),
                                    // decoration: BoxDecoration(
                                    //   border: Border.all(color: blueColor),
                                    // ),
                                    child: Column(
                                      children: <Widget>[
                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                InkWell(
                                                  onTap: () {
                                                    // setState(() {
                                                    //    isExpanded = !isExpanded;
                                                    // //  expandedIndex = !expandedIndex;
                                                    //
                                                    // });
                                                    // setState(() {
                                                    //   if (isExpanded) {
                                                    //     expandedIndex = null;
                                                    //     isExpanded = !isExpanded;
                                                    //   } else {
                                                    //     expandedIndex = index;
                                                    //   }
                                                    // });
                                                    setState(() {
                                                      if (expandedIndex == index) {
                                                        expandedIndex = null;
                                                      } else {
                                                        expandedIndex = index;
                                                      }
                                                    });
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(left: 5, right: 5),
                                                    padding: !isExpanded ? EdgeInsets.only(bottom: 10) : EdgeInsets.only(top: 10),
                                                    child: FaIcon(
                                                      isExpanded ? FontAwesomeIcons.sortUp : FontAwesomeIcons.sortDown,
                                                      size: 20,
                                                      color: blueColor,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if (expandedIndex == index) {
                                                          expandedIndex = null;
                                                        } else {
                                                          expandedIndex = index;
                                                        }
                                                      });
                                                    },
                                                    child: Text(
                                                      '${Propertytype.actionDate}',
                                                      style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: MediaQuery.of(context).size.width * .03),
                                                Expanded(
                                                  flex: 4,
                                                  child: Text(
                                                    '${Propertytype.account}',
                                                    style: TextStyle(
                                                      color: blueColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: MediaQuery.of(context).size.width * .03),
                                                Expanded(
                                                  flex: 3,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 10.0),
                                                    child: Text(
                                                      // '${widget.data.createdAt}',
                                                      '${Propertytype.amount != null ? '\$${Propertytype.amount}' : 'N/A'}',
                                                      style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: MediaQuery.of(context).size.width * .02),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (isExpanded)
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 2.0),
                                            margin: EdgeInsets.only(bottom: 2),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // if (Propertytype
                                                  //     .isRenewing !=
                                                  //     false)

                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 18.0),
                                                    child: Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          if(widget.leaseID == null)
                                                          TextSpan(
                                                            text: 'Memo : ',
                                                            style: TextStyle(fontWeight: FontWeight.bold, color: blueColor), // Bold and black
                                                          ),
                                                          if(widget.leaseID != null)
                                                            TextSpan(
                                                              text: 'Description : ',
                                                              style: TextStyle(fontWeight: FontWeight.bold, color: blueColor), // Bold and black
                                                            ),
                                                          TextSpan(
                                                            // text: formatDate(
                                                            //     '${Propertytype.updatedAt}'),
                                                            text: Propertytype.description ??"-",
                                                            style: TextStyle(fontWeight: FontWeight.w700, color: grey), // Light and grey
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  if(widget.leaseID == null)
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 18.0),
                                                    child: Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: 'Property : ',
                                                            style: TextStyle(fontWeight: FontWeight.bold, color: blueColor), // Bold and black
                                                          ),
                                                          TextSpan(
                                                            // text: formatDate(
                                                            //     '${Propertytype.updatedAt}'),
                                                            text: Propertytype.rentalAddress ??"-",
                                                            style: TextStyle(fontWeight: FontWeight.w700, color: grey), // Light and grey
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if(widget.leaseID != null)
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 18.0),
                                                      child: Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: 'Charge Type : ',
                                                              style: TextStyle(fontWeight: FontWeight.bold, color: blueColor), // Bold and black
                                                            ),
                                                            TextSpan(
                                                              // text: formatDate(
                                                              //     '${Propertytype.updatedAt}'),
                                                              text: Propertytype.chargeType ??"-",
                                                              style: TextStyle(fontWeight: FontWeight.w700, color: grey), // Light and grey
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      if(widget.leaseID == null)
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            setState(() {
                                                              dateController.text = Propertytype.actionDate!;
                                                              amountController.text = Propertytype.amount!.toString();
                                                              memoController.text = Propertytype.description ??"";
                                                              selectedAccount = Propertytype.account!;
                                                              if(!accountOptions.any((account) => account["account"] == selectedAccount)){
                                                                accountOptions.add({
                                                                  "account":selectedAccount,
                                                                  "value":selectedAccount,
                                                                });
                                                              }
                                                              charge_id = Propertytype.taskId;
                                                            });


                                                            EditCharge();
                                                            // Navigator.push(
                                                            //     context,
                                                            //     MaterialPageRoute(
                                                            //         builder: (context) => SummeryPageLease(
                                                            //           leaseId: Propertytype.leaseId!,
                                                            //           enddate: Propertytype.date,
                                                            //           isredirectpayment: true,
                                                            //         )));
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            decoration: BoxDecoration(color: Colors.grey[350]), // color:Colors.grey[100],
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                FaIcon(
                                                                  FontAwesomeIcons.edit,
                                                                  size: 15,
                                                                  color: blueColor,
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  "Edit",
                                                                  style: TextStyle(color: blueColor, fontWeight: FontWeight.bold),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      if(widget.leaseID == null)
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            _showAlert(context, Propertytype.taskId!, Propertytype);
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            decoration: BoxDecoration(color: Colors.grey[350]), // color:Colors.grey[100],
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                FaIcon(
                                                                  FontAwesomeIcons.trashCan,
                                                                  size: 15,
                                                                  color: blueColor,
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  "Delete",
                                                                  style: TextStyle(color: blueColor, fontWeight: FontWeight.bold),
                                                                ),
                                                              ],
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
                                        //SizedBox(height: 13,),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    // Text('Rows per page:'),
                                    SizedBox(width: 10),
                                    Material(
                                      elevation: 3,
                                      child: Container(
                                        height: 40,
                                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            value: itemsPerPage,
                                            items: itemsPerPageOptions.map((int value) {
                                              return DropdownMenuItem<int>(
                                                value: value,
                                                child: Text(value.toString()),
                                              );
                                            }).toList(),
                                            onChanged: data.length > itemsPerPageOptions.first // Condition to check if dropdown should be enabled
                                                ? (newValue) {
                                              setState(() {
                                                itemsPerPage = newValue!;
                                                currentPage = 0; // Reset to first page when items per page change
                                              });
                                            }
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: FaIcon(
                                        FontAwesomeIcons.circleChevronLeft,
                                        color: currentPage == 0 ? Colors.grey : blueColor,
                                      ),
                                      onPressed: currentPage == 0
                                          ? null
                                          : () {
                                        setState(() {
                                          currentPage--;
                                        });
                                      },
                                    ),
                                    // IconButton(
                                    //   icon: Icon(Icons.arrow_back),
                                    //   onPressed: currentPage > 0
                                    //       ? () {
                                    //     setState(() {
                                    //       currentPage--;
                                    //     });
                                    //   }
                                    //       : null,
                                    // ),
                                    Text('Page ${currentPage + 1} of $totalPages'),
                                    // IconButton(
                                    //   icon: Icon(Icons.arrow_forward),
                                    //   onPressed: currentPage < totalPages - 1
                                    //       ? () {
                                    //     setState(() {
                                    //       currentPage++;
                                    //     });
                                    //   }
                                    //       : null,
                                    // ),
                                    IconButton(
                                      icon: FaIcon(
                                        FontAwesomeIcons.circleChevronRight,
                                        color: currentPage < totalPages - 1 ? blueColor : Colors.grey,
                                      ),
                                      onPressed: currentPage < totalPages - 1
                                          ? () {
                                        setState(() {
                                          currentPage++;
                                        });
                                      }
                                          : null,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            /* if (MediaQuery.of(context).size.width > 500)
              FutureBuilder<List<propertytype>>(
                future: futurePropertyTypes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ShimmerTabletTable();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Container(
                      height: MediaQuery.of(context).size.height * .5,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/no_data.jpg",
                              height: 200,
                              width: 200,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "No Data Available",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: blueColor,
                                  fontSize: 16),
                            )
                          ],
                        ),
                      ),
                    );
                  } else {
                    _tableData = snapshot.data!;
                    if (selectedValue == null && searchvalue.isEmpty) {
                      _tableData = snapshot.data!;
                    } else if (selectedValue == "All") {
                      _tableData = snapshot.data!;
                    } else if (searchvalue.isNotEmpty) {
                      _tableData = snapshot.data!
                          .where((property) =>
                      property.propertyType!
                          .toLowerCase()
                          .contains(searchvalue.toLowerCase()) ||
                          property.propertysubType!
                              .toLowerCase()
                              .contains(searchvalue.toLowerCase()))
                          .toList();
                    } else {
                      _tableData = snapshot.data!
                          .where((property) =>
                      property.propertyType == selectedValue)
                          .toList();
                    }
                    totalrecords = _tableData.length;
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 5),
                              child: Column(
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          .91,
                                      child: Table(
                                        defaultColumnWidth:
                                        IntrinsicColumnWidth(),
                                        children: [
                                          TableRow(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                // color: blueColor
                                              ),
                                            ),
                                            children: [

                                              _buildHeader(
                                                  'Main Type',
                                                  0,
                                                      (property) =>
                                                  property.propertyType!),
                                              _buildHeader(
                                                  'Subtype',
                                                  1,
                                                      (property) => property
                                                      .propertysubType!),
                                              _buildHeader(
                                                  'Created At', 2, null),
                                              _buildHeader(
                                                  'Updated At', 3, null),
                                              _buildHeader('Actions', 4, null),
                                            ],
                                          ),
                                          TableRow(
                                            decoration: BoxDecoration(
                                              border: Border.symmetric(
                                                  horizontal: BorderSide.none),
                                            ),
                                            children: List.generate(
                                                5,
                                                    (index) => TableCell(
                                                    child:
                                                    Container(height: 20))),
                                          ),
                                          for (var i = 0;
                                          i < _pagedData.length;
                                          i++)
                                            TableRow(
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  left: BorderSide(
                                                      color: blueColor


),
                                                  right: BorderSide(
                                                      color: blueColor


),
                                                  top: BorderSide(
                                                      color: blueColor


),
                                                  bottom: i ==
                                                      _pagedData.length - 1
                                                      ? BorderSide(
                                                      color: blueColor


)
                                                      : BorderSide.none,
                                                ),
                                              ),
                                              children: [

                                                // Text(
                                                //     '${_pagedData[i].propertyType!}'),
                                                // Text(
                                                //     '${_pagedData[i].propertysubType!}'),
                                                // Text(
                                                //     '${formatDate(_pagedData[i].createdAt!)}'),
                                                // Text(
                                                //     '${formatDate(_pagedData[i].updatedAt!)}'),
                                                _buildDataCell(_pagedData[i]
                                                    .propertyType!),

                                                _buildDataCell(_pagedData[i]
                                                    .propertysubType!),

                                                _buildDataCell(
                                                  formatDate(
                                                      _pagedData[i].createdAt!),
                                                ),

                                                _buildDataCell(
                                                  formatDate(
                                                      _pagedData[i].updatedAt!),
                                                ),
                                                _buildActionsCell(
                                                    _pagedData[i]),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 25),
                                  _buildPaginationControls(),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 25),
                        ],
                      ),
                    );
                  }
                },
              ),*/
          ],
        ),
      )
          : SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/no_internet.json',
              width: 200,
              height: 200,
              fit: BoxFit.fill,
            ),
            Text(
              'No Internet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Check your internet connection',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
