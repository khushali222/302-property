import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
//import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/StaffModule/repository/setting.dart';
import 'package:three_zero_two_property/StaffModule/widgets/appbar.dart';
import 'package:three_zero_two_property/StaffModule/widgets/custom_drawer.dart';

import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/model/setting.dart';
import 'package:three_zero_two_property/provider/color_theme.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';

import 'package:three_zero_two_property/widgets/CustomTableShimmer.dart';

import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';

import '../../../screens/Leasing/RentalRoll/addcard/AddCard.dart';
import '../Leasing/RentalRoll/newAddLease.dart';

/// One tappable row in the redesigned settings menu.
/// [tabKey] selects which content section to show.
class _SettingsMenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String tabKey;
  final String? badge;
  const _SettingsMenuItem(this.title, this.subtitle, this.icon, this.tabKey,
      {this.badge});
}

/// A titled group of settings rows (e.g. FINANCIAL, COMPANY).
class _SettingsMenuSection {
  final String header;
  final List<_SettingsMenuItem> items;
  const _SettingsMenuSection(this.header, this.items);
}

class TabBarExample extends StatefulWidget {
  @override
  State<TabBarExample> createState() => _TabBarExampleState();
}

class _TabBarExampleState extends State<TabBarExample> {
  int _selectedRadio = 0;
  TextEditingController credit = TextEditingController();
  TextEditingController debit = TextEditingController();
  TextEditingController percent = TextEditingController();
  TextEditingController flat = TextEditingController();
  TextEditingController late_fee = TextEditingController();
  TextEditingController duration = TextEditingController();
  TextEditingController durationmail = TextEditingController();
  TextEditingController replyToEmail = TextEditingController();

  bool rentDueReminderEmail = false;

  String _originalReplyToEmail = "";
  String _originalDurationMail = "";
  bool _originalRentDueReminderEmail = false;

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
  bool isdateformate = false;

