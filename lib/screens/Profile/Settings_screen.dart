import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
//import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/WorkOrderSetting.dart';
import 'package:three_zero_two_property/provider/color_theme.dart';
import 'package:three_zero_two_property/repository/SettingWorkorder.dart';

import 'package:three_zero_two_property/repository/setting.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:http/http.dart' as http;

import '../../constant/constant.dart';
import '../../model/setting.dart';
import '../../provider/dateProvider.dart';
import '../../widgets/CustomTableShimmer.dart';
import '../../widgets/drawer_tiles.dart';
import '../../widgets/custom_drawer.dart';
import '../Leasing/RentalRoll/newAddLease.dart';
import '../Rental/Tenants/add_tenants.dart';
import 'manage_template.dart';

class TabBarExample extends StatefulWidget {
  @override
  State<TabBarExample> createState() => _TabBarExampleState();
}

class _TabBarExampleState extends State<TabBarExample> {
  int  _selectedRadio = 0;
  TextEditingController credit = TextEditingController();
  TextEditingController debit = TextEditingController();
  TextEditingController percent = TextEditingController();
  TextEditingController flat = TextEditingController();
  TextEditingController late_fee = TextEditingController();
  TextEditingController duration = TextEditingController();
  TextEditingController durationmail = TextEditingController();
  TextEditingController replyToEmail = TextEditingController();

  bool rentDueReminderEmail = false;