  // ---- Redesigned settings menu state ----
  // When true, the categorized menu (search + cards) is shown.
  // When false, the selected section's content is shown with a back button.
  bool _showSettingsMenu = true;
  String _currentSettingsTitle = '';
  final TextEditingController _settingsSearchController =
      TextEditingController();
  String _settingsSearchQuery = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureaccount = accountRepository().fetchAccounts();
    fetchSurchargeData();
    fetchlatefeeData();
    fetchMailData();
    accountname = TextEditingController();
    note = TextEditingController();
    // _loadColorPreference();
  }

  @override
  void dispose() {
    accountname.dispose();
    note.dispose();
    _settingsSearchController.dispose();
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
      Setting1 surcharges = await surchargeRepository.fetchSurchargeData('$id');

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
          _selectedRadio = surcharges.surchargePercentACH != 0.0 &&
                  surcharges.surchargeFlatACH != 0.0
              ? 3
              : surcharges.surchargePercentACH != 0.0
                  ? 1
                  : surcharges.surchargeFlatACH != 0.0
                      ? 2
                      : 0;
        });
      }
    } catch (e) {
      print('Failed to load surcharge data: $e');
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
        "surcharge_percent": credit.text.trim().isNotEmpty
            ? int.parse(credit.text.trim())
            : null,
        "surcharge_percent_debit":
            debit.text.trim().isNotEmpty ? int.parse(debit.text.trim()) : null,
        "surcharge_percent_ACH": percent.text.trim().isNotEmpty
            ? int.parse(percent.text.trim())
            : null, // Add your logic to get this value
        "surcharge_flat_ACH": flat.text.trim().isNotEmpty
            ? int.parse(flat.text.trim())
            : null, // Add your logic to get this value
      };

      bool success =
          await surchargeRepository.updateSurchargeData('$surge_id', data);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Surcharge Updated Successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to Update Surcharge')));
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
        "surcharge_percent": credit.text.trim().isNotEmpty
            ? int.parse(credit.text.trim())
            : null,
        "surcharge_percent_debit":
            debit.text.trim().isNotEmpty ? int.parse(debit.text.trim()) : null,
        "surcharge_percent_ACH": percent.text.trim().isNotEmpty
            ? int.parse(percent.text.trim().trim())
            : null, // Add your logic to get this value
        "surcharge_flat_ACH": flat.text.trim().isNotEmpty
            ? int.parse(flat.text.trim())
            : null, // Add your logic to get this value
      };

      bool success =
          await surchargeRepository.AddSurgeData('1714649182536', data);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Surcharge Updated Successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to Update Surcharge')));
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
        "duration": duration.text.trim().isNotEmpty
            ? double.parse(duration.text.trim())
            : null,
        "late_fee": late_fee.text.trim().isNotEmpty
            ? double.parse(late_fee.text.trim())
            : null,
      };

      bool success =
          await latefeerepository.updateLatefeesData('$latefee_id', data);

      if (success) {
        Fluttertoast.showToast(
          msg: 'Late Fee Updated Successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to Update Late Fee',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print('Failed to update surcharge data: $e');
      Fluttertoast.showToast(
        msg: 'Error: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
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
        "duration": duration.text.trim().isNotEmpty
            ? int.parse(duration.text.trim())
            : null,
        "late_fee": late_fee.text.trim().isNotEmpty
            ? int.parse(late_fee.text.trim())
            : null,
      };

      bool success =
          await latefeerepository.AddLatefeesData('1714649182536', data);

      if (success) {
        Fluttertoast.showToast(
          msg: 'Late Fee updated successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to Update Late Fee',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print('Failed to update Late Fee data: $e');
      Fluttertoast.showToast(
        msg: 'Error: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
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
          replyToEmail.text = latefee.replyTo ?? "";
          //  rentDueReminderEmail = true;
          if (latefee.remindermail != null) {
            rentDueReminderEmail = latefee.remindermail!;
          }
          print(rentDueReminderEmail);

          _originalReplyToEmail = replyToEmail.text.trim();
          _originalDurationMail = latefee.duration?.toString() ?? "";
          _originalRentDueReminderEmail = latefee.remindermail ?? false;
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
        "duration": rentDueReminderEmail
            ? (durationmail.text.trim().isNotEmpty
                ? double.parse(durationmail.text.trim())
                : null)
            : 0,
        "replyToEmail": replyToEmail.text.trim(),
        "remindermail": rentDueReminderEmail,
      };

      bool success = await mailrepository.updateMailData(data);

      if (success) {
        _originalReplyToEmail = replyToEmail.text.trim();
        _originalDurationMail = durationmail.text.trim();
        _originalRentDueReminderEmail = rentDueReminderEmail;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('mail Updated Successfully')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Failed to Update mail')));
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
        "duration": rentDueReminderEmail
            ? (durationmail.text.trim().isNotEmpty
                ? int.parse(durationmail.text.trim())
                : null)
            : 0,
        "replyToEmail": replyToEmail.text.trim(),
        "remindermail": rentDueReminderEmail,
      };

      bool success = await mailrepository.AddMailData(id, data);

      if (success) {
        await fetchMailData();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('mail Updated Successfully')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Failed to Update ,ail')));
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
        borderRadius: const BorderRadius.only(
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
              child: const Icon(
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
                        ? const Text("Account", style: TextStyle(color: Colors.white))
                        : const Text("Account",
                            style: TextStyle(color: Colors.white)),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 3),
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
                child: const Row(
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
                child: const Row(
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
      style: const AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(
                color: blueColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
          radius: BorderRadius.circular(8), // Rounded corners
          border: Border.all(
            color: blueColor, // Blue border
            width: 1.5,
          ),
        ),
        DialogButton(
          child: const Text(
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
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                icon: const Icon(
                  Icons.arrow_drop_down,
                  size: 40,
                ),
                style: const TextStyle(color: Colors.black, fontSize: 17),
                dropdownColor: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
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
          style: const TextStyle(fontSize: 18),
        ),
        IconButton(
          icon: FaIcon(
            size: 30,
            FontAwesomeIcons.circleChevronRight,
            color: (_currentPage + 1) * _rowsPerPage >= _tableData.length
                ? Colors.grey
                : const Color.fromRGBO(
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

  // ===================== Redesigned settings menu =====================
  // Categorized list of every settings section available to staff. Each
  // item's [tabKey] toggles the same content flags used by the old buttons.
  List<_SettingsMenuSection> get _settingsMenuSections => const [
        _SettingsMenuSection('FINANCIAL', [
          _SettingsMenuItem('Surcharge', 'Default surcharge percentages',
              Icons.receipt_long_outlined, 'surcharge'),
          _SettingsMenuItem('Late Fee', 'Grace period & penalty rules',
              Icons.schedule_outlined, 'latefee'),
        ]),
        _SettingsMenuSection('COMPANY', [
          _SettingsMenuItem('Manage Accounts', 'Bank & liability accounts',
              Icons.account_balance_outlined, 'accounts'),
        ]),
        _SettingsMenuSection('PREFERENCES', [
          _SettingsMenuItem('Mail Service', 'SMTP & notification senders',
              Icons.mail_outline, 'mail'),
        ]),
      ];

  Widget _buildSettingsMenu() {
    final q = _settingsSearchQuery.trim().toLowerCase();
    final filtered = _settingsMenuSections
        .map((s) => _SettingsMenuSection(
            s.header,
            s.items
                .where((it) =>
                    q.isEmpty ||
                    it.title.toLowerCase().contains(q) ||
                    it.subtitle.toLowerCase().contains(q))
                .toList()))
        .where((s) => s.items.isNotEmpty)
        .toList();

    return Container(
      color: const Color(0xFFF1F4F9),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
        children: [
          _buildSettingsSearchField(),
          const SizedBox(height: 20),
          if (filtered.isEmpty)
            _buildNoSettingsResults()
          else
            ...filtered.map(_buildSettingsMenuSection),
        ],
      ),
    );
  }

  Widget _buildSettingsSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _settingsSearchController,
        onChanged: (v) => setState(() => _settingsSearchQuery = v),
        cursorColor: blueColor,
        style: TextStyle(
            color: blueColor, fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Search settings',
          hintStyle: const TextStyle(
            color: Color(0xFF8A95A8),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF8A95A8)),
          suffixIcon: _settingsSearchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close,
                      color: Color(0xFF8A95A8), size: 20),
                  onPressed: () {
                    setState(() {
                      _settingsSearchController.clear();
                      _settingsSearchQuery = '';
                    });
                    FocusScope.of(context).unfocus();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSettingsMenuSection(_SettingsMenuSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 10),
          child: Text(
            section.header,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: Color(0xFF8A95A8),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < section.items.length; i++) ...[
                _buildSettingsMenuTile(section.items[i]),
                if (i != section.items.length - 1)
                  const Padding(
                    padding: EdgeInsets.only(left: 74, right: 16),
                    child: Divider(
                        height: 1, thickness: 1, color: Color(0xFFEEF1F5)),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 22),
      ],
    );
  }

  Widget _buildSettingsMenuTile(_SettingsMenuItem item) {
    final bool isActive = _currentSettingsTitle == item.title;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openSettingsSection(item.tabKey, item.title),
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFEEF1FB) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF1FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: blueColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: blueColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8A95A8),
                      ),
                    ),
                  ],
                ),
              ),
              if (item.badge != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFF3E4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.badge!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Color(0xFF2E7D45),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(Icons.chevron_right,
                  color: Color(0xFFAEB7C7), size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoSettingsResults() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 54, color: Colors.grey.shade400),
          const SizedBox(height: 14),
          Text(
            'No settings found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: blueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search term',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  void _openSettingsSection(String key, String title) {
    setState(() {
      issurge = key == 'surcharge';
      islatefee = key == 'latefee';
      ismail = key == 'mail';
      isaccounts = key == 'accounts';
      isdateformate = false;
      _currentSettingsTitle = title;
      _showSettingsMenu = false;
      _settingsSearchController.clear();
      _settingsSearchQuery = '';
    });
    FocusScope.of(context).unfocus();
  }

  void _backToSettingsMenu() {
    FocusScope.of(context).unfocus();
    setState(() {
      _showSettingsMenu = true;
    });
  }

  Widget _buildSettingsDetailHeader() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 16, 14),
            child: Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _backToSettingsMenu,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF1F5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.chevron_left,
                          color: blueColor, size: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    _currentSettingsTitle.isEmpty
                        ? 'Settings'
                        : _currentSettingsTitle,
                    style: TextStyle(
                      color: blueColor,
                      fontWeight: FontWeight.bold,
                      fontSize:
                          MediaQuery.of(context).size.width < 500 ? 24 : 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE7EBF1)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: widget_302_Staff.App_Bar(context: context),
        backgroundColor: Colors.white,
        drawer: CustomDrawerStaff(
          currentpage: "Settings",
          dropdown: false,
        ),
        body: _showSettingsMenu
            ? _buildSettingsMenu()
            : Container(
                color: const Color(0xFFF1F4F9),
                child: ListView(padding: EdgeInsets.zero, children: [
          _buildSettingsDetailHeader(),
          const SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18, right: 18),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                //border: Border.all(color: blueColor),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  if (issurge)
                    Column(
                      children: [
                        const SizedBox(
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
                                    MediaQuery.of(context).size.width < 500
                                        ? 18
                                        : 25,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "You can set default surcharge percentage from here",
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 500
                                            ? 15
                                            : 20,
                                    color: const Color(0xFF8A95A8),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 20,
                                            color: blueColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
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
                                                controller: credit,
                                                cursorColor: blueColor,
                                                decoration: InputDecoration(
                                                  // hintText: "Enter password",
                                                  hintStyle: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .037,
                                                    color: const Color(0xFF8A95A8),
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
                                                      const EdgeInsets.all(13),
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
                                const SizedBox(width: 16),
                                // Second Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Debit Card Surcharge Percent",
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
                                      const SizedBox(height: 8),
                                      Container(
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
                                                controller: debit,
                                                cursorColor: blueColor,
                                                decoration: InputDecoration(
                                                  // hintText: "Enter password",
                                                  hintStyle: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .037,
                                                    color: const Color(0xFF8A95A8),
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
                                                      const EdgeInsets.all(13),
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
                        const SizedBox(
                          height: 10,
                        ),
                        if (MediaQuery.of(context).size.width > 500)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 20,
                                            color: blueColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Material(
                                        elevation: 4,
                                        borderRadius: BorderRadius.circular(10),
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
                                                  decoration: InputDecoration(
                                                    // hintText: "Enter password",
                                                    hintStyle: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .037,
                                                      color: const Color(0xFF8A95A8),
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
                                                        const EdgeInsets.all(13),
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
                                const SizedBox(width: 16),
                                // Second Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Debit Card Surcharge Percent",
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
                                      const SizedBox(height: 8),
                                      Material(
                                        elevation: 4,
                                        borderRadius: BorderRadius.circular(10),
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
                                                  decoration: InputDecoration(
                                                    // hintText: "Enter password",
                                                    hintStyle: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .037,
                                                      color: const Color(0xFF8A95A8),
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
                                                        const EdgeInsets.all(13),
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
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "You can set default ACH percentage or ACH flat fee or both from here",
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 500
                                            ? 15
                                            : 20,
                                    color: const Color(0xFF8A95A8),
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
                                    MediaQuery.of(context).size.width < 500
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
                                    MediaQuery.of(context).size.width < 500
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
                                    MediaQuery.of(context).size.width < 500
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
                        if (_selectedRadio == 1 || _selectedRadio == 3) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Add ACH Surcharge Percentage',
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 500
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
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const SizedBox(width: 5),
                              Expanded(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width * .5,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: grey),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5),
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
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .037,
                                              color: const Color(0xFF8A95A8),
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
                                            contentPadding: const EdgeInsets.all(13),
                                            suffixIcon: const Icon(
                                              Icons.percent,
                                              color:
                                                  Color.fromRGBO(21, 43, 81, 1),
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
                                const SizedBox(width: 190),
                              if (MediaQuery.of(context).size.width > 500)
                                const SizedBox(width: 380),
                            ],
                          ),
                        ],
                        if (_selectedRadio == 2 || _selectedRadio == 3) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const SizedBox(width: 5),
                              Text(
                                'Add ACH Flat Fee',
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 500
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
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const SizedBox(width: 5),
                              Expanded(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width * .5,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: grey),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5),
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
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .037,
                                              color: const Color(0xFF8A95A8),
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
                                            contentPadding: const EdgeInsets.all(13),
                                            suffixIcon: const Icon(
                                              Icons.percent,
                                              color:
                                                  Color.fromRGBO(21, 43, 81, 1),
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
                                const SizedBox(width: 190),
                              if (MediaQuery.of(context).size.width > 500)
                                const SizedBox(width: 380),
                            ],
                          ),
                        ],
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            const SizedBox(
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
                                      MediaQuery.of(context).size.width < 500
                                          ? 35
                                          : 50,
                                  width: MediaQuery.of(context).size.width < 500
                                      ? 100
                                      : 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: blueColor,
                                    boxShadow: [
                                      const BoxShadow(
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
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 15
                                                : 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            GestureDetector(
                              onTap: () {
                                debit.clear();
                                credit.clear();
                                flat.clear();
                                percent.clear();
                              },
                              child: Container(
                                  height:
                                      MediaQuery.of(context).size.width < 500
                                          ? 35
                                          : 50,
                                  width: MediaQuery.of(context).size.width < 500
                                      ? 100
                                      : 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: blueColor,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                      child: Text(
                                    "Reset",
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width <
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
                  if (ismail) _buildMailServiceSection(),
                  if (islatefee)
                    Column(
                      children: [
                        const SizedBox(
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
                                    MediaQuery.of(context).size.width < 500
                                        ? 18
                                        : 25,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "You can set default Late fee charge from here",
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 500
                                            ? 15
                                            : 20,
                                    color: const Color(0xFF8A95A8),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        if (MediaQuery.of(context).size.width < 500)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 20,
                                            color: blueColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
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
                                                controller: late_fee,
                                                onChanged: (value) {
                                                  setState(() {
                                                    //  passworderror = false;
                                                  });
                                                },
                                                //  controller: password,
                                                cursorColor: blueColor,
                                                decoration: InputDecoration(
                                                  // hintText: "Enter password",
                                                  hintStyle: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .037,
                                                    color: const Color(0xFF8A95A8),
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
                                                      const EdgeInsets.all(13),
//                                                   suffixIcon: Icon(
//                                                     Icons.percent,
//                                                     color: blueColor
//
//
// ,
//                                                     size: 18,
//                                                   ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Second Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
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
                                      const SizedBox(height: 5),
                                      Container(
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
                                                controller: duration,
                                                onChanged: (value) {
                                                  setState(() {
                                                    //  passworderror = false;
                                                  });
                                                },
                                                //  controller: password,
                                                cursorColor: blueColor,
                                                decoration: InputDecoration(
                                                  // hintText: "Enter password",
                                                  hintStyle: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .037,
                                                    color: const Color(0xFF8A95A8),
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
                                                      const EdgeInsets.all(13),
//                                                   suffixIcon: Icon(
//                                                     Icons.percent,
//                                                     color: blueColor
//
//
// ,
//                                                     size: 18,
//                                                   ),
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
                        const SizedBox(
                          height: 10,
                        ),
                        if (MediaQuery.of(context).size.width > 500)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 20,
                                            color: const Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 5),
                                      Material(
                                        elevation: 4,
                                        borderRadius: BorderRadius.circular(10),
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
                                                  decoration: InputDecoration(
                                                    // hintText: "Enter password",
                                                    hintStyle: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .037,
                                                      color: const Color(0xFF8A95A8),
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
                                                        const EdgeInsets.all(13),
//                                                     suffixIcon: Icon(
//                                                       Icons.percent,
//                                                       color: blueColor
//
//
// ,
//                                                       size: 18,
//                                                     ),
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
                                const SizedBox(width: 16),
                                // Second Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Duration",
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 20,
                                            color: const Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 5),
                                      Material(
                                        elevation: 4,
                                        borderRadius: BorderRadius.circular(10),
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
                                                  decoration: InputDecoration(
                                                    // hintText: "Enter password",
                                                    hintStyle: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .037,
                                                      color: const Color(0xFF8A95A8),
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
                                                        const EdgeInsets.all(13),
//                                                     suffixIcon: Icon(
//                                                       Icons.percent,
//                                                       color: blueColor
//
//
// ,
//                                                       size: 18,
//                                                     ),
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
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            if (MediaQuery.of(context).size.width < 500)
                              const SizedBox(width: 2),
                            if (MediaQuery.of(context).size.width > 500)
                              const SizedBox(width: 2),
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
                                      MediaQuery.of(context).size.width < 500
                                          ? 35
                                          : 50,
                                  width: MediaQuery.of(context).size.width < 500
                                      ? 100
                                      : 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: blueColor,
                                    boxShadow: [
                                      const BoxShadow(
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
                            const SizedBox(
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
                                      height:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 35
                                              : 50,
                                      width: MediaQuery.of(context).size.width <
                                              500
                                          ? 100
                                          : 120,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: blueColor,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
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
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Text(
                              "Manage Account",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: blueColor,
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 18
                                        : 25,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () async {
                                _showAccount(context);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * .045,
                                  width: MediaQuery.of(context).size.width < 500
                                      ? 120
                                      : 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: blueColor,
                                    boxShadow: [
                                      const BoxShadow(
                                        color: Colors.grey,
                                        offset: Offset(0.0, 1.0), //(x,y)
                                        blurRadius: 6.0,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: isLoading
                                        ? const SpinKitFadingCircle(
                                            color: Colors.white,
                                            size: 25.0,
                                          )
                                        : Text(
                                            "Add Account",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
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
                        const SizedBox(height: 15),
                        if (MediaQuery.of(context).size.width > 500)
                          const SizedBox(height: 25),
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
                                      child: Text('Error: ${snapshot.error}'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Container(
                                    height:
                                        MediaQuery.of(context).size.height * .5,
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
                                          const SizedBox(
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
                                            .contains(
                                                searchValue!.toLowerCase()))
                                        .toList();
                                  } else {
                                    data = snapshot.data!
                                        .where((staff) =>
                                            staff.accountType == searchValue)
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
                                        const SizedBox(height: 10),
                                        _buildHeaders(),
                                        const SizedBox(height: 20),
                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: const Color.fromRGBO(
                                                      152, 162, 179, .5))),
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
                                              Setting4 account = entry.value;
                                              //return CustomExpansionTile(data: Propertytype, index: index);
                                              return Container(
                                                decoration: BoxDecoration(
                                                  color: index % 2 != 0
                                                      ? Colors.white
                                                      : blueColor
                                                          .withOpacity(0.09),
                                                  border: Border.all(
                                                      color: const Color.fromRGBO(
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
                                                                setState(() {
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
                                                              child: Container(
                                                                margin: const EdgeInsets
                                                                    .only(
                                                                        left: 5,
                                                                        right:
                                                                            5),
                                                                padding: !isExpanded
                                                                    ? const EdgeInsets.only(
                                                                        bottom:
                                                                            10)
                                                                    : const EdgeInsets
                                                                        .only(
                                                                            top:
                                                                                10),
                                                                child: FaIcon(
                                                                  isExpanded
                                                                      ? FontAwesomeIcons
                                                                          .sortUp
                                                                      : FontAwesomeIcons
                                                                          .sortDown,
                                                                  size: 20,
                                                                  color:
                                                                      blueColor,
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: InkWell(
                                                                onTap: () {
                                                                  setState(() {
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
                                                                child: Text(
                                                                  '${account.account}',
                                                                  style:
                                                                      TextStyle(
                                                                    color:
                                                                        blueColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        13,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .08),
                                                            Expanded(
                                                              child: Text(
                                                                '${account.accountType}',
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      blueColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 13,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .08),
                                                            Expanded(
                                                              child: Text(
                                                                '${account.fundType}',
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      blueColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 13,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .02),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    if (isExpanded)
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.only(
                                                                left: 2,
                                                                right: 2),
                                                        margin: const EdgeInsets.only(
                                                            bottom: 2),
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Container(
                                                            //color: Colors.blue,
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        FaIcon(
                                                                          isExpanded
                                                                              ? FontAwesomeIcons.sortUp
                                                                              : FontAwesomeIcons.sortDown,
                                                                          size:
                                                                              50,
                                                                          color:
                                                                              Colors.transparent,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text.rich(
                                                                          TextSpan(
                                                                            children: [
                                                                              TextSpan(
                                                                                text: 'Charge Type: ',
                                                                                style: TextStyle(
                                                                                  fontWeight: FontWeight.bold,
                                                                                  color: blueColor, // Bold and blue
                                                                                ),
                                                                              ),
                                                                              TextSpan(
                                                                                text: '${account.chargeType}',
                                                                                style: TextStyle(
                                                                                  fontWeight: FontWeight.w700,
                                                                                  color: grey, // Light and grey
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                5),
                                                                      ],
                                                                    ),
                                                                    const Spacer(),
                                                                    // Container(
                                                                    //   width: 40,
                                                                    //   child: Column(
                                                                    //     children: [
                                                                    //       IconButton(
                                                                    //         icon: FaIcon(
                                                                    //           FontAwesomeIcons.edit,
                                                                    //           size: 20,
                                                                    //           color: blueColor,
                                                                    //         ),
                                                                    //         onPressed: () async {
                                                                    //           var check = await Navigator.push(
                                                                    //             context,
                                                                    //             MaterialPageRoute(
                                                                    //               builder: (context) => Edit_staff_member(
                                                                    //                 staff: staffmembers,
                                                                    //               ),
                                                                    //             ),
                                                                    //           );
                                                                    //           if (check == true) {
                                                                    //             setState(() {});
                                                                    //           }
                                                                    //         },
                                                                    //       ),
                                                                    //       IconButton(
                                                                    //         icon: FaIcon(
                                                                    //           FontAwesomeIcons.trashCan,
                                                                    //           size: 20,
                                                                    //           color: blueColor,
                                                                    //         ),
                                                                    //         onPressed: () {
                                                                    //           _showDeleteAlert(context, staffmembers.staffmemberId!);
                                                                    //         },
                                                                    //       ),
                                                                    //     ],
                                                                    //   ),
                                                                    // ),
                                                                    const SizedBox(
                                                                        width:
                                                                            5),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          _showDeleteAlert(
                                                                              context,
                                                                              account.accountId!);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              40,
                                                                          decoration:
                                                                              BoxDecoration(color: Colors.grey[350]),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              FaIcon(
                                                                                FontAwesomeIcons.trashCan,
                                                                                size: 15,
                                                                                color: blueColor,
                                                                              ),
                                                                              const SizedBox(
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
                                        if (totalPages > 1) ...[
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Row(
                                              children: [
                                                // Text('Rows per page:'),
                                                const SizedBox(width: 10),
                                                Material(
                                                  elevation: 3,
                                                  child: Container(
                                                    height: 40,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 12.0),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.grey),
                                                    ),
                                                    child:
                                                        DropdownButtonHideUnderline(
                                                      child:
                                                          DropdownButton<int>(
                                                        value: itemsPerPage,
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
                                                        onChanged: data.length >
                                                                itemsPerPageOptions
                                                                    .first // Condition to check if dropdown should be enabled
                                                            ? (newValue) {
                                                                setState(() {
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
                                                    color: currentPage == 0
                                                        ? Colors.grey
                                                        : blueColor,
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
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Container(
                                  height:
                                      MediaQuery.of(context).size.height * .5,
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
                                        const SizedBox(
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
                                if (selectedRole == null && searchValue == "") {
                                  filteredData = snapshot.data;
                                } else if (selectedRole == "All") {
                                  filteredData = snapshot.data;
                                } else if (searchValue.isNotEmpty) {
                                  filteredData = snapshot.data!
                                      .where((staff) =>
                                          staff.account!.toLowerCase().contains(
                                              searchValue.toLowerCase()) ||
                                          staff.accountType!
                                              .toLowerCase()
                                              .contains(
                                                  searchValue.toLowerCase()))
                                      .toList();
                                } else {
                                  filteredData = snapshot.data!
                                      .where((staff) =>
                                          staff.accountType == selectedRole)
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
                                                const IntrinsicColumnWidth(),
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
                                                      (staff) =>
                                                          staff.accountType!),
                                                  _buildHeader(
                                                      'ChargeType', 2, null),
                                                  _buildHeader(
                                                      'FundType', 3, null),
                                                  _buildHeader(
                                                      'Actions', 4, null),
                                                ],
                                              ),
                                              TableRow(
                                                decoration: const BoxDecoration(
                                                  border: Border.symmetric(
                                                      horizontal:
                                                          BorderSide.none),
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
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      left: const BorderSide(
                                                          color: Color.fromRGBO(
                                                              21, 43, 81, 1)),
                                                      right: const BorderSide(
                                                          color: Color.fromRGBO(
                                                              21, 43, 81, 1)),
                                                      top: const BorderSide(
                                                          color: Color.fromRGBO(
                                                              21, 43, 81, 1)),
                                                      bottom: i ==
                                                              _pagedData
                                                                      .length -
                                                                  1
                                                          ? const BorderSide(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      21,
                                                                      43,
                                                                      81,
                                                                      1))
                                                          : BorderSide.none,
                                                    ),
                                                  ),
                                                  children: [
                                                    _buildDataCell(
                                                        _pagedData[i].account!),
                                                    _buildDataCell(_pagedData[i]
                                                        .accountType!),
                                                    _buildDataCell(_pagedData[i]
                                                        .chargeType!),
                                                    _buildDataCell(_pagedData[i]
                                                        .fundType!),
                                                    _buildActionsCell(
                                                        _pagedData[i]),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 25),
                                      _buildPaginationControls(),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ])),
      ),
    );
  }

  Widget _buildMailServiceSection() {
    final bool isSmall = MediaQuery.of(context).size.width < 500;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        // ===== Card 1: Mail Service =====
        _buildSettingsCard(
          icon: Icons.mail_outline,
          title: "MAIL SERVICE",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Reply-To Address",
                style: TextStyle(
                  fontSize: isSmall ? 15 : 20,
                  color: blueColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildMailTextField(
                controller: replyToEmail,
                hint: "Enter email",
              ),
              const SizedBox(height: 8),
              Text(
                "Tenant replies to automated emails will go to this address.",
                style: TextStyle(
                  fontSize: isSmall ? 12 : 15,
                  color: const Color(0xFF8A95A8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // ===== Card 2: Rent Due Reminder =====
        _buildSettingsCard(
          icon: Icons.notifications_none,
          title: "RENT DUE REMINDER",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRentDueReminderSwitch(),
              Text(
                "You can set a duration for send reminder email before rent due date to tenant",
                style: TextStyle(
                  fontSize: isSmall ? 12 : 15,
                  color: const Color(0xFF8A95A8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (rentDueReminderEmail) ...[
                const SizedBox(height: 14),
                Text(
                  "Duration (days before rent due)",
                  style: TextStyle(
                    fontSize: isSmall ? 15 : 20,
                    color: blueColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildMailTextField(
                  controller: durationmail,
                  hint: "1",
                  keyboardType: TextInputType.number,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        // ===== Buttons: Reset + Save Changes =====
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    replyToEmail.text = _originalReplyToEmail;
                    durationmail.text = _originalDurationMail;
                    rentDueReminderEmail = _originalRentDueReminderEmail;
                  });
                },
                child: Container(
                  height: isSmall ? 44 : 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: blueColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "Reset",
                      style: TextStyle(
                        color: blueColor,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmall ? 16 : 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  if (mailupdate)
                    await updateMail();
                  else
                    await Addmail();
                },
                child: Container(
                  height: isSmall ? 44 : 52,
                  decoration: BoxDecoration(
                    color: blueColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0),
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Save Changes",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmall ? 16 : 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD9DEE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFEAEFF6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: blueColor, size: 20),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: blueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildMailTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: grey),
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        cursorColor: const Color.fromRGBO(21, 43, 81, 1),
        onChanged: (value) {
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: MediaQuery.of(context).size.width * .037,
            color: const Color(0xFF8A95A8),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(13),
        ),
      ),
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
          const SizedBox(
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
                  child: const Center(
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
                    const SizedBox(height: 20),
                    Text(
                      "Select Account Type",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: blueColor,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                  Text(
                    "Account Name",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
                  Text(
                    "Account Type",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
                  Text(
                    "Fund Type",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
                  Text(
                    "Note",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 20),
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
                                Navigator.pop(context, true);
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
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Add',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
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
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
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
}