  String surge_id = "";
  String latefee_id = "";
  bool isupdate = false;
  bool islatefeeupdate = false;
  bool mailupdate = false;
  bool issurge = true;
  bool ismail = false;
  bool isaccounts = false;
  bool islatefee = false;
  bool isLoading = false;
  bool isloading = false;
  bool isdateformate = false;
  bool isworkorder = false;
  bool ismanagetemplate = false;
  ConnectivityResult? _connectivityResult;
  List<Setting4> accounts = [];
  String? selectedAccount;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        print(result);
        _connectivityResult = result;
      });
    });

    checkInternet();
    fetchAccounts();
    futureaccount = accountRepository().fetchAccounts();
    fetchSurchargeData();
    fetchlatefeeData();
    fetchMailData();
    accountname = TextEditingController();
    note = TextEditingController();
    // _loadColorPreference();

    _loadVendor();
    _loadStaff();
    fetchWorkData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dateProvider = Provider.of<DateProvider>(context, listen: false);
      dateProvider.loadDateFormat();

    });
   // _customDateController.text = customdate!;
   //  customdate = customdate ?? "2025-01-23"; // Example default date
   //  _customDateController.text = customdate!;
  }



  fetchAccounts() async {
    List<Setting4> fetchedAccounts = await accountRepository().fetchAccounts();
    setState(() {
      accounts = fetchedAccounts; // Store fetched accounts in the state
    });
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  @override
  void dispose() {
    accountname.dispose();
    note.dispose();
    super.dispose();
  }

  void _refreshAccounts() {
    setState(() {
      futureaccount = accountRepository().fetchAccounts();
    });
  }

  final SurchargeRepository surchargeRepository =
      SurchargeRepository(baseUrl: '${Api_url}');
  final latefeeRepository latefeerepository =
      latefeeRepository(baseUrl: '${Api_url}');
  final mailserviceRepository mailrepository =
      mailserviceRepository(baseUrl: '${Api_url}');

  Future<void> fetchSurchargeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    try {
      Setting1 surcharges = await surchargeRepository.fetchSurchargeData('${id ?? ""}');

      if (surcharges != null) {
        setState(() {
          isupdate = true;
          credit.text = surcharges.surchargePercent.toString();
          debit.text = surcharges.surchargePercentDebit.toString();
          percent.text = surcharges.surchargePercentACH != 0.0
              ? surcharges.surchargePercentACH.toString()
              : "";
          flat.text = surcharges.surchargeFlatACH != 0.0
              ? surcharges.surchargeFlatACH.toString()
              : "";
          surge_id = surcharges.surchargeId.toString();
          selectedAccount = surcharges!.surcharge_account ?? null;
          _selectedRadio = surcharges.surchargePercentACH != 0.0 && surcharges.surchargeFlatACH != 0.0 ? 3 : surcharges.surchargePercentACH != 0.0 ?  1:surcharges.surchargeFlatACH != 0.0?2:0;
        });
      }
    } catch (e) {
      print('Failed to load surcharge dataaa: $e');
    }
  }

  Future<void> fetchlatefeeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    try {
      Setting2 latefee = await latefeerepository.fetchLatefeesData('$id');
      if (latefee != null) {
        setState(() {
          islatefeeupdate = true;
          late_fee.text = latefee.late_fee;
          duration.text = latefee.duration;
          latefee_id = latefee.latefeeId;
        });
      }
    } catch (e) {
      print('Failed to load surcharge data: $e');
    }
  }

  Future<void> updateSurcharge() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    try {
      Map<String, dynamic> data = {
        "admin_id": id,
        "surcharge_percent":
            credit.text.trim().isNotEmpty ? double.parse(credit.text.trim()) : null,
        "surcharge_percent_debit":
            debit.text.trim().isNotEmpty ? double.parse(debit.text.trim()) : null,
        "surcharge_percent_ACH": percent.text.trim().isNotEmpty
            ? double.parse(percent.text.trim())
            : null, // Add your logic to get this value
        "surcharge_flat_ACH": flat.text.trim().isNotEmpty
            ? double.parse(flat.text.trim())
            : null,
        "surcharge_account":selectedAccount// Add your logic to get this value
      };

      bool success =
          await surchargeRepository.updateSurchargeData('$surge_id', data);

      if (success) {
        Fluttertoast.showToast(msg: "Surcharge Updated Successfully");
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('Surcharge Updated Successfully')));
      } else {
        Fluttertoast.showToast(msg: "Failed to Update Surcharge");
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('Failed to Update Surcharge')));
      }
    } catch (e) {
      print('Failed to update surcharge data: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> AddSurgedata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    print("calling");

    try {
      Map<String, dynamic> data = {
        "admin_id": id,
        "surcharge_percent":
            credit.text.trim().isNotEmpty ? int.parse(credit.text.trim()) : null,
        "surcharge_percent_debit":
            debit.text.trim().isNotEmpty ? int.parse(debit.text.trim()) : null,
        "surcharge_percent_ACH": percent.text.trim().isNotEmpty
            ? int.parse(percent.text.trim())
            : null, // Add your logic to get this value
        "surcharge_flat_ACH": flat.text.trim().isNotEmpty
            ? int.parse(flat.text.trim())
            : null,
        "surcharge_account":selectedAccount
        // Add your logic to get this value
      };

      bool success =
          await surchargeRepository.AddSurgeData('1714649182536', data);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Surcharge Updated Successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to Update Surcharge')));
      }
    } catch (e) {
      print('Failed to update surcharge data: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> updateLatefee() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    try {
      Map<String, dynamic> data = {
        "admin_id": id,
        "duration":
            duration.text.trim().isNotEmpty ? double.parse(duration.text.trim()) : null,
        "late_fee":
            late_fee.text.trim().isNotEmpty ? double.parse(late_fee.text.trim()) : null,
      };

      bool success =
          await latefeerepository.updateLatefeesData('$latefee_id', data);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Latefee Updated Successfully')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to Update Latefee')));
      }
    } catch (e) {
      print('Failed to update surcharge data: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Future<void> updatemailreminder() async {
  //   print("calling");
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString('token');
  //   String?  id = prefs.getString('adminId');
  //   try {
  //     Map<String, dynamic> data = {
  //       "admin_id": id,
  //       "remindermail":rentDueReminderEmail,
  //       "duration":
  //       rentDueReminderEmail ? double.parse(email_duration.text) : 0,
  //     };
  //
  //     bool success =
  //     await latefeerepository.updateLatefeesData('$latefee_id', data);
  //
  //     if (success) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Latefee Updated Successfully')));
  //     } else {
  //       ScaffoldMessenger.of(context)
  //           .showSnackBar(SnackBar(content: Text('Failed to Update Latefee')));
  //     }
  //   } catch (e) {
  //     print('Failed to update surcharge data: $e');
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text('Error: $e')));
  //   }
  // }
  Future<void> AddLatefeedata() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    try {
      Map<String, dynamic> data = {
        "admin_id": id,
        "duration": duration.text.trim().isNotEmpty ? int.parse(duration.text.trim()) : null,
        "late_fee": late_fee.text.trim().isNotEmpty ? int.parse(late_fee.text.trim()) : null,
      };

      bool success =
          await latefeerepository.AddLatefeesData('1714649182536', data);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('late_fee Updated Successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to Update Surcharge')));
      }
    } catch (e) {
      print('Failed to update surcharge data: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  //mail Services
  Future<void> fetchMailData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    try {
      Setting3 latefee = await mailrepository.fetchMailData('$id');
      print(latefee != null);
      if (latefee != null) {
        print("setting3 calling");
        setState(() {
          id = latefee.adminId;
          mailupdate = true;
          print(latefee.duration);
          durationmail.text = latefee.duration.toString();
          //  rentDueReminderEmail = true;
          if (latefee.remindermail != null) {
            rentDueReminderEmail = latefee.remindermail!;
          }
          print(rentDueReminderEmail);
        });
      }
    } catch (e) {
      print('Failed to load surcharge data: $e');
    }
  }

  Future<void> updateMail() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    try {
      Map<String, dynamic> data = {
        "admin_id": id,
        "duration": durationmail.text.trim().isNotEmpty
            ? double.parse(durationmail.text.trim())
            : null,
        "replyToEmail":replyToEmail.text.trim(),
      };

      bool success = await mailrepository.updateMailData(data);

      if (success) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('mail Updated Successfully')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to Update mail')));
      }
    } catch (e) {
      print('Failed to update mail data: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> Addmail() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    try {
      Map<String, dynamic> data = {
        "admin_id": id,
        "replyToEmail":replyToEmail.text.trim(),
        "duration":
            durationmail.text.trim().isNotEmpty ? int.parse(durationmail.text.trim()) : null,
      };

      bool success = await mailrepository.AddMailData(id, data);

      if (success) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('mail Updated Successfully')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to Update ,ail')));
      }
    } catch (e) {
      print('Failed to update mail data: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  //account table

  late Future<List<Setting4>> futureaccount;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;

  String? selectedRole;
  String searchValue = "";
  int currentPage = 0;
  int itemsPerPage = 10;
  List<int> itemsPerPageOptions = [
    10,
    25,
    50,
    100,
  ];

  late bool isExpanded;
  bool sorting1 = false;
  bool sorting2 = false;
  bool sorting3 = false;
  bool ascending1 = false;
  bool ascending2 = false;
  bool ascending3 = false;

  void sortData(List<Setting4> data) {
    // if (sorting1) {
    //   data.sort((a, b) => ascending1
    //       ? a.staffmemberName!.compareTo(b.staffmemberName!)
    //       : b.staffmemberName!.compareTo(a.staffmemberName!));
    // } else if (sorting2) {
    //   data.sort((a, b) => ascending2
    //       ? a.staffmemberDesignation!.compareTo(b.staffmemberDesignation!)
    //       : b.staffmemberDesignation!.compareTo(a.staffmemberDesignation!));
    // } else if (sorting3) {
    //   data.sort((a, b) => ascending3
    //       ? a.createdAt!.compareTo(b.createdAt!)
    //       : b.createdAt!.compareTo(a.createdAt!));
    // }
  }

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
                    width < 400
                        ? Text("Account", style: TextStyle(color: Colors.white))
                        : Text("Account",
                            style: TextStyle(color: Colors.white)),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 3),
                  ],
                ),
              ),
            ),
            Expanded(
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
                    Text("    Type",
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  ],
                ),
              ),
            ),
            Expanded(
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
                    // SizedBox(width: 3),
                    Text("Fund Type", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int dateformateselect = 0;
  int? expandedIndex;
  Set<int> expandedIndices = {};
  String? dateformate1;
  String? dateformate2;
  String? dateformate3;
  String? customdate;
  int totalrecords = 0;
  List<Setting4> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<Setting4> get _pagedData {
    int startIndex = _currentPage * _rowsPerPage;
    int endIndex = startIndex + _rowsPerPage;
    return _tableData.sublist(startIndex,
        endIndex > _tableData.length ? _tableData.length : endIndex);
  }

  void _changeRowsPerPage(int selectedRowsPerPage) {
    setState(() {
      _rowsPerPage = selectedRowsPerPage;
      _currentPage = 0; // Reset to the first page when changing rows per page
    });
  }

  void _sort<T>(Comparable<T> Function(Setting4 d) getField, int columnIndex,
      bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _tableData.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        int result;
        if (aValue is String && bValue is String) {
          result = aValue
              .toString()
              .toLowerCase()
              .compareTo(bValue.toString().toLowerCase());
        } else {
          result = aValue.compareTo(bValue as T);
        }
        return _sortAscending ? result : -result;
      });
    });
  }

  void _showDeleteAlert(BuildContext context, String id) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this account!",
      style: AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.grey,
        ),
        DialogButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            await accountRepository().DeleteAccount(account_id: id);
            setState(() {
              futureaccount = accountRepository().fetchAccounts();
            });
            Navigator.pop(context);
          },
          color: blueColor,
        ),
      ],
    ).show();
  }

  void handleDelete(Setting4 staff) {
    _showDeleteAlert(context, staff.accountId!);

    // Handle delete action
    print('Delete ${staff.accountId}');
  }

  //for teblet

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(Setting4 d)? getField) {
    return TableCell(
      child: InkWell(
        onTap: getField != null
            ? () {
                _sort(getField, columnIndex, !_sortAscending);
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              Text(text,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              if (_sortColumnIndex == columnIndex)
                Icon(_sortAscending
                    ? Icons.arrow_drop_down_outlined
                    : Icons.arrow_drop_up_outlined),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 16),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildActionsCell(Setting4 data) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          height: 50,
          // color: Colors.blue,
          child: Row(
            children: [
              const SizedBox(
                width: 20,
              ),
              InkWell(
                onTap: () {
                  handleDelete(data);
                },
                child: const FaIcon(
                  FontAwesomeIcons.trashCan,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    int numorpages = 1;
    numorpages = (totalrecords / _rowsPerPage).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Text('Rows per page: '),
        // SizedBox(width: 10),
        Material(
          elevation: 2,
          color: Colors.white,
          child: Container(
            height: 55,
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _rowsPerPage,
                items: [10, 25, 50, 100].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    _changeRowsPerPage(newValue);
                  }
                },
                icon: Icon(
                  Icons.arrow_drop_down,
                  size: 40,
                ),
                style: TextStyle(color: Colors.black, fontSize: 17),
                dropdownColor: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.circleChevronLeft,
            size: 30,
            color: _currentPage == 0 ? Colors.grey : blueColor,
          ),
          onPressed: _currentPage == 0
              ? null
              : () {
                  setState(() {
                    _currentPage--;
                  });
                },
        ),
        Text(
          'Page ${_currentPage + 1} of $numorpages',
          style: TextStyle(fontSize: 18),
        ),
        IconButton(
          icon: FaIcon(
            size: 30,
            FontAwesomeIcons.circleChevronRight,
            color: (_currentPage + 1) * _rowsPerPage >= _tableData.length
                ? Colors.grey
                : Color.fromRGBO(
                    21, 43, 83, 1), // Change color based on availability
          ),
          onPressed: (_currentPage + 1) * _rowsPerPage >= _tableData.length
              ? null
              : () {
                  setState(() {
                    _currentPage++;
                  });
                },
        ),
      ],
    );
  }

  Color _selectedColor = Colors.blue;
  Color _selectedLabelColor = Colors.grey; // Default label color

  // void _showColorPicker() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Select a color', style: TextStyle(fontWeight: FontWeight.bold)),
  //         content: SingleChildScrollView(
  //           child: ColorPicker(
  //          paletteType: PaletteType.hueWheel,
  //             pickerColor: _selectedColor,
  //             enableAlpha: false,
  //             showLabel: false,
  //             onColorChanged: (Color color) {
  //               setState(() {
  //                 _selectedColor = color;
  //                 _selectedColors = color;
  //               });
  //             },
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             child: Text('OK'),
  //             onPressed: () {
  //               final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  //               themeProvider.updateColor(_selectedColor);
  //               _saveColorPreference(_selectedColor);
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  // Future<void> _saveColorPreference(Color color, Color labelColor) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setInt('selectedColor', color.value);
  //   await prefs.setInt('labelColor', labelColor.value);
  //   setState(() {
  //     _selectedColor = color;
  //     _selectedLabelColor = labelColor;
  //   });
  // }
  //
  // Future<void> _loadColorPreference() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final colorValue = prefs.getInt('selectedColor');
  //   final colorLabelValue = prefs.getInt('labelColor');
  //   if (colorValue != null) {
  //     setState(() {
  //       _selectedColor = Color(colorValue);
  //     });
  //   }
  //   if (colorLabelValue != null) {
  //     setState(() {
  //       _selectedLabelColor = Color(colorLabelValue);
  //     });
  //   }
  // }
  //
  // void _showColorPicker(Color currentColor, Function(Color) onColorSelected, String title, String preferenceKey) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
  //         content: SingleChildScrollView(
  //           child: ColorPicker(
  //             paletteType: PaletteType.hueWheel,
  //             pickerColor: currentColor,
  //             enableAlpha: false,
  //             showLabel: false,
  //             onColorChanged: (Color color) {
  //               onColorSelected(color);
  //             },
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             child: Text('OK'),
  //             onPressed: () {
  //               if (preferenceKey == 'selectedColor') {
  //                 _saveColorPreference(currentColor, _selectedLabelColor);
  //               } else if (preferenceKey == 'labelColor') {
  //                 _saveColorPreference(_selectedColor, currentColor);
  //               }
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void _showColorPicker(Color currentColor, Function(Color) onColorSelected, String title) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
  //         content: SingleChildScrollView(
  //           child: ColorPicker(
  //             paletteType: PaletteType.hueWheel,
  //             pickerColor: currentColor,
  //             enableAlpha: false,
  //             showLabel: false,
  //             onColorChanged: (Color color) {
  //               onColorSelected(color);
  //             },
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             child: Text('OK'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }


  String? _selectedCategory;
  final List<String> _category = [
    'Complaint',
    'Contribution Request',
    'Feedback/Suggestion',
    'General Inquiry',
    'Maintenance Request',
    'Other'
  ];
  String? _selectedEntry;
  final List<String> _entry = [
    'Yes',
    'No',
  ];
  String? _selectedStatus = "New";
  final List<String> _status = ['New', 'In Progress', 'On Hold', 'Completed','Closed'];
  final List<String> _account = [
    'Advertizing',
    'Association fees',
  ];
  List<Map<String, dynamic>> rows = [];
  bool _showTextField = false;
  String renderId = '';
  String unitId = '';
  String vendorId = '';
  String StaffId = '';
  String tenantId = '';
  bool _isLoading = false;
  bool _isLoadingvendors = false;
  bool _isLoadingstaff = false;

  //for vendor
  Map<String, String> vendors = {};
  String? _selectedvendorsId;
  String? _selectedVendors;

  //for Staffmember
  Map<String, String> staffs = {};
  String? _selectedstaffId;
  String? _selectedStaffs;
  //for tenants
  Map<String, String> tenants = {};
  String? _selectedtenantId;
  String? _selectedTenants;

  Map<String, String> properties = {}; // Mapping of rental_id to rental_address
  Map<String, String> units = {};
  bool _isLoadingtenant = false;

  final TextEditingController other = TextEditingController();
  Future<void> _loadUnits(String rentalId) async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    try {
      final response = await http
          .get(Uri.parse('$Api_url/api/unit/rental_unit/$rentalId'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      });
      print('$Api_url/api/unit/rental_unit/$rentalId');

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> unitAddresses = {};
        jsonResponse.forEach((data) {
          unitAddresses[data['unit_id'].toString()] =
              data['rental_unit'].toString();
        });
        //  200 no hoy tyare _loadtennant
        setState(() {
          units = unitAddresses;
          _isLoading = false;
        });
      } else {
        _loadTenant(rentalId, unitId);
        throw Exception('Failed to load units');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTenant(String rentalId, String unitId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    setState(() {
      _isLoadingtenant = true;
    });
    try {
      final response = await http.get(
          Uri.parse('${Api_url}/api/leases/get_tenants/$rentalId/$unitId'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
          });
      print('${Api_url}/api/leases/get_tenants/$rentalId/$unitId');
      print(response.body);
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> tenantsnames = {};
        jsonResponse.forEach((data) {
          tenantsnames[data['tenant_id'].toString()] =
              data['tenant_firstName'].toString() +
                  " " +
                  data['tenant_lastName'].toString();
        });
        setState(() {
          tenants = tenantsnames;
          _isLoadingtenant = false;
        });
        print(tenants);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoadingtenant = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch tenants: $e')),
      );
    }
  }

  //for vendor
  Future<void> _loadVendor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    setState(() {
      _isLoadingvendors = true;
    });
    try {
      final response = await http
          .get(Uri.parse('${Api_url}/api/vendor/vendors/$id'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      });
      print('${Api_url}/api/vendor/vendors/$id');

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> names = {};
        jsonResponse.forEach((data) {
          names[data['vendor_id'].toString()] = data['vendor_name'].toString();
        });

        setState(() {
          vendors = names;
          _isLoadingvendors = false;
        });
      } else {
       // throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoadingvendors = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch vendors: $e')),
      );
    }
  }

  Future<void> _loadStaff() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    setState(() {
      _isLoadingstaff = true;
    });
    try {
      final response = await http.get(
          Uri.parse('${Api_url}/api/staffmember/staff_member/$id'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
          });
      print('${Api_url}/api/staffmember/staff_member/$id');

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> staffnames = {};
        jsonResponse.forEach((data) {
          staffnames[data['staffmember_id'].toString()] =
              data['staffmember_name'].toString();
        });

        setState(() {
          staffs = staffnames;
          _isLoadingstaff = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoadingstaff = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch vendors: $e')),
      );
    }
  }

  //for update the workorder
  Future<void> updateWorkOrderSettings() async {
    setState(() {
      isloading = true; // Show loading indicator
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final url = '${Api_url}/api/work-order/work-defaults';
    final headers = {
      "authorization": "CRM $token",
      "id":"CRM $id",
      'Content-Type': 'application/json; charset=UTF-8',

    };
    final body = json.encode({
      "admin_id": id,
      "category": _selectedCategory,
     "entry_allowed": _selectedEntry == 'yes',
      "staffmember_id":_selectedstaffId,
      "vendor_id":vendorId,
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      var responseData = json.decode(response.body);
      print('add workorder ${responseData}');
      print('add workorder  ${response.body}');
      if (responseData["statusCode"] == 200) {
        Fluttertoast.showToast(msg: responseData["message"]);
        return json.decode(response.body);

      } else {
        Fluttertoast.showToast(msg: responseData["message"]);
        throw Exception('Failed to add workorder');
      }
    } catch (error) {
      // Handle network error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    } finally {
      setState(() {
        isloading = false; // Hide loading indicator
      });
    }
  }

  Future<void> fetchWorkData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    try {
      Data workorder = await fetchWorkOrderSetting();
      String? entryAllowedString;
      if (workorder.workDefaults?.entryAllowed != null) {
        entryAllowedString = workorder.workDefaults!.entryAllowed! ? 'Yes' : 'No';
      }
      if (workorder != null) {
        setState(() {
          _selectedvendorsId = workorder.workDefaults?.vendorId?.isEmpty ?? true ? null : workorder.workDefaults?.vendorId;
          _selectedCategory  = workorder.workDefaults?.category ?? "";
          _selectedstaffId = workorder.workDefaults?.staffmemberId?.isEmpty ?? true ? null : workorder.workDefaults?.staffmemberId;
          _selectedEntry = entryAllowedString;
         print('vendor check ${workorder.workDefaults?.vendorId ?? ""}');

        });
      }
    } catch (e) {
      print('Failed to load workorder data: $e');
    }
  }


  //for date formate
  Future<void> updateDateFormat(String format, String adminId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final url = Uri.parse('${Api_url}/api/themes/date-format');
    final response = await http.post(
      url,
      headers: {
        "authorization": "CRM $token",
        "id":"CRM $id",
        'Content-Type': 'application/json; charset=UTF-8',

      },
      body: json.encode({
        'format': format,
        'admin_id': adminId,
      }),
    );
    var responseData = json.decode(response.body);
    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return json.decode(response.body);

    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to Date format');
    }

  }
  TextEditingController _customDateController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
   //dateProvider.loadDateFormat();
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: widget_302.App_Bar(context: context, isSettingPageActive: true),
        backgroundColor: Colors.white,
        drawer: CustomDrawer(
          currentpage: "Dashboard",
          dropdown: false,
        ),
        body: _connectivityResult != ConnectivityResult.none
            ? ListView(children: [
                SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: Container(
                      height: MediaQuery.of(context).size.width < 500 ? 45 : 55,
                      padding: EdgeInsets.only(top: 10, left: 10),
                      width: MediaQuery.of(context).size.width * .91,
                      margin: const EdgeInsets.only(bottom: 6.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: blueColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 1.0),
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: Text(
                        "Setting ",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width < 500
                                ? 16
                                : 25),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18, right: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      //border: Border.all(color: blueColor),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height:
                              MediaQuery.of(context).size.width < 500 ? 40 : 50,
                          width: MediaQuery.of(context).size.width < 500
                              ? 850
                              : 900,
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      issurge = true;
                                      ismail = false;
                                      isaccounts = false;
                                      islatefee = false;
                                      isdateformate = false;
                                      isworkorder = false;
                                      ismanagetemplate = false;
                                    });
                                  },
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.width < 500
                                            ? 40
                                            : 50,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: blueColor),
                                      color:
                                          !issurge ? Colors.white : blueColor,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Surcharge",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: issurge
                                                ? Colors.white
                                                : blueColor,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      issurge = false;
                                      ismail = false;
                                      isaccounts = false;
                                      isdateformate = false;
                                      islatefee = true;
                                      isworkorder = false;
                                      ismanagetemplate = false;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: blueColor),
                                      color:
                                          !islatefee ? Colors.white : blueColor,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Late Fee Charge",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: islatefee
                                                ? Colors.white
                                                : blueColor,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height:
                              MediaQuery.of(context).size.width < 500 ? 40 : 50,
                          width: MediaQuery.of(context).size.width < 500
                              ? 850
                              : 900,
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      issurge = false;
                                      isaccounts = false;
                                      ismail = true;
                                      islatefee = false;
                                      isdateformate = false;
                                      isworkorder = false;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: blueColor),
                                      color: !ismail ? Colors.white : blueColor,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Mail Service",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ismail
                                                ? Colors.white
                                                : blueColor,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      issurge = false;
                                      ismail = false;
                                      isaccounts = true;
                                      islatefee = false;
                                      isdateformate = false;
                                      isworkorder = false;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: blueColor),
                                      color: !isaccounts
                                          ? Colors.white
                                          : blueColor,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Accounts",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isaccounts
                                                ? Colors.white
                                                : blueColor,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          height:
                              MediaQuery.of(context).size.width < 500 ? 40 : 50,
                          width: MediaQuery.of(context).size.width < 500
                              ? 850
                              : 900,
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    final dateProvider =
                                        Provider.of<DateProvider>(context,
                                            listen: false);
                                    setState(() {
                                      issurge = false;
                                      isaccounts = false;
                                      ismail = false;
                                      isdateformate = true;
                                      islatefee = false;
                                      isworkorder = false;
                                      ismanagetemplate = false;
                                      DateTime now = DateTime.now();
                                      dateformateselect =
                                          dateProvider.dateformateselect;
                                      dateformate1 =
                                          DateFormat('MM-dd-yyyy').format(now);
                                      dateformate2 =
                                          DateFormat('yyyy-MM-dd').format(now);
                                      dateformate3 =
                                          DateFormat('yyyy-MMM-dd').format(now);
                                      //dateformate1 = DateFormat('mm/dd/yyyy').parse(DateTime.now().toString()).toString();
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: blueColor),
                                      color: !isdateformate
                                          ? Colors.white
                                          : blueColor,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Date Format",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isdateformate
                                                ? Colors.white
                                                : blueColor,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      issurge = false;
                                      ismail = false;
                                      isaccounts = false;
                                      isworkorder = true;
                                      islatefee = false;
                                      isdateformate = false;
                                      ismanagetemplate = false;
                                    });
                                  },
                                  child: Visibility(
                                    visible: true,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: blueColor),
                                        color: !isworkorder
                                            ? Colors.white
                                            : blueColor,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Work Order",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isworkorder
                                                  ? Colors.white
                                                  : blueColor,
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      500
                                                  ? 15
                                                  : 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          height:
                          MediaQuery.of(context).size.width < 500 ? 40 : 50,
                          width: MediaQuery.of(context).size.width < 500
                              ? 850
                              : 900,
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {

                                    setState(() {
                                      issurge = false;
                                      isaccounts = false;
                                      ismail = false;
                                      isdateformate = false;
                                      islatefee = false;
                                      isworkorder = false;
                                      ismanagetemplate = true;
                                      //dateformate1 = DateFormat('mm/dd/yyyy').parse(DateTime.now().toString()).toString();
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: blueColor),
                                      color: !ismanagetemplate
                                          ? Colors.white
                                          : blueColor,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Manage Template",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ismanagetemplate
                                                ? Colors.white
                                                : blueColor,
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width <
                                                500
                                                ? 15
                                                : 20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              // Expanded(
                              //   child: InkWell(
                              //     onTap: () {
                              //       setState(() {
                              //         issurge = false;
                              //         ismail = false;
                              //         isaccounts = false;
                              //         isworkorder = true;
                              //         islatefee = false;
                              //         isdateformate = false;
                              //       });
                              //     },
                              //     child: Visibility(
                              //       visible: true,
                              //       child: Container(
                              //         decoration: BoxDecoration(
                              //           border: Border.all(color: blueColor),
                              //           color: !isworkorder
                              //               ? Colors.white
                              //               : blueColor,
                              //         ),
                              //         child: Center(
                              //           child: Text(
                              //             "WorkOrder",
                              //             style: TextStyle(
                              //                 fontWeight: FontWeight.bold,
                              //                 color: isworkorder
                              //                     ? Colors.white
                              //                     : blueColor,
                              //                 fontSize: MediaQuery.of(context)
                              //                     .size
                              //                     .width <
                              //                     500
                              //                     ? 15
                              //                     : 20),
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),

                              Spacer()
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Divider(
                          color: grey,
                        ),
                        if (issurge)
                          Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Surcharge",
                                    style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 18
                                              : 25,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "You can set default surcharge percentage from here",
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 15
                                              : 20,
                                          color: Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              // if (MediaQuery.of(context).size.width < 500)
                              //   Row(
                              //     children: [
                              //       SizedBox(
                              //         width: 5,
                              //       ),
                              //       Text(
                              //         "Credit Card Surcharge Percent",
                              //         style: TextStyle(
                              //             fontSize:
                              //                 MediaQuery.of(context).size.width <
                              //                         500
                              //                     ? 15
                              //                     : 20,
                              //             color: blueColor,
                              //             fontWeight: FontWeight.bold),
                              //       ),
                              //     ],
                              //   ),
                              // if (MediaQuery.of(context).size.width < 500)
                              //   SizedBox(
                              //     height: 10,
                              //   ),
                              // if (MediaQuery.of(context).size.width < 500)
                              //   Row(
                              //     children: [
                              //       SizedBox(width: 5),
                              //       Expanded(
                              //         child: Material(
                              //           elevation: 4,
                              //           borderRadius: BorderRadius.circular(10),
                              //           child: Container(
                              //             height: 50,
                              //             width:
                              //                 MediaQuery.of(context).size.width *
                              //                     .6,
                              //             decoration: BoxDecoration(
                              //               color: Colors.white,
                              //               borderRadius:
                              //                   BorderRadius.circular(10),
                              //             ),
                              //             child: Stack(
                              //               children: [
                              //                 Positioned.fill(
                              //                   child: TextField(
                              //                     onChanged: (value) {
                              //                       setState(() {
                              //                         //  passworderror = false;
                              //                       });
                              //                     },
                              //                     controller: credit,
                              //                     cursorColor: Color.fromRGBO(
                              //                         21, 43, 81, 1),
                              //                     decoration: InputDecoration(
                              //                       // hintText: "Enter password",
                              //                       hintStyle: TextStyle(
                              //                         fontSize:
                              //                             MediaQuery.of(context)
                              //                                     .size
                              //                                     .width *
                              //                                 .037,
                              //                         color: Color(0xFF8A95A8),
                              //                       ),
                              //                       // enabledBorder: passworderror
                              //                       //     ? OutlineInputBorder(
                              //                       //   borderRadius:
                              //                       //   BorderRadius.circular(2),
                              //                       //   borderSide: BorderSide(
                              //                       //     color: Colors.red,
                              //                       //   ),
                              //                       // )
                              //                       //     : InputBorder.none,
                              //                       border: InputBorder.none,
                              //                       contentPadding:
                              //                           EdgeInsets.all(13),
                              //                       suffixIcon: Icon(
                              //                         Icons.percent,
                              //                         color: Color.fromRGBO(
                              //                             21, 43, 81, 1),
                              //                         size: 18,
                              //                       ),
                              //                     ),
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //       SizedBox(width: 100),
                              //     ],
                              //   ),
                              // if (MediaQuery.of(context).size.width < 500)
                              //   SizedBox(
                              //     height: 20,
                              //   ),
                              // if (MediaQuery.of(context).size.width < 500)
                              //   Row(
                              //     children: [
                              //       SizedBox(width: 5),
                              //       Text(
                              //         "Debit Card Surcharge Percent",
                              //         style: TextStyle(
                              //             fontSize:
                              //                 MediaQuery.of(context).size.width <
                              //                         500
                              //                     ? 15
                              //                     : 20,
                              //             color: blueColor,
                              //             fontWeight: FontWeight.bold),
                              //       ),
                              //     ],
                              //   ),
                              // if (MediaQuery.of(context).size.width < 500)
                              //   SizedBox(
                              //     height: 10,
                              //   ),
                              // if (MediaQuery.of(context).size.width < 500)
                              //   Row(
                              //     children: [
                              //       SizedBox(width: 5),
                              //       Expanded(
                              //         child: Material(
                              //           elevation: 4,
                              //           borderRadius: BorderRadius.circular(10),
                              //           child: Container(
                              //             height: 50,
                              //             width:
                              //                 MediaQuery.of(context).size.width *
                              //                     .6,
                              //             decoration: BoxDecoration(
                              //               color: Colors.white,
                              //               borderRadius:
                              //                   BorderRadius.circular(10),
                              //             ),
                              //             child: Stack(
                              //               children: [
                              //                 Positioned.fill(
                              //                   child: TextField(
                              //                     onChanged: (value) {
                              //                       setState(() {
                              //                         //  passworderror = false;
                              //                       });
                              //                     },
                              //                     controller: debit,
                              //                     cursorColor: Color.fromRGBO(
                              //                         21, 43, 81, 1),
                              //                     decoration: InputDecoration(
                              //                       // hintText: "Enter password",
                              //                       hintStyle: TextStyle(
                              //                         fontSize:
                              //                             MediaQuery.of(context)
                              //                                     .size
                              //                                     .width *
                              //                                 .037,
                              //                         color: Color(0xFF8A95A8),
                              //                       ),
                              //                       // enabledBorder: passworderror
                              //                       //     ? OutlineInputBorder(
                              //                       //   borderRadius:
                              //                       //   BorderRadius.circular(2),
                              //                       //   borderSide: BorderSide(
                              //                       //     color: Colors.red,
                              //                       //   ),
                              //                       // )
                              //                       //     : InputBorder.none,
                              //                       border: InputBorder.none,
                              //                       contentPadding:
                              //                           EdgeInsets.all(13),
                              //                       suffixIcon: Icon(
                              //                         Icons.percent,
                              //                         color: Color.fromRGBO(
                              //                             21, 43, 81, 1),
                              //                         size: 18,
                              //                       ),
                              //                     ),
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //       SizedBox(width: 100),
                              //     ],
                              //   ),
                              if (MediaQuery.of(context).size.width < 500)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // First Column
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Credit Card Surcharge Percent",
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 15
                                                          : 20,
                                                  color: blueColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 8),
                                            Container(
                                              height: 50,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .5,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: grey),
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Stack(
                                                children: [
                                                  Positioned.fill(
                                                    child: TextField(
                                                      onChanged: (value) {
                                                        setState(() {
                                                          //  passworderror = false;
                                                        });
                                                      },
                                                      controller: credit,
                                                      cursorColor: blueColor,
                                                      decoration:
                                                          InputDecoration(
                                                        // hintText: "Enter password",
                                                        hintStyle: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .037,
                                                          color:
                                                              Color(0xFF8A95A8),
                                                        ),
                                                        // enabledBorder: passworderror
                                                        //     ? OutlineInputBorder(
                                                        //   borderRadius:
                                                        //   BorderRadius.circular(2),
                                                        //   borderSide: BorderSide(
                                                        //     color: Colors.red,
                                                        //   ),
                                                        // )
                                                        //     : InputBorder.none,
                                                        border:
                                                            InputBorder.none,
                                                        contentPadding:
                                                            EdgeInsets.all(13),
                                                        suffixIcon: Icon(
                                                          Icons.percent,
                                                          color: blueColor,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      // Second Column
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Debit Card Surcharge Percent",
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 15
                                                          : 20,
                                                  color: blueColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 8),
                                            Container(
                                              height: 50,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .5,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: grey),
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Stack(
                                                children: [
                                                  Positioned.fill(
                                                    child: TextField(
                                                      onChanged: (value) {
                                                        setState(() {
                                                          //  passworderror = false;
                                                        });
                                                      },
                                                      controller: debit,
                                                      cursorColor: blueColor,
                                                      decoration:
                                                          InputDecoration(
                                                        // hintText: "Enter password",
                                                        hintStyle: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .037,
                                                          color:
                                                              Color(0xFF8A95A8),
                                                        ),
                                                        // enabledBorder: passworderror
                                                        //     ? OutlineInputBorder(
                                                        //   borderRadius:
                                                        //   BorderRadius.circular(2),
                                                        //   borderSide: BorderSide(
                                                        //     color: Colors.red,
                                                        //   ),
                                                        // )
                                                        //     : InputBorder.none,
                                                        border:
                                                            InputBorder.none,
                                                        contentPadding:
                                                            EdgeInsets.all(13),
                                                        suffixIcon: Icon(
                                                          Icons.percent,
                                                          color: blueColor,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(
                                height: 10,
                              ),
                              if (MediaQuery.of(context).size.width > 500)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // First Column
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Credit Card Surcharge Percent",
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 15
                                                          : 20,
                                                  color: blueColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 8),
                                            Material(
                                              elevation: 4,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Container(
                                                height: 50,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .6,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Positioned.fill(
                                                      child: TextField(
                                                        onChanged: (value) {
                                                          setState(() {
                                                            //  passworderror = false;
                                                          });
                                                        },
                                                        controller: credit,
                                                        cursorColor: blueColor,
                                                        decoration:
                                                            InputDecoration(
                                                          // hintText: "Enter password",
                                                          hintStyle: TextStyle(
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .037,
                                                            color: Color(
                                                                0xFF8A95A8),
                                                          ),
                                                          // enabledBorder: passworderror
                                                          //     ? OutlineInputBorder(
                                                          //   borderRadius:
                                                          //   BorderRadius.circular(2),
                                                          //   borderSide: BorderSide(
                                                          //     color: Colors.red,
                                                          //   ),
                                                          // )
                                                          //     : InputBorder.none,
                                                          border:
                                                              InputBorder.none,
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  13),
                                                          suffixIcon: Icon(
                                                            Icons.percent,
                                                            color: blueColor,
                                                            size: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Debit Card Surcharge Percent",
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 15
                                                          : 20,
                                                  color: blueColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 8),
                                            Material(
                                              elevation: 4,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Container(
                                                height: 50,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .6,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Positioned.fill(
                                                      child: TextField(
                                                        onChanged: (value) {
                                                          setState(() {
                                                            //  passworderror = false;
                                                          });
                                                        },
                                                        controller: debit,
                                                        cursorColor: blueColor,
                                                        decoration:
                                                            InputDecoration(
                                                          // hintText: "Enter password",
                                                          hintStyle: TextStyle(
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .037,
                                                            color: Color(
                                                                0xFF8A95A8),
                                                          ),
                                                          // enabledBorder: passworderror
                                                          //     ? OutlineInputBorder(
                                                          //   borderRadius:
                                                          //   BorderRadius.circular(2),
                                                          //   borderSide: BorderSide(
                                                          //     color: Colors.red,
                                                          //   ),
                                                          // )
                                                          //     : InputBorder.none,
                                                          border:
                                                              InputBorder.none,
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  13),
                                                          suffixIcon: Icon(
                                                            Icons.percent,
                                                            color: blueColor,
                                                            size: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "You can set default ACH percentage or ACH flat fee or both from here",
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 15
                                              : 20,
                                          color: Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              RadioListTile<int>(
                                activeColor: Colors.black,
                                title: Text(
                                  'Add ACH surcharge percentage',
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 15
                                              : 20,
                                      color: blueColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                value: 1,
                                groupValue: _selectedRadio,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRadio = value!;
                                  });
                                },
                              ),
                              RadioListTile<int>(
                                activeColor: Colors.black,
                                title: Text(
                                  'Add ACH flat fee',
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 15
                                              : 20,
                                      color: blueColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                value: 2,
                                groupValue: _selectedRadio,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRadio = value!;
                                  });
                                },
                              ),
                              RadioListTile<int>(
                                activeColor: Colors.black,
                                title: Text(
                                  'Add both ACH surcharge percentage and flat fee',
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 15
                                              : 20,
                                      color: blueColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                value: 3,
                                groupValue: _selectedRadio,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRadio = value!;
                                  });
                                },
                              ),
                              if (_selectedRadio == 1 ||
                                  _selectedRadio == 3) ...[
                                SizedBox(height: 20),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'Add ACH Surcharge Percentage',
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 15
                                              : 20,
                                          color: blueColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                // TextField(
                                //   decoration: InputDecoration(
                                //     border: OutlineInputBorder(),
                                //     labelText: 'ACH Surcharge Percentage',
                                //   ),
                                // ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    SizedBox(width: 5),
                                    Expanded(
                                      child: Container(
                                        height: 50,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .5,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: grey),
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: TextField(
                                                onChanged: (value) {
                                                  setState(() {
                                                    //  passworderror = false;
                                                  });
                                                },
                                                controller: percent,
                                                cursorColor: blueColor,
                                                decoration: InputDecoration(
                                                  // hintText: "Enter password",
                                                  hintStyle: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .037,
                                                    color: Color(0xFF8A95A8),
                                                  ),
                                                  // enabledBorder: passworderror
                                                  //     ? OutlineInputBorder(
                                                  //   borderRadius:
                                                  //   BorderRadius.circular(2),
                                                  //   borderSide: BorderSide(
                                                  //     color: Colors.red,
                                                  //   ),
                                                  // )
                                                  //     : InputBorder.none,
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.all(13),
                                                  suffixIcon: Icon(
                                                    Icons.percent,
                                                    color: Color.fromRGBO(
                                                        21, 43, 81, 1),
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (MediaQuery.of(context).size.width < 500)
                                      SizedBox(width: 190),
                                    if (MediaQuery.of(context).size.width > 500)
                                      SizedBox(width: 380),
                                  ],
                                ),
                              ],
                              if (_selectedRadio == 2 ||
                                  _selectedRadio == 3) ...[
                                SizedBox(height: 20),
                                Row(
                                  children: [
                                    SizedBox(width: 5),
                                    Text(
                                      'Add ACH Flat Fee',
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 15
                                              : 20,
                                          color: blueColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                // TextField(
                                //   decoration: InputDecoration(
                                //     border: OutlineInputBorder(),
                                //     labelText: 'ACH Flat Fee',
                                //   ),
                                // ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    SizedBox(width: 5),
                                    Expanded(
                                      child: Container(
                                        height: 50,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .5,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: grey),
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: TextField(
                                                onChanged: (value) {
                                                  setState(() {
                                                    //  passworderror = false;
                                                  });
                                                },
                                                controller: flat,
                                                cursorColor: blueColor,
                                                decoration: InputDecoration(
                                                  // hintText: "Enter password",
                                                  hintStyle: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .037,
                                                    color: Color(0xFF8A95A8),
                                                  ),
                                                  // enabledBorder: passworderror
                                                  //     ? OutlineInputBorder(
                                                  //   borderRadius:
                                                  //   BorderRadius.circular(2),
                                                  //   borderSide: BorderSide(
                                                  //     color: Colors.red,
                                                  //   ),
                                                  // )
                                                  //     : InputBorder.none,
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.all(13),
                                                  suffixIcon: Icon(
                                                    Icons.percent,
                                                    color: Color.fromRGBO(
                                                        21, 43, 81, 1),
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (MediaQuery.of(context).size.width < 500)
                                      SizedBox(width: 190),
                                    if (MediaQuery.of(context).size.width > 500)
                                      SizedBox(width: 380),
                                  ],
                                ),

                              ],

                              Container(
                                width: double.infinity,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 15,),
                                    Text("Account to receive surcharges",style: TextStyle(
                                        fontSize: MediaQuery.of(context)
                                            .size
                                            .width <
                                            500
                                            ? 15
                                            : 20,
                                        color: Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold),),
                                    Container(
                                      height: 42,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String?>(
                                          value: selectedAccount,
                                          padding: EdgeInsets.symmetric(horizontal: 5),
                                          hint: Text(
                                            "Select Account",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          items: accounts.map((Setting4 account) {
                                            return DropdownMenuItem<String>(
                                              value: account.account,
                                              child: Text(account.account!), // Display account name
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedAccount = newValue;
                                            });
                                            // Handle the selected account
                                           // print(newValue?.); // Print selected account name
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 30),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 2,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      if (isupdate)
                                        await updateSurcharge();
                                      else
                                        await AddSurgedata();
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 35
                                                : 50,
                                        width:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 100
                                                : 150,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          color: blueColor,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey,
                                              offset: Offset(0.0, 1.0), //(x,y)
                                              blurRadius: 6.0,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Update",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      500
                                                  ? 15
                                                  : 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      debit.clear();
                                      credit.clear();
                                      flat.clear();
                                      percent.clear();
                                      setState(() {
                                        selectedAccount = null;
                                      });
                                    },
                                    child: Container(
                                        height:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 35
                                                : 50,
                                        width:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 100
                                                : 100,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: blueColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Center(
                                            child: Text(
                                          "Reset",
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      500
                                                  ? 15
                                                  : 20,
                                              fontWeight: FontWeight.bold),
                                        ))),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        if (ismail)
                          Column(
                            children: [
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Mail Service",
                                    style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 18
                                              : 25,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [

                                  Text(
                                    "Add Your Reply to Address",
                                    style: TextStyle(
                                        fontSize:
                                        MediaQuery.of(context)
                                            .size
                                            .width <
                                            500
                                            ? 15
                                            : 20,
                                        color: blueColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [

                                  Expanded(
                                    child: Container(
                                      height: 50,
                                      width:
                                      MediaQuery.of(context).size.width *
                                          .5,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: grey),
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(5),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: TextFormField(
                                              controller: replyToEmail,
                                              onChanged: (value) {
                                                setState(() {
                                                  //  passworderror = false;
                                                });
                                              },
                                              //  controller: password,
                                              cursorColor: Color.fromRGBO(
                                                  21, 43, 81, 1),
                                              decoration: InputDecoration(
                                                 hintText: "Enter email",
                                                hintStyle: TextStyle(
                                                  fontSize:
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                      .037,
                                                  color: Color(0xFF8A95A8),
                                                ),

                                                border: InputBorder.none,
                                                contentPadding:
                                                EdgeInsets.all(13),

                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 190),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              _buildRentDueReminderSwitch(),
                              /*  SizedBox(
                          height: 10,
                        ),*/
                              if (rentDueReminderEmail)
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "You can set a duration for send reminder email before rent due date to tenant",
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        500
                                                    ? 15
                                                    : 20,
                                                color: Color(0xFF8A95A8),
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Duration",
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      500
                                                  ? 15
                                                  : 20,
                                              color: blueColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(width: 5),
                                        Expanded(
                                          child: Container(
                                            height: 50,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .5,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: grey),
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Stack(
                                              children: [
                                                Positioned.fill(
                                                  child: TextFormField(
                                                    controller: durationmail,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        //  passworderror = false;
                                                      });
                                                    },
                                                    //  controller: password,
                                                    cursorColor: Color.fromRGBO(
                                                        21, 43, 81, 1),
                                                    decoration: InputDecoration(
                                                      // hintText: "Enter password",
                                                      hintStyle: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .037,
                                                        color:
                                                            Color(0xFF8A95A8),
                                                      ),

                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.all(13),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 190),
                                      ],
                                    ),
                                  ],
                                ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  if (MediaQuery.of(context).size.width < 500)
                                    SizedBox(width: 2),
                                  if (MediaQuery.of(context).size.width > 500)
                                    SizedBox(width: 2),
                                  GestureDetector(
                                    onTap: () async {
                                      if (mailupdate)
                                        await updateMail();
                                      else
                                        await Addmail();
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 35
                                                : 50,
                                        width:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 100
                                                : 150,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          color: blueColor,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey,
                                              offset: Offset(0.0, 1.0), //(x,y)
                                              blurRadius: 6.0,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Save",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        500
                                                    ? 16
                                                    : 20),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      durationmail.clear();
                                    },
                                    child: Container(
                                        height:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 35
                                                : 50,
                                        width:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 100
                                                : 120,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: blueColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Center(
                                            child: Text(
                                          "Reset",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      500
                                                  ? 16
                                                  : 20),
                                        ))),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        if (islatefee)
                          Column(
                            children: [
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Late Fee Charge",
                                    style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 18
                                              : 25,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "You can set default Late fee charge from here",
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 15
                                              : 20,
                                          color: Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              if (MediaQuery.of(context).size.width < 500)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // First Column
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Percentage",
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 15
                                                          : 20,
                                                  color: blueColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 5),
                                            Container(
                                              height: 50,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .5,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: grey),
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Stack(
                                                children: [
                                                  Positioned.fill(
                                                    child: TextFormField(
                                                      controller: late_fee,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          //  passworderror = false;
                                                        });
                                                      },
                                                      //  controller: password,
                                                      cursorColor: blueColor,
                                                      decoration:
                                                          InputDecoration(
                                                        // hintText: "Enter password",
                                                        hintStyle: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .037,
                                                          color:
                                                              Color(0xFF8A95A8),
                                                        ),
                                                        // enabledBorder: passworderror
                                                        //     ? OutlineInputBorder(
                                                        //   borderRadius:
                                                        //   BorderRadius.circular(2),
                                                        //   borderSide: BorderSide(
                                                        //     color: Colors.red,
                                                        //   ),
                                                        // )
                                                        //     : InputBorder.none,
                                                        border:
                                                            InputBorder.none,
                                                        contentPadding:
                                                            EdgeInsets.all(13),
                                                        suffixIcon: Icon(
                                                          Icons.percent,
                                                          color: blueColor,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      // Second Column
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Duration",
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 15
                                                          : 20,
                                                  color: blueColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 5),
                                            Container(
                                              height: 50,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .5,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: grey),
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Stack(
                                                children: [
                                                  Positioned.fill(
                                                    child: TextFormField(
                                                      controller: duration,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          //  passworderror = false;
                                                        });
                                                      },
                                                      //  controller: password,
                                                      cursorColor: blueColor,
                                                      decoration:
                                                          InputDecoration(
                                                        // hintText: "Enter password",
                                                        hintStyle: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .037,
                                                          color:
                                                              Color(0xFF8A95A8),
                                                        ),
                                                        // enabledBorder: passworderror
                                                        //     ? OutlineInputBorder(
                                                        //   borderRadius:
                                                        //   BorderRadius.circular(2),
                                                        //   borderSide: BorderSide(
                                                        //     color: Colors.red,
                                                        //   ),
                                                        // )
                                                        //     : InputBorder.none,
                                                        border:
                                                            InputBorder.none,
                                                        contentPadding:
                                                            EdgeInsets.all(13),
                                                        suffixIcon: Icon(
                                                          Icons.percent,
                                                          color: blueColor,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              // if (MediaQuery.of(context).size.width < 500)
                              //   SizedBox(
                              //     height: 10,
                              //   ),
                              // if (MediaQuery.of(context).size.width < 500)
                              //   Row(
                              //     children: [
                              //       SizedBox(
                              //         width: 10,
                              //       ),
                              //       Text(
                              //         "Percentage",
                              //         style: TextStyle(
                              //             fontSize:
                              //                 MediaQuery.of(context).size.width *
                              //                     .035,
                              //             color: blueColor,
                              //             fontWeight: FontWeight.bold),
                              //       ),
                              //     ],
                              //   ),
                              // if (MediaQuery.of(context).size.width < 500)
                              //   SizedBox(
                              //     height: 10,
                              //   ),
                              // if (MediaQuery.of(context).size.width < 500)
                              //   Row(
                              //     children: [
                              //       SizedBox(width: 5),
                              //       Expanded(
                              //         child: Material(
                              //           elevation: 4,
                              //           borderRadius: BorderRadius.circular(10),
                              //           child: Container(
                              //             height: 50,
                              //             width:
                              //                 MediaQuery.of(context).size.width *
                              //                     .6,
                              //             decoration: BoxDecoration(
                              //               color: Colors.white,
                              //               borderRadius:
                              //                   BorderRadius.circular(10),
                              //             ),
                              //             child: Stack(
                              //               children: [
                              //                 Positioned.fill(
                              //                   child: TextFormField(
                              //                     controller: late_fee,
                              //                     onChanged: (value) {
                              //                       setState(() {
                              //                         //  passworderror = false;
                              //                       });
                              //                     },
                              //                     //  controller: password,
                              //                     cursorColor: Color.fromRGBO(
                              //                         21, 43, 81, 1),
                              //                     decoration: InputDecoration(
                              //                       // hintText: "Enter password",
                              //                       hintStyle: TextStyle(
                              //                         fontSize:
                              //                             MediaQuery.of(context)
                              //                                     .size
                              //                                     .width *
                              //                                 .037,
                              //                         color: Color(0xFF8A95A8),
                              //                       ),
                              //                       // enabledBorder: passworderror
                              //                       //     ? OutlineInputBorder(
                              //                       //   borderRadius:
                              //                       //   BorderRadius.circular(2),
                              //                       //   borderSide: BorderSide(
                              //                       //     color: Colors.red,
                              //                       //   ),
                              //                       // )
                              //                       //     : InputBorder.none,
                              //                       border: InputBorder.none,
                              //                       contentPadding:
                              //                           EdgeInsets.all(13),
                              //                       suffixIcon: Icon(
                              //                         Icons.percent,
                              //                         color: Color.fromRGBO(
                              //                             21, 43, 81, 1),
                              //                         size: 18,
                              //                       ),
                              //                     ),
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //       SizedBox(width: 90),
                              //     ],
                              //   ),
                              // if (MediaQuery.of(context).size.width < 500)
                              //   SizedBox(
                              //     height: 20,
                              //   ),
                              // if (MediaQuery.of(context).size.width < 500)
                              //   Row(
                              //     children: [
                              //       SizedBox(
                              //         width: 10,
                              //       ),
                              //       Text(
                              //         "Duration",
                              //         style: TextStyle(
                              //             fontSize:
                              //                 MediaQuery.of(context).size.width *
                              //                     .035,
                              //             color: blueColor,
                              //             fontWeight: FontWeight.bold),
                              //       ),
                              //     ],
                              //   ),
                              // if (MediaQuery.of(context).size.width < 500)
                              //   SizedBox(
                              //     height: 10,
                              //   ),
                              // if (MediaQuery.of(context).size.width < 500)
                              //   Row(
                              //     children: [
                              //       SizedBox(width: 5),
                              //       Expanded(
                              //         child: Material(
                              //           elevation: 4,
                              //           borderRadius: BorderRadius.circular(10),
                              //           child: Container(
                              //             height: 50,
                              //             width:
                              //                 MediaQuery.of(context).size.width *
                              //                     .6,
                              //             decoration: BoxDecoration(
                              //               color: Colors.white,
                              //               borderRadius:
                              //                   BorderRadius.circular(10),
                              //             ),
                              //             child: Stack(
                              //               children: [
                              //                 Positioned.fill(
                              //                   child: TextFormField(
                              //                     controller: duration,
                              //                     onChanged: (value) {
                              //                       setState(() {
                              //                         //  passworderror = false;
                              //                       });
                              //                     },
                              //                     //  controller: password,
                              //                     cursorColor: Color.fromRGBO(
                              //                         21, 43, 81, 1),
                              //                     decoration: InputDecoration(
                              //                       // hintText: "Enter password",
                              //                       hintStyle: TextStyle(
                              //                         fontSize:
                              //                             MediaQuery.of(context)
                              //                                     .size
                              //                                     .width *
                              //                                 .037,
                              //                         color: Color(0xFF8A95A8),
                              //                       ),
                              //                       // enabledBorder: passworderror
                              //                       //     ? OutlineInputBorder(
                              //                       //   borderRadius:
                              //                       //   BorderRadius.circular(2),
                              //                       //   borderSide: BorderSide(
                              //                       //     color: Colors.red,
                              //                       //   ),
                              //                       // )
                              //                       //     : InputBorder.none,
                              //                       border: InputBorder.none,
                              //                       contentPadding:
                              //                           EdgeInsets.all(13),
                              //                       suffixIcon: Icon(
                              //                         Icons.percent,
                              //                         color: Color.fromRGBO(
                              //                             21, 43, 81, 1),
                              //                         size: 18,
                              //                       ),
                              //                     ),
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //       SizedBox(width: 90),
                              //     ],
                              //   ),
                              SizedBox(
                                height: 10,
                              ),
                              if (MediaQuery.of(context).size.width > 500)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // First Column
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Percentage",
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 15
                                                          : 20,
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 5),
                                            Material(
                                              elevation: 4,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Container(
                                                height: 50,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .6,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Positioned.fill(
                                                      child: TextFormField(
                                                        controller: late_fee,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            //  passworderror = false;
                                                          });
                                                        },
                                                        //  controller: password,
                                                        cursorColor: blueColor,
                                                        decoration:
                                                            InputDecoration(
                                                          // hintText: "Enter password",
                                                          hintStyle: TextStyle(
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .037,
                                                            color: Color(
                                                                0xFF8A95A8),
                                                          ),
                                                          // enabledBorder: passworderror
                                                          //     ? OutlineInputBorder(
                                                          //   borderRadius:
                                                          //   BorderRadius.circular(2),
                                                          //   borderSide: BorderSide(
                                                          //     color: Colors.red,
                                                          //   ),
                                                          // )
                                                          //     : InputBorder.none,
                                                          border:
                                                              InputBorder.none,
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  13),
                                                          suffixIcon: Icon(
                                                            Icons.percent,
                                                            color: blueColor,
                                                            size: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Duration",
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 15
                                                          : 20,
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 5),
                                            Material(
                                              elevation: 4,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Container(
                                                height: 50,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .6,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Positioned.fill(
                                                      child: TextFormField(
                                                        controller: duration,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            //  passworderror = false;
                                                          });
                                                        },
                                                        //  controller: password,
                                                        cursorColor: blueColor,
                                                        decoration:
                                                            InputDecoration(
                                                          // hintText: "Enter password",
                                                          hintStyle: TextStyle(
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .037,
                                                            color: Color(
                                                                0xFF8A95A8),
                                                          ),
                                                          // enabledBorder: passworderror
                                                          //     ? OutlineInputBorder(
                                                          //   borderRadius:
                                                          //   BorderRadius.circular(2),
                                                          //   borderSide: BorderSide(
                                                          //     color: Colors.red,
                                                          //   ),
                                                          // )
                                                          //     : InputBorder.none,
                                                          border:
                                                              InputBorder.none,
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  13),
                                                          suffixIcon: Icon(
                                                            Icons.percent,
                                                            color: blueColor,
                                                            size: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(height: 30),
                              Row(
                                children: [
                                  if (MediaQuery.of(context).size.width < 500)
                                    SizedBox(width: 2),
                                  if (MediaQuery.of(context).size.width > 500)
                                    SizedBox(width: 2),
                                  GestureDetector(
                                    onTap: () async {
                                      if (islatefeeupdate)
                                        await updateLatefee();
                                      else
                                        await AddLatefeedata();
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 35
                                                : 50,
                                        width:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 100
                                                : 150,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          color: blueColor,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey,
                                              offset: Offset(0.0, 1.0), //(x,y)
                                              blurRadius: 6.0,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Save",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        500
                                                    ? 16
                                                    : 20),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      duration.clear();
                                      late_fee.clear();
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 35
                                                : 50,
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 100
                                                : 120,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: blueColor,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Center(
                                                child: Text(
                                              "Reset",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 16
                                                          : 20),
                                            ))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        if (isaccounts)
                          Column(
                            children: [
                              SizedBox(height: 15),
                              Row(
                                children: [
                                  Text(
                                    "Manage Account",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: blueColor,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 18
                                              : 25,
                                    ),
                                  ),
                                  Spacer(),
                                  GestureDetector(
                                    onTap: () async {
                                      _showAccount(context);
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .045,
                                        width:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 120
                                                : 180,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          color: blueColor,
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
                                                  "Add Account",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 15
                                                              : 18),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              if (MediaQuery.of(context).size.width > 500)
                                SizedBox(height: 25),
                              if (MediaQuery.of(context).size.width < 500)
                                if (MediaQuery.of(context).size.width < 500)
                                  FutureBuilder<List<Setting4>>(
                                    future: futureaccount,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return ColabShimmerLoadingWidget();
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Error: ${snapshot.error}'));
                                      } else if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .5,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor,
                                                      fontSize: 16),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      } else {
                                        var data = snapshot.data!;
                                        if (searchValue == null ||
                                            searchValue!.isEmpty) {
                                          data = snapshot.data!;
                                        } else if (searchValue == "All") {
                                          data = snapshot.data!;
                                        } else if (searchValue!.isNotEmpty) {
                                          data = snapshot.data!
                                              .where((staff) => staff.account!
                                                  .toLowerCase()
                                                  .contains(searchValue!
                                                      .toLowerCase()))
                                              .toList();
                                        } else {
                                          data = snapshot.data!
                                              .where((staff) =>
                                                  staff.accountType ==
                                                  searchValue)
                                              .toList();
                                        }
                                        sortData(data);
                                        final totalPages =
                                            (data.length / itemsPerPage).ceil();
                                        final currentPageData = data
                                            .skip(currentPage * itemsPerPage)
                                            .take(itemsPerPage)
                                            .toList();
                                        return SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              SizedBox(height: 10),
                                              _buildHeaders(),
                                              SizedBox(height: 20),
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Color.fromRGBO(
                                                          152, 162, 179, .5)),),
                                                // decoration: BoxDecoration(
                                                //     border: Border.all(color: blueColor)),
                                                child: Column(
                                                  children: currentPageData
                                                      .asMap()
                                                      .entries
                                                      .map((entry) {
                                                    int index = entry.key;
                                                    bool isExpanded =
                                                        expandedIndex == index;
                                                    Setting4 account =
                                                        entry.value;
                                                    //return CustomExpansionTile(data: Propertytype, index: index);
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        color: index % 2 != 0
                                                            ? Colors.white
                                                            : blueColor
                                                                .withOpacity(
                                                                    0.09),
                                                        border:Border.all(
                                                      color: Color.fromRGBO(
                                                          152, 162, 179, .5)),
                                                      ),
                                                      // decoration: BoxDecoration(
                                                      //   border: Border.all(color: blueColor),
                                                      // ),
                                                      child: Column(
                                                        children: <Widget>[
                                                          ListTile(
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                            title: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(2.0),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
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
                                                                      setState(
                                                                          () {
                                                                        if (expandedIndex ==
                                                                            index) {
                                                                          expandedIndex =
                                                                              null;
                                                                        } else {
                                                                          expandedIndex =
                                                                              index;
                                                                        }
                                                                      });
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      margin: EdgeInsets.only(
                                                                          left:
                                                                              5,
                                                                          right:
                                                                              5),
                                                                      padding: !isExpanded
                                                                          ? EdgeInsets.only(
                                                                              bottom:
                                                                                  10)
                                                                          : EdgeInsets.only(
                                                                              top: 10),
                                                                      child:
                                                                          FaIcon(
                                                                        isExpanded
                                                                            ? FontAwesomeIcons.sortUp
                                                                            : FontAwesomeIcons.sortDown,
                                                                        size:
                                                                            20,
                                                                        color:
                                                                            blueColor,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          if (expandedIndex ==
                                                                              index) {
                                                                            expandedIndex =
                                                                                null;
                                                                          } else {
                                                                            expandedIndex =
                                                                                index;
                                                                          }
                                                                        });
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        '${account.account}',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              blueColor,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontSize:
                                                                              13,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          .03),
                                                                  Expanded(
                                                                    child: Text(
                                                                      '${account.accountType}',
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            blueColor,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            13,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          .03),
                                                                  Expanded(
                                                                    child: Text(
                                                                      '${account.fundType}',
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            blueColor,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            13,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          .02),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          if (isExpanded)
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 2,
                                                                      right: 2),
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      bottom:
                                                                          2),
                                                              child:
                                                                  SingleChildScrollView(
                                                                child:
                                                                    Container(
                                                                  //color: Colors.blue,
                                                                  child: Column(
                                                                    children: [

                                                                      Row(
                                                                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                GestureDetector(
                                                                              onTap: () {
                                                                                _showDeleteAlert(context, account.accountId!);
                                                                              },
                                                                              child: Container(
                                                                                height: 40,
                                                                                decoration: BoxDecoration(color: Colors.grey[350]),
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
                                                                                    )
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
                                                            ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    children: [
                                                      // Text('Rows per page:'),
                                                      SizedBox(width: 10),
                                                      Material(
                                                        elevation: 3,
                                                        child: Container(
                                                          height: 40,
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      12.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                          child:
                                                              DropdownButtonHideUnderline(
                                                            child:
                                                                DropdownButton<
                                                                    int>(
                                                              value:
                                                                  itemsPerPage,
                                                              items:
                                                                  itemsPerPageOptions
                                                                      .map((int
                                                                          value) {
                                                                return DropdownMenuItem<
                                                                    int>(
                                                                  value: value,
                                                                  child: Text(value
                                                                      .toString()),
                                                                );
                                                              }).toList(),
                                                              onChanged: data
                                                                          .length >
                                                                      itemsPerPageOptions
                                                                          .first // Condition to check if dropdown should be enabled
                                                                  ? (newValue) {
                                                                      setState(
                                                                          () {
                                                                        itemsPerPage =
                                                                            newValue!;
                                                                        currentPage =
                                                                            0; // Reset to first page when items per page change
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
                                                          FontAwesomeIcons
                                                              .circleChevronLeft,
                                                          color:
                                                              currentPage == 0
                                                                  ? Colors.grey
                                                                  : blueColor,
                                                        ),
                                                        onPressed:
                                                            currentPage == 0
                                                                ? null
                                                                : () {
                                                                    setState(
                                                                        () {
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
                                                      Text(
                                                          'Page ${currentPage + 1} of $totalPages'),
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
                                                          FontAwesomeIcons
                                                              .circleChevronRight,
                                                          color: currentPage <
                                                                  totalPages - 1
                                                              ? blueColor
                                                              : Colors.grey,
                                                        ),
                                                        onPressed: currentPage <
                                                                totalPages - 1
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
                              if (MediaQuery.of(context).size.width > 500)
                                FutureBuilder<List<Setting4>>(
                                  future: futureaccount,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return ShimmerTabletTable();
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'));
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .5,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
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
                                      List<Setting4>? filteredData = [];
                                      if (selectedRole == null &&
                                          searchValue == "") {
                                        filteredData = snapshot.data;
                                      } else if (selectedRole == "All") {
                                        filteredData = snapshot.data;
                                      } else if (searchValue.isNotEmpty) {
                                        filteredData = snapshot.data!
                                            .where((staff) =>
                                                staff.account!
                                                    .toLowerCase()
                                                    .contains(searchValue
                                                        .toLowerCase()) ||
                                                staff.accountType!
                                                    .toLowerCase()
                                                    .contains(searchValue
                                                        .toLowerCase()))
                                            .toList();
                                      } else {
                                        filteredData = snapshot.data!
                                            .where((staff) =>
                                                staff.accountType ==
                                                selectedRole)
                                            .toList();
                                      }
                                      //_tableData = snapshot.data!;
                                      // _tableData = snapshot.data!;
                                      _tableData = filteredData!;
                                      totalrecords = _tableData.length;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5.0, vertical: 5),
                                        child: Column(
                                          children: [
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .91,
                                                child: Table(
                                                  defaultColumnWidth:
                                                      IntrinsicColumnWidth(),
                                                  children: [
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                          border: Border.all()),
                                                      children: [
                                                        _buildHeader(
                                                            'Account',
                                                            0,
                                                            (staff) =>
                                                                staff.account!),
                                                        _buildHeader(
                                                            'Type',
                                                            1,
                                                            (staff) => staff
                                                                .accountType!),
                                                        _buildHeader(
                                                            'ChargeType',
                                                            2,
                                                            null),
                                                        _buildHeader('FundType',
                                                            3, null),
                                                        _buildHeader(
                                                            'Actions', 4, null),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        border:
                                                            Border.symmetric(
                                                                horizontal:
                                                                    BorderSide
                                                                        .none),
                                                      ),
                                                      children: List.generate(
                                                          5,
                                                          (index) => TableCell(
                                                              child: Container(
                                                                  height: 20))),
                                                    ),
                                                    for (var i = 0;
                                                        i < _pagedData.length;
                                                        i++)
                                                      TableRow(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border(
                                                            left: BorderSide(
                                                                color: Color
                                                                    .fromRGBO(
                                                                        21,
                                                                        43,
                                                                        81,
                                                                        1)),
                                                            right: BorderSide(
                                                                color: Color
                                                                    .fromRGBO(
                                                                        21,
                                                                        43,
                                                                        81,
                                                                        1)),
                                                            top: BorderSide(
                                                                color: Color
                                                                    .fromRGBO(
                                                                        21,
                                                                        43,
                                                                        81,
                                                                        1)),
                                                            bottom: i ==
                                                                    _pagedData
                                                                            .length -
                                                                        1
                                                                ? BorderSide(
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1))
                                                                : BorderSide
                                                                    .none,
                                                          ),
                                                        ),
                                                        children: [
                                                          _buildDataCell(
                                                              _pagedData[i]
                                                                  .account!),
                                                          _buildDataCell(
                                                              _pagedData[i]
                                                                  .accountType!),
                                                          _buildDataCell(
                                                              _pagedData[i]
                                                                  .chargeType!),
                                                          _buildDataCell(
                                                              _pagedData[i]
                                                                  .fundType!),
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
                                      );
                                    }
                                  },
                                ),
                            ],
                          ),
                        if (isdateformate)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 15),
                              Row(
                                children: [
                                  Text(
                                    "Manage Date Format",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: blueColor,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 18
                                              : 25,
                                    ),
                                  ),
                                  Spacer(),
                                ],
                              ),
                              SizedBox(height: 15),
                              Row(
                                children: [
                                  Text(
                                    "Current Date Format :- dd-mm-yyyy",
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: blueColor,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 16
                                              : 25,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              Text(
                                "Select Date Format",
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: blueColor,
                                  fontSize:
                                      MediaQuery.of(context).size.width < 500
                                          ? 16
                                          : 25,
                                ),
                              ),
                              Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                              height: 20,
                                              width: 30,
                                              child: Radio(
                                                  value: 0,
                                                  groupValue: dateformateselect,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      dateProvider
                                                          .updateDateFormat(
                                                              'MM/dd/yyyy',
                                                              value);
                                                      dateformateselect =
                                                          value!;
                                                    });
                                                  })),
                                          Text(
                                            "MM/DD/YYYY",
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        height: 50,
                                        width: 150,
                                        child: TextFormField(
                                          enabled: false,
                                          initialValue: dateformate1 ?? "",
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 15),
                                            border: OutlineInputBorder(),
                                            filled: true,
                                            fillColor: Colors.grey.shade200,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                              height: 20,
                                              width: 30,
                                              child: Radio(
                                                  value: 1,
                                                  groupValue: dateformateselect,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      dateProvider
                                                          .updateDateFormat(
                                                              'yyyy-MM-dd',
                                                              value);
                                                      dateformateselect =
                                                          value!;
                                                    });
                                                  })),
                                          Text(
                                            "YYYY-MM-DD",
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        height: 50,
                                        width: 150,
                                        child: TextFormField(
                                          enabled: false,
                                          initialValue: dateformate2 ?? "",
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 15),
                                            border: OutlineInputBorder(),
                                            filled: true,
                                            fillColor: Colors.grey.shade200,
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                              height: 20,
                                              width: 30,
                                              child: Radio(
                                                  value: 2,
                                                  groupValue: dateformateselect,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      dateProvider
                                                          .updateDateFormat(
                                                              'yyyy-MMM-dd',
                                                              value);
                                                      dateformateselect =
                                                          value!;
                                                    });
                                                  })),
                                          Text(
                                            "YYYY-MMM-DD",
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        height: 50,
                                        width: 150,
                                        child: TextFormField(
                                          initialValue: dateformate3 ?? "",
                                          enabled: false,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 15),
                                            border: OutlineInputBorder(),
                                            filled: true,
                                            fillColor: Colors.grey.shade200,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                              height: 20,
                                              width: 30,
                                              child: Radio(
                                                  value: 3,
                                                  groupValue: dateformateselect,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      dateformateselect =
                                                          value!;
                                                      customdate = ""; // Clear the custom date format when switched to custom
                                                      _customDateController.text = "";
                                                    });
                                                  })),
                                          Text(
                                            "Custom",
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        height: 50,
                                        width: 150,
                                        child: TextFormField(
                                         // controller: _customDateController,
                                          onChanged: (value) {
                                            setState(() {
                                              customdate = value;
                                            //  print("custom date  $customdate");
                                            });
                                          },
                                          initialValue: customdate != null ? customdate : dateProvider.dateFormat.toUpperCase() ?? "",
                                          enabled: dateformateselect == 3,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 15),
                                            border: OutlineInputBorder(),
                                            filled: dateformateselect != 3,
                                            fillColor: Colors.grey.shade200,
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  customdate = customdate != null && customdate!.isNotEmpty
                                      ? customdate
                                      : dateProvider.dateFormat;

                                  print("Custom Date: $customdate");
                                  if (dateformateselect == 3 && customdate != null) {
                                    // Save the custom date format
                                    String fixedDate = fixDateFormat(customdate!);
                                    context.read<DateProvider>().updateDateFormat(fixedDate!, 3);
                                    // Optionally, show a success message
                                    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    //   content: Text("Date format saved!"),
                                    // ));
                                  }
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5.0),
                                  child: Container(
                                    height:
                                    MediaQuery.of(context).size.width <
                                        500
                                        ? 40
                                        : 50,
                                    width:
                                    MediaQuery.of(context).size.width <
                                        500
                                        ? 100
                                        : 150,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(5.0),
                                      color: blueColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey,
                                          offset: Offset(0.0, 1.0), //(x,y)
                                          blurRadius: 6.0,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Save",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width <
                                                500
                                                ? 16
                                                : 20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              // Text("Select text color",style: TextStyle(
                              //   fontWeight: FontWeight.normal,
                              //   color: blueColor,
                              //   fontSize: MediaQuery.of(context).size.width < 500
                              //       ? 16
                              //       : 25,
                              // ),),
                              // Card(
                              //   elevation: 4,
                              //   child: ListTile(
                              //     title: Text('Choose a color', style: TextStyle(fontSize: 18)),
                              //     trailing: Icon(Icons.color_lens, color: _selectedColor),
                              //     // onTap: _showColorPicker,
                              //     // onTap: () {
                              //     //   _showColorPicker(_selectedColor, (Color color) {
                              //     //     setState(() {
                              //     //       _selectedColor = color;
                              //     //     });
                              //     //     final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                              //     //     themeProvider.updateColor(_selectedColor);
                              //     //   //  _saveColorPreference(_selectedColor,_selectedColor);
                              //     //   }, 'Select a text color','_selectedColor');
                              //     // },
                              //     onTap: () {
                              //       _showColorPicker(_selectedColor, (Color color) {
                              //         setState(() {
                              //           _selectedColor = color;
                              //         });
                              //       }, 'Select a text color', 'selectedColor');
                              //     },
                              //   ),
                              // ),
                              // Text("Select label color",style: TextStyle(
                              //   fontWeight: FontWeight.normal,
                              //   color: blueColor,
                              //   fontSize: MediaQuery.of(context).size.width < 500
                              //       ? 16
                              //       : 25,
                              // ),),
                              // Card(
                              //   elevation: 4,
                              //   child: ListTile(
                              //     title: Text('Choose a color', style: TextStyle(fontSize: 18)),
                              //     trailing: Icon(Icons.color_lens, color: _selectedLabelColor),
                              //     // onTap: _showColorPicker,
                              //     onTap: () {
                              //       // _showColorPicker(_selectedLabelColor, (Color color) {
                              //       //   setState(() {
                              //       //     _selectedLabelColor = color;
                              //       //   });
                              //       //   final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                              //       //   themeProvider.updatelabelColor(_selectedLabelColor);
                              //       //    //_saveColorPreference(_selectedLabelColor,_selectedLabelColor);
                              //       // }, 'Select a label color','labelColor');
                              //       _showColorPicker(_selectedColor, (Color color) {
                              //         setState(() {
                              //           _selectedColor = color;
                              //         });
                              //       }, 'Select a label color', 'labelColor');
                              //     },
                              //   ),
                              // ),
                            ],
                          ),
                        if (isworkorder)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 15),
                              Row(
                                children: [
                                  Text(
                                    "Manage Work Order",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: blueColor,
                                      fontSize:
                                      MediaQuery.of(context).size.width <
                                          500
                                          ? 18
                                          : 25,
                                    ),
                                  ),
                                  Spacer(),
                                ],
                              ),
                              SizedBox(height: 15),
                              Row(
                                children: [
                                  Text(
                                    "Category",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: blueColor,
                                      fontSize:
                                      MediaQuery.of(context).size.width <
                                          500
                                          ? 16
                                          : 25,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              FormField<String>(
                                validator: (value) {
                                  if (_selectedCategory == null ||
                                      _selectedCategory!.isEmpty) {
                                    return 'Please select a category';
                                  }
                                  return null;
                                },
                                builder: (FormFieldState<String> state) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton2<String>(
                                          isExpanded: true,
                                          hint: const Text('Select Category'),
                                          value: _selectedCategory,
                                          items: _category.map((method) {
                                            return DropdownMenuItem<String>(
                                              value: method,
                                              child: Text(method),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _selectedCategory = newValue;
                                              _showTextField =
                                                  _selectedCategory == 'Other';
                                              state.didChange(newValue);
                                            });
                                            print(
                                                'Selected category: $_selectedCategory');
                                            state.reset();
                                            // Notify FormField of value change
                                          },
                                          buttonStyleData: ButtonStyleData(
                                            height: 45,
                                            padding: const EdgeInsets.only(
                                                left: 14, right: 14),
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
                                              MaterialStateProperty.all(true),
                                            ),
                                          ),
                                          menuItemStyleData:
                                          const MenuItemStyleData(
                                            height: 50,
                                            padding: EdgeInsets.only(
                                                left: 14, right: 14),
                                          ),
                                        ),
                                      ),
                                      if (state.hasError)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 14, top: 8),
                                          child: Text(
                                            state.errorText!,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                              _showTextField
                                  ? Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, bottom: 10),
                                child: buildTextField('Other Category',
                                    'Enter Other Category', other),
                              )
                                  : Container(),
                              SizedBox(
                                height: 10,
                              ),
                              Text('Vendor *',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: blueColor,
                                  fontSize:
                                  MediaQuery.of(context).size.width <
                                      500
                                      ? 16
                                      : 25,
                                ),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FormField<String>(
                                    validator: (value) {
                                      if (_selectedvendorsId == null ||
                                          _selectedvendorsId!.isEmpty) {
                                        return 'Please select a vendor';
                                      }
                                      return null;
                                    },
                                    builder: (FormFieldState<String> state) {
                                      return Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          DropdownButtonHideUnderline(
                                            child:
                                            DropdownButtonFormField2<String>(
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                              ),
                                              isExpanded: true,
                                              hint: const Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      'Select here',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                        FontWeight.w400,
                                                        color: Color(0xFFb0b6c3),
                                                      ),
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              items:
                                              vendors.keys.map((vender_id) {
                                                return DropdownMenuItem<String>(
                                                  value: vender_id,
                                                  child: Text(
                                                    vendors[vender_id]!,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.black87,
                                                    ),
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                  ),
                                                );
                                              }).toList(),
                                              value: _selectedvendorsId,
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedvendorsId = value;
                                                  _selectedVendors =
                                                  vendors[value];
                                                  vendorId = value.toString();
                                                  print(
                                                      'Selected Vendors: $_selectedVendors');
                                                  _loadUnits(value!);
                                                  state.didChange(
                                                      value); // Fetch units for the selected vendor
                                                });
                                                state.reset();
                                                // Notify form field of the change
                                              },
                                              buttonStyleData: ButtonStyleData(
                                                height: 45,
                                                width: 160,
                                                padding: const EdgeInsets.only(
                                                    left: 14, right: 14),
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
                                                iconEnabledColor:
                                                Color(0xFFb0b6c3),
                                                iconDisabledColor: Colors.grey,
                                              ),
                                              dropdownStyleData:
                                              DropdownStyleData(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius.circular(6),
                                                  color: Colors.white,
                                                ),
                                                scrollbarTheme:
                                                ScrollbarThemeData(
                                                  radius:
                                                  const Radius.circular(6),
                                                  thickness:
                                                  MaterialStateProperty.all(
                                                      6),
                                                  thumbVisibility:
                                                  MaterialStateProperty.all(
                                                      true),
                                                ),
                                              ),
                                              menuItemStyleData:
                                              const MenuItemStyleData(
                                                height: 40,
                                                padding: EdgeInsets.only(
                                                    left: 14, right: 14),
                                              ),
                                              // validator: (value) {
                                              //   if (value == null || value.isEmpty) {
                                              //     return 'Please select a vendor';
                                              //   }
                                              //   return null;
                                              // },
                                            ),
                                          ),
                                          if (state.hasError)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 14, top: 8),
                                              child: Text(
                                                state.errorText!,
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text('Entery Allowed ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: blueColor,
                                  fontSize:
                                  MediaQuery.of(context).size.width <
                                      500
                                      ? 16
                                      : 25,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: Text('Select'),
                                  value: _selectedEntry,
                                  items: _entry.map((method) {
                                    return DropdownMenuItem<String>(
                                      value: method,
                                      child: Text(method),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedEntry = newValue;
                                      //_selectedPaymentMethod = addRow();
                                      // if(_selectedCategory == 'Other')
                                      // addRow();
                                    });
                                    print('Selected category: $_selectedEntry');
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    height: 45,
                                    // width: 200,
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
                                    padding: EdgeInsets.only(left: 14, right: 14),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text('Assigned To *',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: blueColor,
                                  fontSize:
                                  MediaQuery.of(context).size.width <
                                      500
                                      ? 16
                                      : 25,
                                ),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FormField<String>(
                                    validator: (value) {
                                      if (_selectedstaffId == null ||
                                          _selectedstaffId!.isEmpty) {
                                        return 'Please select a staff member';
                                      }
                                      return null;
                                    },
                                    builder: (FormFieldState<String> state) {
                                      return Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          DropdownButtonHideUnderline(
                                            child:
                                            DropdownButtonFormField2<String>(
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                              ),
                                              isExpanded: true,
                                              hint: const Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      'Select here',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                        FontWeight.w400,
                                                        color: Color(0xFFb0b6c3),
                                                      ),
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              items: staffs.keys
                                                  .map((staffmember_id) {
                                                return DropdownMenuItem<String>(
                                                  value: staffmember_id,
                                                  child: Text(
                                                    staffs[staffmember_id]!,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.black87,
                                                    ),
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                  ),
                                                );
                                              }).toList(),
                                              value: _selectedstaffId,
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedstaffId = value;
                                                  _selectedStaffs = staffs[value];
                                                  StaffId = value.toString();
                                                  print(
                                                      'Selected Staffs: $_selectedStaffs');
                                                  state.didChange(value);
                                                });
                                                state.reset();
                                                // Notify form field of the change
                                              },
                                              buttonStyleData: ButtonStyleData(
                                                height: 45,
                                                width: 160,
                                                padding: const EdgeInsets.only(
                                                    left: 14, right: 14),
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
                                                iconEnabledColor:
                                                Color(0xFFb0b6c3),
                                                iconDisabledColor: Colors.grey,
                                              ),
                                              dropdownStyleData:
                                              DropdownStyleData(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius.circular(6),
                                                  color: Colors.white,
                                                ),
                                                scrollbarTheme:
                                                ScrollbarThemeData(
                                                  radius:
                                                  const Radius.circular(6),
                                                  thickness:
                                                  MaterialStateProperty.all(
                                                      6),
                                                  thumbVisibility:
                                                  MaterialStateProperty.all(
                                                      true),
                                                ),
                                              ),
                                              menuItemStyleData:
                                              const MenuItemStyleData(
                                                height: 40,
                                                padding: EdgeInsets.only(
                                                    left: 14, right: 14),
                                              ),
                                            ),
                                          ),
                                          if (state.hasError)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 14, top: 8),
                                              child: Text(
                                                state.errorText!,
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                                 Row(
                                   children: [
                                     Container(
                                       height: 50,
                                       width: 100,
                                       decoration: BoxDecoration(
                                         borderRadius: BorderRadius.circular(8.0),
                                       ),
                                       child: ElevatedButton(
                                         style: ElevatedButton.styleFrom(
                                           backgroundColor: blueColor,
                                           shape: RoundedRectangleBorder(
                                             borderRadius: BorderRadius.circular(8.0),
                                           ),
                                         ),
                                         onPressed: () async {
                                           print("hello");
                                           updateWorkOrderSettings();
                                         },
                                         child: isLoading
                                             ? Center(
                                           child: SpinKitFadingCircle(
                                             color: Colors.white,
                                             size: 55.0,
                                           ),
                                         )
                                             : Text(
                                           'Save',
                                           style: TextStyle(
                                             fontWeight: FontWeight.bold,
                                             fontSize:
                                             MediaQuery.of(context).size.width <
                                                 500
                                                 ? 16
                                                 : 25,
                                           ),
                                         ),
                                       ),
                                     ),

                                   ],
                                 ),
                            ],
                          ),
                        if(ismanagetemplate)
                          manage_templates()
                      ],
                    ),
                  ),
                ),
              ])
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Check your internet connection',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
  String fixDateFormat(String customdate) {
    return customdate.replaceAllMapped(
      RegExp(r'[DY]'),
          (match) {
        if (match.group(0) == 'D') {
          return 'd';
        } else if (match.group(0) == 'Y') {
          return 'y';
        }
        return match.group(0)!; // Return the character unchanged if it doesn't match
      },
    );
  }
  Widget _buildRentDueReminderSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Switch(
            value: rentDueReminderEmail,
            onChanged: (value) {
              setState(() {
                rentDueReminderEmail = value;
              });
            },
            activeColor: blueColor, // Color when switch is on
            inactiveThumbColor: Colors.grey, // Color when switch is off
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            'Rent Due Reminder Email',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: blueColor,
            ),
          ),
        ],
      ),
    );
  }

  final List<String> accountitems = [
    'Liability Account',
    'Recurring Charge',
    'One Time Charge',
  ];
  final List<String> accounttypeitems = [
    'Income',
    'Non Operating Income',
    'Liability Account',
  ];
  final List<String> fundtypeitems = [
    'Reserve',
    'Operating',
  ];

  String? _selectedAccount;
  String? _selectedAccounttype;
  String? _selectedFundtype;
  bool isError = false;

  TextEditingController accountname = TextEditingController();
  TextEditingController note = TextEditingController();

  // void _showAccountType(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return
  //         StatefulBuilder(builder: (context, setState) {
  //           return
  //             AlertDialog(
  //               title: Text('Account Type', style: TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 color: Color.fromRGBO(
  //                     21, 43, 81, 1),),),
  //               actions: <Widget>[
  //                 InkWell(
  //                   onTap: (){
  //                     Navigator.pop(context);
  //                   },
  //                   child: Container(
  //                     height: 40,
  //                     decoration: BoxDecoration(
  //                       color: blueColor,
  //                       borderRadius: BorderRadius.circular(3),
  //                     ),
  //                     child: Center(
  //                       child: Text('Cancel',style: TextStyle(
  //                           color: Colors.white
  //                       ),),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //               content: Container(
  //                 height: 150,
  //                 child: Column(
  //                   children: [
  //                     SizedBox(
  //                       height: 20,
  //                     ),
  //                     Row(
  //                       children: [
  //                         Text("Select Account Type",
  //                             style: TextStyle(
  //                                 fontWeight: FontWeight.bold,
  //                                 color: Color.fromRGBO(
  //                                     21, 43, 81, 1),
  //                                 fontSize: 17)
  //                         ),
  //                       ],
  //                     ),
  //                     SizedBox(
  //                       height: 20,
  //                     ),
  //                     Row(
  //                       children: [
  //                         CustomDropdown(
  //                           validator: (value) {
  //                             if (value == null || value.isEmpty) {
  //                               return 'Please select a account';
  //                             }
  //                             return null;
  //                           },
  //                           labelText: 'Select',
  //                           items: accountitems,
  //                           selectedValue: _selectedAccount,
  //                           onChanged: (String? value) {
  //                             print(_selectedAccount);
  //                             setState(() {
  //                               _selectedAccount = value;
  //                               Navigator.pop(context);
  //                               _showAccount(
  //                                   context,_selectedAccount);
  //                             });
  //                           },
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //
  //             );
  //         });
  //
  //     },
  //   );
  // }

  //popup
  void _showAccountType(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Account Type',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: blueColor,
              ),
            ),
            actions: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: blueColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Center(
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
            content: SingleChildScrollView(
              child: Container(
                height: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      "Select Account Type",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: blueColor,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomDropdown(
                      validator: (value) {
                        if (_selectedAccount == null) {
                          return 'Please select an account';
                        }
                        return null;
                      },
                      labelText: 'Select',
                      items: accountitems,
                      selectedValue: _selectedAccount,
                      onChanged: (String? value) {
                        print(_selectedAccount);
                        setState(() {
                          _selectedAccount = value;
                          Navigator.pop(context);
                          _showAccount(context);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  // void _showAccount(BuildContext context , String? selectedAccountType) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return
  //         StatefulBuilder(builder: (context, setState) {
  //           return
  //             AlertDialog(
  //               title: Text('Add Account', style: TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 color: Color.fromRGBO(
  //                     21, 43, 81, 1),),),
  //
  //               content: SingleChildScrollView(
  //                 child: Column(
  //                   children: [
  //                     SizedBox(
  //                       height: 20,
  //                     ),
  //                     Row(
  //                       children: [
  //                         Text("Account Name",
  //                             style: TextStyle(
  //                                 fontWeight: FontWeight.bold,
  //                                 color: Color.fromRGBO(
  //                                     21, 43, 81, 1),
  //                                 fontSize: 16)
  //                         ),
  //                       ],
  //                     ),
  //                     SizedBox(
  //                       height: 10,
  //                     ),
  //                     CustomTextField(
  //                       validator: (value) {
  //                         if (value == null || value.isEmpty) {
  //                           return 'Please enter account name';
  //                         }
  //                         return null;
  //                       },
  //                       keyboardType: TextInputType.text,
  //                       hintText: 'Enter account name',
  //                       controller: accountname,
  //                     ),
  //                     SizedBox(
  //                       height: 10,
  //                     ),
  //                     //account type
  //                     Row(
  //                       children: [
  //                         Text("Account Type",
  //                             style: TextStyle(
  //                                 fontWeight: FontWeight.bold,
  //                                 color: Color.fromRGBO(
  //                                     21, 43, 81, 1),
  //                                 fontSize: 16)
  //                         ),
  //                       ],
  //                     ),
  //                     SizedBox(
  //                       height: 10,
  //                     ),
  //                     Row(
  //                       children: [
  //                         CustomDropdown(
  //                           validator: (value) {
  //                             if (value == null || value.isEmpty) {
  //                               return 'Please select a account';
  //                             }
  //                             return null;
  //                           },
  //                           labelText: 'Select',
  //                           items: accounttypeitems,
  //                           selectedValue: _selectedAccounttype,
  //                           onChanged: (String? value) {
  //                             print(_selectedAccounttype);
  //                             setState(() {
  //                               _selectedAccounttype = value;
  //
  //                             });
  //                           },
  //                         ),
  //                       ],
  //                     ),
  //                     SizedBox(
  //                       height: 10,
  //                     ),
  //                     //fundtype
  //                     Row(
  //                       children: [
  //                         Text("Fund Type",
  //                             style: TextStyle(
  //                                 fontWeight: FontWeight.bold,
  //                                 color: Color.fromRGBO(
  //                                     21, 43, 81, 1),
  //                                 fontSize: 16)
  //                         ),
  //                       ],
  //                     ),
  //                     SizedBox(
  //                       height: 10,
  //                     ),
  //                     Row(
  //                       children: [
  //                         CustomDropdown(
  //                           validator: (value) {
  //                             if (value == null || value.isEmpty) {
  //                               return 'Please select a account';
  //                             }
  //                             return null;
  //                           },
  //                           labelText: 'Select',
  //                           items: fundtypeitems,
  //                           selectedValue: _selectedFundtype,
  //                           onChanged: (String? value) {
  //                             print(_selectedFundtype);
  //                             setState(() {
  //                               _selectedFundtype = value;
  //
  //                             });
  //                           },
  //                         ),
  //                       ],
  //                     ),
  //                     SizedBox(
  //                       height: 10,
  //                     ),
  //                     Row(
  //                       children: [
  //                         Text("Note",
  //                             style: TextStyle(
  //                                 fontWeight: FontWeight.bold,
  //                                 color: Color.fromRGBO(
  //                                     21, 43, 81, 1),
  //                                 fontSize: 16)
  //                         ),
  //                       ],
  //                     ),
  //                     SizedBox(
  //                       height: 10,
  //                     ),
  //                     CustomTextField(
  //                       validator: (value) {
  //                         if (value == null || value.isEmpty) {
  //                           return 'Please enter notes';
  //                         }
  //                         return null;
  //                       },
  //                       keyboardType: TextInputType.text,
  //                       hintText: 'Enter notes',
  //                       controller: note,
  //                     ),
  //                     SizedBox(
  //                       height: 20,
  //                     ),
  //                     Row(
  //                       children: [
  //                         InkWell(
  //                           onTap: () async {
  //                             if (_selectedAccounttype == null ||
  //                                 accountname.text.isEmpty ||
  //                                 _selectedFundtype == null) {
  //                               setState(() {
  //                                 isError = true;
  //                               });
  //                             } else {
  //                               setState(() {
  //                                 isLoading = true;
  //                                 isError = false;
  //                               });
  //
  //                               SharedPreferences prefs = await SharedPreferences.getInstance();
  //                               String? id = prefs.getString("adminId");
  //                               // Post the account data
  //                               await accountRepository().addAccount(
  //                                 adminId: id!,
  //                                 account: accountname.text,
  //                                 accounttype: _selectedAccounttype,
  //                                 fundtype: _selectedFundtype,
  //                                 chargetype: _selectedAccount,
  //                                 notes: note.text,
  //                               ).then((value) {
  //                                 setState(() {
  //                                   isLoading = false;
  //                                 });
  //                                 Navigator.pop(context, true);
  //                                 _refreshAccounts();
  //                               }).catchError((e) {
  //                                 setState(() {
  //                                   isLoading = false;
  //                                 });
  //                               });
  //                             }
  //                           },
  //                           child: Container(
  //                             height: 40,
  //                             width: 100,
  //                             decoration: BoxDecoration(
  //                               color: blueColor,
  //                               borderRadius: BorderRadius.circular(3),
  //                             ),
  //                             child: Center(
  //                               child: Text('Add',style: TextStyle(
  //                                   color: Colors.white
  //                               ),),
  //                             ),
  //                           ),
  //                         ),
  //                         SizedBox(width: 20,),
  //                         InkWell(
  //                           onTap: (){
  //                             Navigator.pop(context);
  //                           },
  //                           child: Container(
  //                             height: 40,
  //                             width: 100,
  //                             decoration: BoxDecoration(
  //                               color: Colors.white,
  //                               borderRadius: BorderRadius.circular(3),
  //                             ),
  //                             child: Center(
  //                               child: Text('Cancel',style: TextStyle(
  //                                   color: blueColor
  //                               ),),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     if (isError)
  //                       Padding(
  //                         padding: const EdgeInsets.only(top: 8.0),
  //                         child: Text(
  //                           'Please fill all fields',
  //                           style: TextStyle(color: Colors.red),
  //                         ),
  //                       ),
  //                   ],
  //                 ),
  //               ),
  //
  //             );
  //         });
  //
  //     },
  //   );
  // }

  void _showAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Add Account',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: blueColor,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Account Name",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter account name';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    hintText: 'Enter account name',
                    controller: accountname,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Account Type",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  CustomDropdown(
                    validator: (value) {
                      if (_selectedAccounttype == null) {
                        return 'Please select an account type';
                      }
                      return null;
                    },
                    labelText: 'Select',
                    items: accounttypeitems,
                    selectedValue: _selectedAccounttype,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedAccounttype = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Fund Type",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  CustomDropdown(
                    validator: (value) {
                      if (_selectedFundtype == null) {
                        return 'Please select a fund type';
                      }
                      return null;
                    },
                    labelText: 'Select',
                    items: fundtypeitems,
                    selectedValue: _selectedFundtype,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedFundtype = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Note",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter notes';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    hintText: 'Enter notes',
                    controller: note,
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            if (_selectedAccounttype == null ||
                                accountname.text.trim().isEmpty ||
                                _selectedFundtype == null) {
                              setState(() {
                                isError = true;
                              });
                            } else {
                              setState(() {
                                isLoading = true;
                                isError = false;
                              });

                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              String? id = prefs.getString("adminId");

                              try {
                                await accountRepository().addAccount(
                                  adminId: id!,
                                  account: accountname.text.trim(),
                                  accounttype: _selectedAccounttype,
                                  fundtype: _selectedFundtype,
                                  chargetype: "",
                                  notes: note.text.trim(),
                                );
                                Navigator.pop(context);
                                _refreshAccounts();
                              } catch (e) {
                                setState(() {
                                  isError = true;
                                });
                              } finally {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            }
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: blueColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Center(
                              child: isLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      'Add',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: blueColor),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Please fill all fields',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget buildTextField(
      String label, String hintText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
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
