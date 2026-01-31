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
import 'package:three_zero_two_property/Model/WorkOrderSetting.dart'
    as WorkOrderModel;
import 'package:three_zero_two_property/repository/SettingWorkorder.dart';

import 'package:three_zero_two_property/repository/setting.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/StaffModule/widgets/appbar.dart'
    as widget_302_Staff;
import 'package:http/http.dart' as http;

import '../../Model/categories_model.dart';
import '../../StaffModule/widgets/custom_drawer.dart';
import '../../constant/constant.dart';
import '../../model/setting.dart';
import '../../provider/dateProvider.dart';
import '../../widgets/CustomTableShimmer.dart';
import '../../widgets/custom_drawer.dart';
import '../Leasing/RentalRoll/newAddLease.dart';
import '../Rental/Tenants/add_tenants.dart';
import 'manage_template.dart';
import 'package:three_zero_two_property/Model/All_categories_model.dart';
import 'package:three_zero_two_property/repository/fetch_allcategories.dart';
import '../Maintenance/Vendor/edit_vendor.dart' hide CustomTextField;
import '../Maintenance/Vendor/add_vendor.dart' hide CustomTextField;
import '../../Model/vendor.dart';
import '../../repository/vendor_repository.dart';
import '../Rental/Rentalowner/Rentalowner_table.dart';
import '../Property_Type/Property_type_table.dart';
import '../Maintenance/Vendor/Vendor_table.dart';
// Staff module table widgets
import '../../StaffModule/screen/Rental/Rentalowner/Rentalowner_table.dart'
    as StaffRentalOwner;
import '../../StaffModule/screen/Property_Type/Property_type_table.dart'
    as StaffPropertyType;
import '../../StaffModule/screen/Maintenance/Vendor/Vendor_table.dart'
    as StaffVendor;

class TabBarExample extends StatefulWidget {
  final String? initialTab; // Optional parameter to specify which tab to open

  const TabBarExample({super.key, this.initialTab});

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
  TextEditingController grace_balance = TextEditingController();
  TextEditingController durationmail = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController replyToEmail = TextEditingController();
  TextEditingController categories = TextEditingController();
  late Future<List<categories_model>> futureCategories;
  late Future<List<Vendor>> futureVendors;
  bool rentDueReminderEmail = false;

  String surge_id = "";
  String latefee_id = "";
  bool isupdate = false;
  bool islatefeeupdate = false;
  String calculationType = "fixed"; // "fixed" or "percent"
  String selectedAccountId = "";
  String selectedAccountName = "";
  List<Setting4> accounts = [];
  // Original values for Late Fee Charge change tracking
  String _originalDuration = "";
  String _originalLateFee = "";
  String _originalGraceBalance = "";
  String _originalCalculationType = "fixed";
  String _originalDescription = "";
  String _originalSelectedAccountName = "";
  // Original values for Mail Service change tracking
  String _originalReplyToEmail = "";
  String _originalDurationMail = "";
  bool _originalRentDueReminderEmail = false;
  bool isLoadingAccounts = false;
  bool mailupdate = false;
  bool issurge = false;
  bool ismail = false;
  bool isaccounts = true;
  bool islatefee = false;
  bool isLoading = false;
  bool isloading = false;
  bool isdateformate = false;
  bool isworkorder = false;
  bool iscategories = false;
  bool ismanagetemplate = false;
  bool ischargesetting = false;
  bool isvendor = false;
  bool ispropertyowner = false;
  bool ispropertytype = false;
  bool _isStaffUser = false;
  // Vendor table state variables
  String vendorSearchValue = "";
  int vendorCurrentPage = 0;
  int vendorItemsPerPage = 10;
  List<int> vendorItemsPerPageOptions = [10, 25, 50, 100];
  int? vendorExpandedIndex;
  bool vendorSorting1 = true;
  bool vendorSorting2 = false;
  bool vendorAscending1 = true;
  bool vendorAscending2 = false;
  ConnectivityResult? _connectivityResult;
  String? selectedAccount;
  // 1. Add state variables
  List<allcategories_model> _dropdownCategories = [];
  allcategories_model? _selectedDropdownCategory;
  bool _isLoadingCategories = false;

  // Workorder notification settings state variables
  bool createAdmin = false;
  bool createAssignee = false;
  bool createTenant = false;
  bool updateAdmin = false;
  bool updateAssignee = false;
  bool updateTenant = false;
  bool completeAdmin = false;
  bool completeAssignee = false;
  bool completeTenant = false;
  bool isLoadingNotifications = false; // For fetching/loading data
  bool isSavingNotifications = false; // For saving data
  bool _hasLoadedNotifications =
      false; // Track if notifications have been loaded

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkUserType();
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
    loadChargeSetting();
    _loadVendor();
    _loadStaff();
    fetchWorkData();
    // fetchWorkOrderNotificationSettings(); // Removed - will be called when workorder tab is clicked
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dateProvider = Provider.of<DateProvider>(context, listen: false);
      dateProvider.loadDateFormat();

      // Set initial tab if specified
      if (widget.initialTab == 'Vendor') {
        setState(() {
          issurge = false;
          ismail = false;
          isaccounts = false;
          islatefee = false;
          isdateformate = false;
          isworkorder = false;
          ismanagetemplate = false;
          ischargesetting = false;
          iscategories = false;
          ispropertyowner = false;
          ispropertytype = false;
          isvendor = true;
        });
      } else if (widget.initialTab == 'Property Owners') {
        setState(() {
          issurge = false;
          ismail = false;
          isaccounts = false;
          islatefee = false;
          isdateformate = false;
          isworkorder = false;
          ismanagetemplate = false;
          ischargesetting = false;
          iscategories = false;
          isvendor = false;
          ispropertytype = false;
          ispropertyowner = true;
        });
      } else if (widget.initialTab == 'Property Type') {
        setState(() {
          issurge = false;
          ismail = false;
          isaccounts = false;
          islatefee = false;
          isdateformate = false;
          isworkorder = false;
          ismanagetemplate = false;
          ischargesetting = false;
          iscategories = false;
          isvendor = false;
          ispropertyowner = false;
          ispropertytype = true;
        });
      }
    });
    // _customDateController.text = customdate!;
    //  customdate = customdate ?? "2025-01-23"; // Example default date
    //  _customDateController.text = customdate!;
    futureCategories = accountRepository().fetchCategories();
    futureVendors = VendorRepository(baseUrl: '').getVendors();
    _loadDropdownCategories();
  }

  Future<void> _loadDropdownCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });
    try {
      final cats = await FetchAllcategories().fetchAllCategories();
      setState(() {
        // Sort categories alphabetically by name
        _dropdownCategories = cats
          ..sort((a, b) => (a.name ?? '')
              .toLowerCase()
              .compareTo((b.name ?? '').toLowerCase()));
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      // Optionally show error
    }
  }

  // Add this helper method after the initState method
  Future<String?> _getApiId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? staffId = prefs.getString('staff_id');
    String? adminId = prefs.getString('adminId');

    // Use staff_id if it exists, otherwise use admin_id
    return (staffId != null && staffId.isNotEmpty) ? staffId : adminId;
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
  final accountRepository accountrepository = accountRepository();
  final mailserviceRepository mailrepository =
      mailserviceRepository(baseUrl: '${Api_url}');

  Future<void> fetchSurchargeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? staffId = prefs.getString("staff_id");

    // Use staff_id if it exists, otherwise use admin_id
    String? id = (staffId != null && staffId.isNotEmpty) ? staffId : adminId;

    try {
      Setting1 surcharges =
          await surchargeRepository.fetchSurchargeData('${adminId ?? ""}');

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
          if (surcharges!.surcharge_account != null) {
            try {
              var matchingAccount = accounts.firstWhere(
                (account) => account.account == surcharges!.surcharge_account,
              );
              selectedAccount = matchingAccount.accountId;
            } catch (e) {
              selectedAccount = null; // No matching account found
            }
          } else {
            selectedAccount = null;
          }
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
      print('Failed to load surcharge dataaa: $e');
    }
  }

  Future<void> fetchAccountsData() async {
    setState(() {
      isLoadingAccounts = true;
    });
    try {
      List<Setting4> fetchedAccounts = await accountrepository.fetchAccounts();
      setState(() {
        accounts = fetchedAccounts;
        isLoadingAccounts = false;
      });
    } catch (e) {
      print('Failed to load accounts: $e');
      setState(() {
        isLoadingAccounts = false;
      });
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
          duration.text = latefee.duration.toString();
          grace_balance.text = latefee.graceBalance.toString();
          latefee_id = latefee.latefeeId;
          calculationType = latefee.calculationType;
          description.text = latefee.description;
          // Set default to "Late Fee Income" if no account value from API
          selectedAccountName = latefee.chargeAccount.isNotEmpty
              ? latefee.chargeAccount
              : "Late Fee Income";

          // Store original values for change tracking
          _originalDuration = latefee.duration.toString();
          _originalLateFee = latefee.late_fee;
          _originalGraceBalance = latefee.graceBalance.toString();
          _originalCalculationType = latefee.calculationType;
          _originalDescription = latefee.description ?? "";
          _originalSelectedAccountName = latefee.chargeAccount.isNotEmpty
              ? latefee.chargeAccount
              : "Late Fee Income";
        });
      }
    } catch (e) {
      print('Failed to load surcharge data: $e');
    }
  }

  // Check if Late Fee Charge fields have been modified
  bool _hasLateFeeChanges() {
    if (!islatefeeupdate) {
      // For new entries, check if any field has a value
      return duration.text.trim().isNotEmpty ||
          late_fee.text.trim().isNotEmpty ||
          grace_balance.text.trim().isNotEmpty ||
          description.text.trim().isNotEmpty ||
          selectedAccountName.isNotEmpty;
    }

    // For updates, compare current values with original values
    return duration.text.trim() != _originalDuration ||
        late_fee.text.trim() != _originalLateFee ||
        grace_balance.text.trim() != _originalGraceBalance ||
        calculationType != _originalCalculationType ||
        description.text.trim() != _originalDescription ||
        selectedAccountName != _originalSelectedAccountName;
  }

  // Check if Mail Service fields have been modified
  bool _hasMailServiceChanges() {
    if (!mailupdate) {
      // For new entries, check if any field has a value
      return replyToEmail.text.trim().isNotEmpty ||
          durationmail.text.trim().isNotEmpty ||
          rentDueReminderEmail;
    }

    // For updates, compare current values with original values
    return replyToEmail.text.trim() != _originalReplyToEmail ||
        durationmail.text.trim() != _originalDurationMail ||
        rentDueReminderEmail != _originalRentDueReminderEmail;
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
            ? double.parse(credit.text.trim())
            : null,
        "surcharge_percent_debit": debit.text.trim().isNotEmpty
            ? double.parse(debit.text.trim())
            : null,
        "surcharge_percent_ACH": percent.text.trim().isNotEmpty
            ? double.parse(percent.text.trim())
            : null, // Add your logic to get this value
        "surcharge_flat_ACH":
            flat.text.trim().isNotEmpty ? double.parse(flat.text.trim()) : null,
        "surcharge_account": selectedAccount != null
            ? (accounts.any((account) => account.accountId == selectedAccount)
                ? accounts
                    .firstWhere(
                        (account) => account.accountId == selectedAccount)
                    .account
                : selectedAccount)
            : null
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
        "surcharge_percent": credit.text.trim().isNotEmpty
            ? int.parse(credit.text.trim())
            : null,
        "surcharge_percent_debit":
            debit.text.trim().isNotEmpty ? int.parse(debit.text.trim()) : null,
        "surcharge_percent_ACH": percent.text.trim().isNotEmpty
            ? int.parse(percent.text.trim())
            : null, // Add your logic to get this value
        "surcharge_flat_ACH":
            flat.text.trim().isNotEmpty ? int.parse(flat.text.trim()) : null,
        "surcharge_account": selectedAccount
        // Add your logic to get this value
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
    // Check if there are any changes before proceeding
    if (!_hasLateFeeChanges()) {
      return; // No changes made, don't proceed with update
    }

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
        "grace_balance": grace_balance.text.trim().isNotEmpty
            ? int.parse(grace_balance.text.trim())
            : null,
        "late_fee": late_fee.text.trim().isNotEmpty
            ? double.parse(late_fee.text.trim())
            : null,
        "calculation_type": calculationType,
        "description":
            description.text.trim().isNotEmpty ? description.text.trim() : null,
        "charge_account":
            selectedAccountName.isNotEmpty ? selectedAccountName : null,
      };

      bool success =
          await latefeerepository.updateLatefeesData('$latefee_id', data);

      if (success) {
        // Update original values after successful save
        setState(() {
          _originalDuration = duration.text.trim();
          _originalLateFee = late_fee.text.trim();
          _originalGraceBalance = grace_balance.text.trim();
          _originalCalculationType = calculationType;
          _originalDescription = description.text.trim();
          _originalSelectedAccountName = selectedAccountName;
        });
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('Latefee Updated Successfully')));
        Fluttertoast.showToast(msg: 'Late Fee Updated Successfully');
      } else {
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(SnackBar(content: Text('Failed to Update Latefee')));
        Fluttertoast.showToast(msg: 'Failed to Update Late Fee');
      }
    } catch (e) {
      print('Failed to update Late Fee data: $e');
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text('Error: $e')));
      Fluttertoast.showToast(msg: 'Error: $e');
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
    // Check if there are any changes before proceeding
    if (!_hasLateFeeChanges()) {
      return; // No changes made, don't proceed with add
    }

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
        "grace_balance": grace_balance.text.trim().isNotEmpty
            ? int.parse(grace_balance.text.trim())
            : null,
        "late_fee": late_fee.text.trim().isNotEmpty
            ? int.parse(late_fee.text.trim())
            : null,
        "calculation_type": calculationType,
        "description":
            description.text.trim().isNotEmpty ? description.text.trim() : null,
        "charge_account":
            selectedAccountName.isNotEmpty ? selectedAccountName : null,
      };

      bool success =
          await latefeerepository.AddLatefeesData('1714649182536', data);

      if (success) {
        // After successful add, fetch the data to get the ID and update original values
        await fetchlatefeeData();
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('late_fee Updated Successfully')));
        Fluttertoast.showToast(msg: 'Late Fee updated successfully');
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('Failed to Update Surcharge')));
        Fluttertoast.showToast(msg: 'Failed to Update Late Fee');
      }
    } catch (e) {
      print('Failed to update Late Fee data: $e');
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text('Error: $e')));
      Fluttertoast.showToast(msg: 'Error: $e');
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

          // Store original values for change tracking
          _originalDurationMail = latefee.duration?.toString() ?? "";
          _originalRentDueReminderEmail = latefee.remindermail ?? false;
          // Note: replyToEmail is not in Setting3 API response, track from current value
          _originalReplyToEmail = replyToEmail.text.trim();
        });
      }
    } catch (e) {
      print('Failed to load surcharge data: $e');
    }
  }

  Map<String, dynamic>? chargesetting;

  void loadChargeSetting() async {
    Map<String, dynamic>? chargeData = await fetchChargeSetting();
    if (chargeData != null) {
      print("Charge Settings: $chargeData");
      bool unbundle = chargeData["unbundle_charges"] ?? false;
      print("Unbundle charges: $unbundle");
      setState(() {
        chargesetting = chargeData;
      });
    }
  }

  //mail Services
  Future<Map<String, dynamic>?> fetchChargeSetting() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = await _getApiId(); // Use helper method to get correct ID
      String? token = prefs.getString('token');
      String? adminid = prefs.getString("adminId");

      if (id == null || token == null) {
        throw Exception("Missing ID or token in SharedPreferences");
      }

      final response = await http.get(
        Uri.parse('$Api_url/api/charge-setting/$adminid'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );

      final responseData = jsonDecode(response.body);

      if (responseData["statusCode"] == 200) {
        Map<String, dynamic> data = responseData["data"];
        return data; // returning as a Map<String, dynamic>
      } else {
        throw Exception('Failed to load charge data');
      }
    } catch (e) {
      print('Failed to load charge data: $e');
      return null;
    }
  }

  Future<void> updateMail() async {
    // Check if there are any changes before proceeding
    if (!_hasMailServiceChanges()) {
      return; // No changes made, don't proceed with update
    }

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
        "replyToEmail": replyToEmail.text.trim(),
      };

      bool success = await mailrepository.updateMailData(data);

      if (success) {
        // Update original values after successful save
        setState(() {
          _originalReplyToEmail = replyToEmail.text.trim();
          _originalDurationMail = durationmail.text.trim();
          _originalRentDueReminderEmail = rentDueReminderEmail;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('mail Updated Successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to Update mail')));
      }
    } catch (e) {
      print('Failed to update mail data: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<bool> AddChargeSettingData(id, Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? adminId = prefs.getString('adminId');
    String? staffid = prefs.getString("staff_id");

    String? id = (staffid != null && staffid.isNotEmpty) ? staffid : adminId;
    print("id of id 1 $id");

    print(data);
    final response = await http.post(
      Uri.parse('$Api_url/api/charge-setting'),
      headers: {
        "authorization": "CRM $token",
        'Content-Type': 'application/json',
        "id": "CRM $id",
      },
      body: jsonEncode(data),
    );
    print(response.body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData["statusCode"] == 200) {
        // Show success message
        Fluttertoast.showToast(
            msg: responseData["message"] ??
                "Charge Setting updated successfully");
        return true;
      } else {
        // Show error message from API
        Fluttertoast.showToast(
            msg: responseData["message"] ?? "Failed to update charge setting");
        return false;
      }
    } else {
      // Show error message for HTTP error
      Fluttertoast.showToast(msg: "Failed to update charge setting");
      return false;
    }
  }

  Future<void> Addmail() async {
    // Check if there are any changes before proceeding
    if (!_hasMailServiceChanges()) {
      return; // No changes made, don't proceed with add
    }

    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    try {
      Map<String, dynamic> data = {
        "admin_id": id,
        "replyToEmail": replyToEmail.text.trim(),
        "duration": durationmail.text.trim().isNotEmpty
            ? int.parse(durationmail.text.trim())
            : null,
      };

      bool success = await mailrepository.AddMailData(id, data);

      if (success) {
        // After successful add, fetch the data to get the updated values and update original values
        await fetchMailData();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('mail Updated Successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to Update ,ail')));
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
          color: const Color(0xFFF4F8FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDBE0E5))),
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
                        ? Text("Account",
                            style: TextStyle(
                                color: blueColor, fontWeight: FontWeight.bold))
                        : Text("Account",
                            style: TextStyle(
                                color: blueColor, fontWeight: FontWeight.bold)),
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
                child: Row(
                  children: [
                    Text("    Type",
                        style: TextStyle(
                            color: blueColor, fontWeight: FontWeight.bold)),
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
                    Text("Fund Type",
                        style: TextStyle(
                            color: blueColor, fontWeight: FontWeight.bold)),
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
  int timeformateselect = 0;
  int? expandedIndex;
  Set<int> expandedIndices = {};
  String? dateformate1;
  String? dateformate2;
  String? dateformate3;
  String? customdate;
  String? timeformate1;
  String? timeformate2;
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
                  _showEditAccount(context, data);
                },
                child: const FaIcon(
                  FontAwesomeIcons.edit,
                  size: 30,
                  color: Colors.green,
                ),
              ),
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
  final List<String> _status = [
    'New',
    'In Progress',
    'On Hold',
    'Completed',
    'Closed'
  ];
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
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');
    String? staffid = prefs.getString("staff_id");

    String? id = (staffid != null && staffid.isNotEmpty) ? staffid : adminId;
    print("id of id 1 $id");

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
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');
    String? staffid = prefs.getString("staff_id");

    String? id = (staffid != null && staffid.isNotEmpty) ? staffid : adminId;
    print("id of id 1 $id");
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
    String? adminid = prefs.getString("adminId");
    String? token = prefs.getString('token');
    String? staffid = prefs.getString("staff_id");
    String? id = (staffid != null && staffid.isNotEmpty) ? staffid : adminid;
    setState(() {
      _isLoadingvendors = true;
    });
    try {
      final response = await http
          .get(Uri.parse('${Api_url}/api/vendor/vendors/$adminid'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      });
      print('${Api_url}/api/vendor/vendors/$adminid');

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> names = {};
        jsonResponse.forEach((data) {
          names[data['vendor_id'].toString()] = data['vendor_name'].toString();
        });

        setState(() {
          // Sort vendors alphabetically by name (values)
          var sortedEntries = names.entries.toList()
            ..sort((a, b) =>
                a.value.toLowerCase().compareTo(b.value.toLowerCase()));
          vendors = Map.fromEntries(sortedEntries);
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
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');
    String? staffid = prefs.getString("staff_id");

    String? id = (staffid != null && staffid.isNotEmpty) ? staffid : adminId;
    print("id of id 1 $id");

    setState(() {
      _isLoadingstaff = true;
    });
    try {
      final response = await http.get(
          Uri.parse('${Api_url}/api/staffmember/staff_member/$adminId'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
          });
      print('${Api_url}/api/staffmember/staff_member/$adminId');

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> staffnames = {};
        jsonResponse.forEach((data) {
          staffnames[data['staffmember_id'].toString()] =
              data['staffmember_name'].toString();
        });

        setState(() {
          // Sort staff alphabetically by name (values)
          var sortedEntries = staffnames.entries.toList()
            ..sort((a, b) =>
                a.value.toLowerCase().compareTo(b.value.toLowerCase()));
          staffs = Map.fromEntries(sortedEntries);
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
    String? adminId = prefs.getString('adminId');
    String? staffid = prefs.getString("staff_id");

    String? id = (staffid != null && staffid.isNotEmpty) ? staffid : adminId;
    print("id of id 1 $id");

    // Ensure a category is selected
    if (_selectedDropdownCategory == null ||
        _selectedDropdownCategory?.categoryId == null) {
      Fluttertoast.showToast(msg: "Please select a category");
      setState(() {
        isloading = false;
      });
      return;
    }

    print(
        "Sending categoryId: " + (_selectedDropdownCategory?.categoryId ?? ""));
    print(
        'Selected category for update: ${_selectedDropdownCategory?.name} (${_selectedDropdownCategory?.categoryId})');

    final url = '${Api_url}/api/work-order/work-defaults';
    final headers = {
      "authorization": "CRM $token",
      "id": "CRM $id",
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final body = json.encode({
      "admin_id": adminId,
      "category": _selectedDropdownCategory?.categoryId, // Send category_id
      "entry_allowed": _selectedEntry == 'yes',
      "staffmember_id": _selectedstaffId,
      "vendor_id": _selectedvendorsId,
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      var responseData = json.decode(response.body);
      print('add and update workorder  \\${responseData}');
      print('add workorder  \\${response.body}');
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
    String? adminId = prefs.getString("adminId");
    String? staffid = prefs.getString("staff_id");

    String? id = (staffid != null && staffid.isNotEmpty) ? staffid : adminId;
    print("id of id 1 $id");
    try {
      WorkOrderModel.Data workorder = await fetchWorkOrderSetting();
      String? entryAllowedString;
      if (workorder.workDefaults?.entryAllowed != null) {
        entryAllowedString =
            workorder.workDefaults!.entryAllowed! ? 'Yes' : 'No';
      }
      if (workorder != null) {
        // Get category_id from workDefaults.category
        String? fetchedCategoryId = workorder.workDefaults?.category;
        print("Fetched category_id from workDefaults: " +
            (fetchedCategoryId ?? "null"));
        setState(() {
          _selectedvendorsId = workorder.workDefaults?.vendorId?.isEmpty ?? true
              ? null
              : workorder.workDefaults?.vendorId;
          _selectedstaffId =
              workorder.workDefaults?.staffmemberId?.isEmpty ?? true
                  ? null
                  : workorder.workDefaults?.staffmemberId;
          _selectedEntry = entryAllowedString;
          // Set the dropdown value by matching the ID
          if (fetchedCategoryId != null && _dropdownCategories.isNotEmpty) {
            final match = _dropdownCategories
                .where((cat) => cat.categoryId == fetchedCategoryId)
                .toList();
            if (match.length == 1) {
              _selectedDropdownCategory = match.first;
            } else {
              _selectedDropdownCategory = null;
            }
          } else {
            _selectedDropdownCategory = null;
          }
        });
      }
    } catch (e) {
      print('Failed to load workorder data: $e');
    }
  }

  // Fetch workorder notification settings
  Future<void> fetchWorkOrderNotificationSettings() async {
    // Don't set loading state - fetch in background
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? adminId = prefs.getString('adminId');
    String? staffid = prefs.getString("staff_id");

    if (adminId == null || adminId.isEmpty) {
      print('Admin ID is null or empty');
      return;
    }

    String? id = (staffid != null && staffid.isNotEmpty) ? staffid : adminId;

    final url =
        '${Api_url}/api/workorder-settings/workorder-notification/$adminId';
    final headers = {
      "authorization": "CRM $token",
      "id": "CRM $id",
      'Content-Type': 'application/json; charset=UTF-8',
    };

    print('Fetching notification settings from: $url');
    print('Admin ID: $adminId');

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        if (responseData["statusCode"] == 200) {
          // Check if data exists
          if (responseData["data"] != null) {
            var data = responseData["data"];
            print('Notification settings data: $data');
            setState(() {
              createAdmin = data["create_admin"] ?? false;
              createAssignee = data["create_assignee"] ?? false;
              createTenant = data["create_tenant"] ?? false;
              updateAdmin = data["update_admin"] ?? false;
              updateAssignee = data["update_assignee"] ?? false;
              updateTenant = data["update_tenant"] ?? false;
              completeAdmin = data["complete_admin"] ?? false;
              completeAssignee = data["complete_assignee"] ?? false;
              completeTenant = data["complete_tenant"] ?? false;
            });
            print('Settings loaded successfully');
            print(
                'Create - Admin: $createAdmin, Assignee: $createAssignee, Tenant: $createTenant');
            print(
                'Update - Admin: $updateAdmin, Assignee: $updateAssignee, Tenant: $updateTenant');
            print(
                'Complete - Admin: $completeAdmin, Assignee: $completeAssignee, Tenant: $completeTenant');
            setState(() {
              _hasLoadedNotifications = true; // Mark as loaded
            });
          } else {
            print('No data in response, using default values');
            // Set default values if no data exists (first time setup)
            setState(() {
              createAdmin = false;
              createAssignee = false;
              createTenant = false;
              updateAdmin = false;
              updateAssignee = false;
              updateTenant = false;
              completeAdmin = false;
              completeAssignee = false;
              completeTenant = false;
              _hasLoadedNotifications =
                  true; // Mark as loaded even with defaults
            });
          }
        } else {
          print('API returned error statusCode: ${responseData["statusCode"]}');
          print('Message: ${responseData["message"] ?? "No message"}');
        }
      } else if (response.statusCode == 404) {
        print('Settings not found (404), using default values');
        // First time - no settings exist yet, use defaults
        setState(() {
          createAdmin = false;
          createAssignee = false;
          createTenant = false;
          updateAdmin = false;
          updateAssignee = false;
          updateTenant = false;
          completeAdmin = false;
          completeAssignee = false;
          completeTenant = false;
          _hasLoadedNotifications = true; // Mark as loaded even with defaults
        });
      } else {
        print('API returned error status: ${response.statusCode}');
        var errorBody = response.body;
        print('Error response: $errorBody');
        Fluttertoast.showToast(
            msg:
                'Failed to load notification settings: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception loading workorder notification settings: $e');
      print('Stack trace: ${StackTrace.current}');
      Fluttertoast.showToast(msg: 'Failed to load notification settings: $e');
    }
  }

  // Save workorder notification settings
  Future<void> saveWorkOrderNotificationSettings() async {
    setState(() {
      isSavingNotifications = true; // Use separate saving state
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? adminId = prefs.getString('adminId');
    String? staffid = prefs.getString("staff_id");

    String? id = (staffid != null && staffid.isNotEmpty) ? staffid : adminId;

    final url = '${Api_url}/api/workorder-settings/workorder-notification';
    final headers = {
      "authorization": "CRM $token",
      "id": "CRM $id",
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final body = json.encode({
      "admin_id": adminId,
      "create_admin": createAdmin,
      "create_assignee": createAssignee,
      "create_tenant": createTenant,
      "update_admin": updateAdmin,
      "update_assignee": updateAssignee,
      "update_tenant": updateTenant,
      "complete_admin": completeAdmin,
      "complete_assignee": completeAssignee,
      "complete_tenant": completeTenant,
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      var responseData = json.decode(response.body);

      if (responseData["statusCode"] == 200) {
        Fluttertoast.showToast(
            msg: responseData["message"] ?? "Settings saved");
      } else {
        Fluttertoast.showToast(
            msg: responseData["message"] ?? "Failed to save settings");
      }
    } catch (error) {
      print('Error saving notification settings: $error');
      Fluttertoast.showToast(msg: 'An error occurred while saving settings');
    } finally {
      setState(() {
        isSavingNotifications = false; // Use separate saving state
      });
    }
  }

  //for date formate
  Future<void> updateDateFormat(String format, String adminId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? adminId = prefs.getString('adminId');
    String? staffid = prefs.getString("staff_id");

    String? id = (staffid != null && staffid.isNotEmpty) ? staffid : adminId;
    print("id of id 1 $id");
    final url = Uri.parse('${Api_url}/api/themes/date-format');
    final response = await http.post(
      url,
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
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
  bool _isStaff = false;
  bool _isInitialized = false;
  _checkUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? staffid = prefs.getString("staff_id");
    String? adminId = prefs.getString('adminId');
    String? id = (staffid != null && staffid.isNotEmpty) ? staffid : adminId;
    print("id of id 1 staff $id");

    setState(() {
      _isStaff = (staffid != null && staffid.isNotEmpty);
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    //dateProvider.loadDateFormat();
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        //appBar: widget_302.App_Bar(context: context, isSettingPageActive: true),
        appBar: !_isInitialized
            ? widget_302.App_Bar(context: context, isSettingPageActive: true)
            : (_isStaff
                ? widget_302_Staff.widget_302_Staff.App_Bar(context: context)
                : widget_302.App_Bar(
                    context: context, isSettingPageActive: true)),
        backgroundColor: Colors.white,
        drawer: !_isInitialized
            ? CustomDrawer(
                currentpage: "Settings",
                dropdown: false,
              )
            : (_isStaff
                ? CustomDrawerStaff(
                    currentpage: "Settings",
                    dropdown: true,
                  )
                : CustomDrawer(
                    currentpage: "Settings",
                    dropdown: false,
                  )),
        // drawer:
        // CustomDrawer(
        //   currentpage: "Settings",
        //   dropdown: false,
        // ),
        body: _connectivityResult != ConnectivityResult.none
            ? ListView(children: [
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: Container(
                      height: MediaQuery.of(context).size.width < 500 ? 45 : 55,
                      padding: const EdgeInsets.only(top: 10, left: 10),
                      width: MediaQuery.of(context).size.width * .91,
                      margin: const EdgeInsets.only(bottom: 6.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: blueColor,
                        boxShadow: [
                          const BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 1.0),
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: Text(
                        "Settings ",
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
                const SizedBox(
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
                                      issurge = false;
                                      ismail = false;
                                      isaccounts = true;
                                      islatefee = false;
                                      isdateformate = false;
                                      ismanagetemplate = false;
                                      isworkorder = false;
                                      ischargesetting = false;
                                      iscategories = false;
                                      isvendor = false;
                                      ispropertyowner = false;
                                      ispropertytype = false;
                                    });
                                  },
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.width < 500
                                            ? 40
                                            : 50,
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
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      issurge = false;
                                      ismail = false;
                                      isaccounts = false;
                                      isworkorder = false;
                                      iscategories = true;
                                      islatefee = false;
                                      isdateformate = false;
                                      ischargesetting = false;
                                      ismanagetemplate = false;
                                      isvendor = false;
                                      ispropertyowner = false;
                                      ispropertytype = false;
                                    });
                                  },
                                  child: Visibility(
                                    visible: true,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: blueColor),
                                        color: !iscategories
                                            ? Colors.white
                                            : blueColor,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Categories",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: iscategories
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
                        const SizedBox(
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
                                      ismail = false;
                                      ischargesetting = true;
                                      ismanagetemplate = false;
                                      islatefee = false;
                                      isaccounts = false;
                                      isdateformate = false;
                                      isworkorder = false;
                                      iscategories = false;
                                      isvendor = false;
                                      ispropertyowner = false;
                                      ispropertytype = false;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: blueColor),
                                      color: !ischargesetting
                                          ? Colors.white
                                          : blueColor,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Charges",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ischargesetting
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
                              const SizedBox(
                                width: 10,
                              ),
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
                                      ispropertyowner = false;
                                      ispropertytype = false;
                                      ischargesetting = false;
                                      iscategories = false;
                                      isvendor = false;
                                      DateTime now = DateTime.now();
                                      dateformateselect =
                                          dateProvider.dateformateselect;
                                      timeformateselect =
                                          dateProvider.timeformateselect;
                                      dateformate1 =
                                          DateFormat('MM/dd/yyyy').format(now);
                                      dateformate2 =
                                          DateFormat('yyyy-MM-dd').format(now);
                                      dateformate3 =
                                          DateFormat('yyyy-MMM-dd').format(now);
                                      timeformate1 =
                                          DateFormat('HH:mm:ss').format(now);
                                      timeformate2 =
                                          DateFormat('h:mm:ss a').format(now);
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
                            ],
                          ),
                        ),
                        const SizedBox(
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
                                  onTap: () async {
                                    setState(() {
                                      issurge = false;
                                      ismail = false;
                                      isaccounts = false;
                                      isdateformate = false;
                                      islatefee = true;
                                      isworkorder = false;
                                      ismanagetemplate = false;
                                      ischargesetting = false;
                                      iscategories = false;
                                      isvendor = false;
                                      ispropertyowner = false;
                                      ispropertytype = false;
                                    });
                                    await fetchAccountsData();
                                    await fetchlatefeeData();
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
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      issurge = false;
                                      isaccounts = false;
                                      ismail = true;
                                      islatefee = false;
                                      isdateformate = false;
                                      ismanagetemplate = false;
                                      isworkorder = false;
                                      ischargesetting = false;
                                      iscategories = false;
                                      isvendor = false;
                                      ispropertyowner = false;
                                      ispropertytype = false;
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
                            ],
                          ),
                        ),
                        const SizedBox(
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
                                      ischargesetting = false;
                                      ismail = false;
                                      isdateformate = false;
                                      islatefee = false;
                                      isworkorder = false;
                                      ismanagetemplate = true;
                                      ispropertyowner = false;
                                      ispropertytype = false;
                                      iscategories = false;
                                      isvendor = false;
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
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      issurge = false;
                                      ismail = false;
                                      isaccounts = false;
                                      isworkorder = false;
                                      iscategories = false;
                                      islatefee = false;
                                      isdateformate = false;
                                      ischargesetting = false;
                                      ismanagetemplate = false;
                                      isvendor = false;
                                      ispropertytype = false;
                                      ispropertyowner = true;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: blueColor),
                                      color: !ispropertyowner
                                          ? Colors.white
                                          : blueColor,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Property Owners",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ispropertyowner
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
                        const SizedBox(
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
                                      ismail = false;
                                      isaccounts = false;
                                      isworkorder = false;
                                      iscategories = false;
                                      islatefee = false;
                                      isdateformate = false;
                                      ischargesetting = false;
                                      ismanagetemplate = false;
                                      isvendor = false;
                                      ispropertyowner = false;
                                      ispropertytype = true;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: blueColor),
                                      color: !ispropertytype
                                          ? Colors.white
                                          : blueColor,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Property Type",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ispropertytype
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
                              const SizedBox(
                                width: 10,
                              ),
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
                                      ischargesetting = false;
                                      iscategories = false;
                                      isvendor = false;
                                      ispropertyowner = false;
                                      ispropertytype = false;
                                    });
                                  },
                                  child: Container(
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
                            ],
                          ),
                        ),
                        const SizedBox(
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
                                      ismail = false;
                                      isaccounts = false;
                                      isworkorder = false;
                                      iscategories = false;
                                      islatefee = false;
                                      isdateformate = false;
                                      ischargesetting = false;
                                      ismanagetemplate = false;
                                      ispropertyowner = false;
                                      ispropertytype = false;
                                      isvendor = true;
                                      ispropertyowner = false;
                                      ispropertytype = false;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: blueColor),
                                      color:
                                          !isvendor ? Colors.white : blueColor,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Vendor",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isvendor
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
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    setState(() {
                                      issurge = false;
                                      ismail = false;
                                      isaccounts = false;
                                      isworkorder = true;
                                      islatefee = false;
                                      isdateformate = false;
                                      ischargesetting = false;
                                      ismanagetemplate = false;
                                      iscategories = false;
                                      isvendor = false;
                                      ispropertyowner = false;
                                      ispropertytype = false;
                                      // Don't set loading state - show table immediately
                                    });
                                    await _loadDropdownCategories(); // Always fetch latest categories from backend
                                    await fetchWorkData(); // Fetch work order settings after categories are loaded
                                    // Fetch notification settings in background without showing loading
                                    fetchWorkOrderNotificationSettings(); // Fetch in background
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

                              // Spacer()
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Divider(
                          color: grey,
                        ),
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
                                          MediaQuery.of(context).size.width <
                                                  500
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
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
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
                                            const SizedBox(height: 8),
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
                                                          color: const Color(
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
                                                            const EdgeInsets
                                                                .all(13),
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
                                            const SizedBox(height: 8),
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
                                                          color: const Color(
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
                                                            const EdgeInsets
                                                                .all(13),
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
                                            const SizedBox(height: 8),
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
                                                            color: const Color(
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
                                                              const EdgeInsets
                                                                  .all(13),
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
                                            const SizedBox(height: 8),
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
                                                            color: const Color(
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
                                                              const EdgeInsets
                                                                  .all(13),
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
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
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
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const SizedBox(
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
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const SizedBox(width: 5),
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
                                                    color:
                                                        const Color(0xFF8A95A8),
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
                                                  suffixIcon: const Icon(
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
                                      const SizedBox(width: 190),
                                    if (MediaQuery.of(context).size.width > 500)
                                      const SizedBox(width: 380),
                                  ],
                                ),
                              ],
                              if (_selectedRadio == 2 ||
                                  _selectedRadio == 3) ...[
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const SizedBox(width: 5),
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
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const SizedBox(width: 5),
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
                                                    color:
                                                        const Color(0xFF8A95A8),
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
                                                  // suffixIcon: const Icon(
                                                  //   Icons.percent,
                                                  //   color: Color.fromRGBO(
                                                  //       21, 43, 81, 1),
                                                  //   size: 18,
                                                  // ),
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

                              Container(
                                width: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Text(
                                      "Account to receive surcharges",
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
                                    Container(
                                      height: 42,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String?>(
                                          value: selectedAccount != null &&
                                                  accounts.any((account) =>
                                                      account.accountId ==
                                                      selectedAccount)
                                              ? selectedAccount
                                              : null,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          hint: const Text(
                                            "Select Account",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          items:
                                              accounts.map((Setting4 account) {
                                            return DropdownMenuItem<String>(
                                              value: account
                                                  .accountId, // This must be unique (account ID)
                                              child: Text(account
                                                  .account!), // This is what the user sees (account name)
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedAccount =
                                                  newValue; // This stores the accountId (unique)
                                            });
                                            print(
                                                "Selected Account ID: $newValue");
                                            // Find the account name for the selected ID
                                            String? accountName = accounts
                                                .firstWhere((account) =>
                                                    account.accountId ==
                                                    newValue)
                                                .account;
                                            print(
                                                "Selected Account Name: $accountName");
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                                  const SizedBox(
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
                              const SizedBox(
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
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Add Your Reply to Address",
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 15
                                                : 20,
                                        color: blueColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width *
                                          .5,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: grey),
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
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
                                              cursorColor: const Color.fromRGBO(
                                                  21, 43, 81, 1),
                                              decoration: InputDecoration(
                                                hintText: "Enter email",
                                                hintStyle: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          .037,
                                                  color:
                                                      const Color(0xFF8A95A8),
                                                ),
                                                border: InputBorder.none,
                                                contentPadding:
                                                    const EdgeInsets.all(13),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 190),
                                ],
                              ),
                              const SizedBox(
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
                                                color: const Color(0xFF8A95A8),
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        const SizedBox(
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
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        const SizedBox(width: 5),
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
                                                    cursorColor:
                                                        const Color.fromRGBO(
                                                            21, 43, 81, 1),
                                                    decoration: InputDecoration(
                                                      // hintText: "Enter password",
                                                      hintStyle: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .037,
                                                        color: const Color(
                                                            0xFF8A95A8),
                                                      ),

                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          const EdgeInsets.all(
                                                              13),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 190),
                                      ],
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  if (MediaQuery.of(context).size.width < 500)
                                    const SizedBox(width: 2),
                                  if (MediaQuery.of(context).size.width > 500)
                                    const SizedBox(width: 2),
                                  GestureDetector(
                                    onTap: _hasMailServiceChanges()
                                        ? () async {
                                            if (mailupdate)
                                              await updateMail();
                                            else
                                              await Addmail();
                                          }
                                        : null,
                                    child: Opacity(
                                      opacity:
                                          _hasMailServiceChanges() ? 1.0 : 0.5,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: Container(
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
                                              : 150,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            color: blueColor,
                                            boxShadow: [
                                              const BoxShadow(
                                                color: Colors.grey,
                                                offset:
                                                    Offset(0.0, 1.0), //(x,y)
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
                                                  fontSize:
                                                      MediaQuery.of(context)
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
                                  ),
                                  const SizedBox(
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
                                          MediaQuery.of(context).size.width <
                                                  500
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
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
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
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Number Of Grace Period Days",
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
                                                    color:
                                                        const Color(0xFF8A95A8),
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
                                                  // suffixIcon: Icon(
                                                  //   Icons.percent,
                                                  //   color: blueColor,
                                                  //   size: 18,
                                                  // ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Late Fee Calculation",
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
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Row(
                                            children: [
                                              Radio<String>(
                                                value: "fixed",
                                                groupValue: calculationType,
                                                onChanged: (String? value) {
                                                  setState(() {
                                                    calculationType = value!;
                                                  });
                                                },
                                                activeColor: blueColor,
                                              ),
                                              Text(
                                                "Fixed",
                                                style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 14
                                                          : 16,
                                                  color: blueColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 20),
                                          Row(
                                            children: [
                                              Radio<String>(
                                                value: "percent",
                                                groupValue: calculationType,
                                                onChanged: (String? value) {
                                                  setState(() {
                                                    calculationType = value!;
                                                  });
                                                },
                                                activeColor: blueColor,
                                              ),
                                              Text(
                                                "Percent",
                                                style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 14
                                                          : 16,
                                                  color: blueColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
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
                                              calculationType == "fixed"
                                                  ? "Amount"
                                                  : "Percentage",
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
                                            const SizedBox(height: 5),
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
                                                      textAlign:
                                                          calculationType ==
                                                                  "fixed"
                                                              ? TextAlign.right
                                                              : TextAlign.left,
                                                      cursorColor: blueColor,
                                                      keyboardType: TextInputType
                                                          .numberWithOptions(
                                                              decimal: true),
                                                      decoration:
                                                          InputDecoration(
                                                        // hintText: "Enter password",
                                                        hintStyle: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .037,
                                                          color: const Color(
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
                                                            calculationType ==
                                                                    "fixed"
                                                                ? const EdgeInsets
                                                                    .only(
                                                                    left: 8,
                                                                    top: 13,
                                                                    bottom: 13,
                                                                    right: 13)
                                                                : const EdgeInsets
                                                                    .all(13),
                                                        prefixIcon:
                                                            calculationType ==
                                                                    "fixed"
                                                                ? Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            12,
                                                                        right:
                                                                            8),
                                                                    child:
                                                                        Center(
                                                                      widthFactor:
                                                                          1.0,
                                                                      child:
                                                                          Text(
                                                                        '\$',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              blueColor,
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : null,
                                                        prefixIconConstraints:
                                                            calculationType ==
                                                                    "fixed"
                                                                ? const BoxConstraints(
                                                                    minWidth:
                                                                        28,
                                                                    maxWidth:
                                                                        32)
                                                                : null,
                                                        suffixIcon:
                                                            calculationType ==
                                                                    "percent"
                                                                ? Icon(
                                                                    Icons
                                                                        .percent,
                                                                    color:
                                                                        blueColor,
                                                                    size: 18,
                                                                  )
                                                                : null,
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
                                              "Grace Balance",
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
                                            const SizedBox(height: 5),
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
                                                      controller: grace_balance,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          //  passworderror = false;
                                                        });
                                                      },
                                                      //  controller: password,
                                                      textAlign:
                                                          TextAlign.right,
                                                      keyboardType: TextInputType
                                                          .numberWithOptions(
                                                              decimal: true),
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
                                                          color: const Color(
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
                                                            const EdgeInsets
                                                                .only(
                                                                left: 8,
                                                                top: 13,
                                                                bottom: 13,
                                                                right: 13),
                                                        prefixIcon: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 12,
                                                                  right: 8),
                                                          child: Center(
                                                            widthFactor: 1.0,
                                                            child: Text(
                                                              '\$',
                                                              style: TextStyle(
                                                                color:
                                                                    blueColor,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        prefixIconConstraints:
                                                            const BoxConstraints(
                                                                minWidth: 28,
                                                                maxWidth: 32),
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
                                              calculationType == "fixed"
                                                  ? "Amount"
                                                  : "Percentage",
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 15
                                                          : 20,
                                                  color:
                                                      const Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 5),
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
                                                        textAlign:
                                                            calculationType ==
                                                                    "fixed"
                                                                ? TextAlign
                                                                    .right
                                                                : TextAlign
                                                                    .left,
                                                        cursorColor: blueColor,
                                                        keyboardType: TextInputType
                                                            .numberWithOptions(
                                                                decimal: true),
                                                        decoration:
                                                            InputDecoration(
                                                          // hintText: "Enter password",
                                                          hintStyle: TextStyle(
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .037,
                                                            color: const Color(
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
                                                              calculationType ==
                                                                      "fixed"
                                                                  ? const EdgeInsets
                                                                      .only(
                                                                      left: 8,
                                                                      top: 13,
                                                                      bottom:
                                                                          13,
                                                                      right: 13)
                                                                  : const EdgeInsets
                                                                      .all(13),
                                                          prefixIcon:
                                                              calculationType ==
                                                                      "fixed"
                                                                  ? Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              12,
                                                                          right:
                                                                              8),
                                                                      child:
                                                                          Center(
                                                                        widthFactor:
                                                                            1.0,
                                                                        child:
                                                                            Text(
                                                                          '\$',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                blueColor,
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : null,
                                                          prefixIconConstraints:
                                                              calculationType ==
                                                                      "fixed"
                                                                  ? const BoxConstraints(
                                                                      minWidth:
                                                                          28,
                                                                      maxWidth:
                                                                          32)
                                                                  : null,
                                                          suffixIcon:
                                                              calculationType ==
                                                                      "percent"
                                                                  ? Icon(
                                                                      Icons
                                                                          .percent,
                                                                      color:
                                                                          blueColor,
                                                                      size: 18,
                                                                    )
                                                                  : null,
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
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 15
                                                          : 20,
                                                  color:
                                                      const Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 5),
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
                                                            color: const Color(
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
                                                              const EdgeInsets
                                                                  .all(13),
                                                          // suffixIcon: Icon(
                                                          //   Icons.percent,
                                                          //   color: blueColor,
                                                          //   size: 18,
                                                          // ),
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
                              const SizedBox(height: 15),
                              // Account Dropdown
                              if (MediaQuery.of(context).size.width < 500)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Charge Account",
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
                                      DropdownButtonHideUnderline(
                                        child: Material(
                                          elevation: 3,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: DropdownButton2<String>(
                                            isExpanded: true,
                                            hint: Row(
                                              children: [
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    'Select Account',
                                                    style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 16,
                                                      color: const Color(
                                                          0xFF8A95A8),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            items: [
                                              // Combine "Late Fee Income" with accounts and sort alphabetically
                                              ...([
                                                "Late Fee Income",
                                                ...accounts
                                                    .map((a) => a.account ?? '')
                                                    .where((a) => a.isNotEmpty)
                                              ]..sort((a, b) => a
                                                      .toLowerCase()
                                                      .compareTo(
                                                          b.toLowerCase())))
                                                  .map((String accountName) {
                                                return DropdownMenuItem<String>(
                                                  value: accountName,
                                                  child: Text(
                                                    accountName,
                                                    style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                );
                                              }).toList(),
                                            ],
                                            value:
                                                selectedAccountName.isNotEmpty
                                                    ? selectedAccountName
                                                    : null,
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                selectedAccountName =
                                                    newValue ?? '';
                                                // Handle static "Late Fee Income" option
                                                if (newValue ==
                                                    "Late Fee Income") {
                                                  selectedAccountId = "";
                                                } else {
                                                  // Find the account ID for the selected account
                                                  Setting4? selectedAccount =
                                                      accounts.firstWhere(
                                                    (account) =>
                                                        account.account ==
                                                        newValue,
                                                    orElse: () => Setting4(),
                                                  );
                                                  selectedAccountId =
                                                      selectedAccount
                                                              .accountId ??
                                                          '';
                                                }
                                              });
                                            },
                                            buttonStyleData: ButtonStyleData(
                                              height: 50,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .98, // Leave small margin
                                              padding: const EdgeInsets.only(
                                                  left: 14, right: 14),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color:
                                                      const Color(0xFF8A95A8),
                                                ),
                                                color: Colors.white,
                                              ),
                                              elevation: 0,
                                            ),
                                            dropdownStyleData:
                                                DropdownStyleData(
                                              maxHeight: 250,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .98, // Match button width
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                color: Colors.white,
                                              ),
                                              offset: const Offset(-2, 0),
                                              scrollbarTheme:
                                                  ScrollbarThemeData(
                                                radius:
                                                    const Radius.circular(40),
                                                thickness:
                                                    MaterialStateProperty.all(
                                                        6),
                                                thumbVisibility:
                                                    MaterialStateProperty.all(
                                                        true),
                                                thumbColor:
                                                    MaterialStateProperty.all(
                                                        Colors.grey.shade400),
                                                trackColor:
                                                    MaterialStateProperty.all(
                                                        Colors.grey.shade100),
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
                                      ),
                                    ],
                                  ),
                                ),
                              if (MediaQuery.of(context).size.width > 500)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Charge Account",
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
                                      DropdownButtonHideUnderline(
                                        child: Material(
                                          elevation: 3,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: DropdownButton2<String>(
                                            isExpanded: true,
                                            hint: Row(
                                              children: [
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    'Select Account',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: const Color(
                                                          0xFF8A95A8),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            items: [
                                              // Combine "Late Fee Income" with accounts and sort alphabetically
                                              ...([
                                                "Late Fee Income",
                                                ...accounts
                                                    .map((a) => a.account ?? '')
                                                    .where((a) => a.isNotEmpty)
                                              ]..sort((a, b) => a
                                                      .toLowerCase()
                                                      .compareTo(
                                                          b.toLowerCase())))
                                                  .map((String accountName) {
                                                return DropdownMenuItem<String>(
                                                  value: accountName,
                                                  child: Text(
                                                    accountName,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                );
                                              }).toList(),
                                            ],
                                            value:
                                                selectedAccountName.isNotEmpty
                                                    ? selectedAccountName
                                                    : null,
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                selectedAccountName =
                                                    newValue ?? '';
                                                // Handle static "Late Fee Income" option
                                                if (newValue ==
                                                    "Late Fee Income") {
                                                  selectedAccountId = "";
                                                } else {
                                                  // Find the account ID for the selected account
                                                  Setting4? selectedAccount =
                                                      accounts.firstWhere(
                                                    (account) =>
                                                        account.account ==
                                                        newValue,
                                                    orElse: () => Setting4(),
                                                  );
                                                  selectedAccountId =
                                                      selectedAccount
                                                              .accountId ??
                                                          '';
                                                }
                                              });
                                            },
                                            buttonStyleData: ButtonStyleData(
                                              height: 50,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .6,
                                              padding: const EdgeInsets.only(
                                                  left: 14, right: 14),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color:
                                                      const Color(0xFF8A95A8),
                                                ),
                                                color: Colors.white,
                                              ),
                                              elevation: 0,
                                            ),
                                            dropdownStyleData:
                                                DropdownStyleData(
                                              maxHeight: 250,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .6, // Match button width
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                color: Colors.white,
                                              ),
                                              offset: const Offset(0, 0),
                                              scrollbarTheme:
                                                  ScrollbarThemeData(
                                                radius:
                                                    const Radius.circular(40),
                                                thickness:
                                                    MaterialStateProperty.all(
                                                        6),
                                                thumbVisibility:
                                                    MaterialStateProperty.all(
                                                        true),
                                                thumbColor:
                                                    MaterialStateProperty.all(
                                                        Colors.grey.shade400),
                                                trackColor:
                                                    MaterialStateProperty.all(
                                                        Colors.grey.shade100),
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
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 15),
                              // Description Field
                              if (MediaQuery.of(context).size.width < 500)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Description",
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
                                            MediaQuery.of(context).size.width,
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
                                                controller: description,
                                                onChanged: (value) {
                                                  setState(() {
                                                    //  passworderror = false;
                                                  });
                                                },
                                                cursorColor: blueColor,
                                                decoration: InputDecoration(
                                                  hintStyle: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .037,
                                                    color:
                                                        const Color(0xFF8A95A8),
                                                  ),
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      const EdgeInsets.all(13),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (MediaQuery.of(context).size.width > 500)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Description",
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
                                                  controller: description,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      //  passworderror = false;
                                                    });
                                                  },
                                                  cursorColor: blueColor,
                                                  decoration: InputDecoration(
                                                    hintStyle: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .037,
                                                      color: const Color(
                                                          0xFF8A95A8),
                                                    ),
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            13),
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
                              const SizedBox(height: 30),
                              Row(
                                children: [
                                  if (MediaQuery.of(context).size.width < 500)
                                    const SizedBox(width: 2),
                                  if (MediaQuery.of(context).size.width > 500)
                                    const SizedBox(width: 2),
                                  GestureDetector(
                                    onTap: _hasLateFeeChanges()
                                        ? () async {
                                            if (islatefeeupdate)
                                              await updateLatefee();
                                            else
                                              await AddLatefeedata();
                                          }
                                        : null,
                                    child: Opacity(
                                      opacity: _hasLateFeeChanges() ? 1.0 : 0.5,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: Container(
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
                                              : 150,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            color: blueColor,
                                            boxShadow: [
                                              const BoxShadow(
                                                color: Colors.grey,
                                                offset:
                                                    Offset(0.0, 1.0), //(x,y)
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
                                                  fontSize:
                                                      MediaQuery.of(context)
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
                              const SizedBox(height: 15),
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
                                  const Spacer(),
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
                                                const SizedBox(
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
                                              const SizedBox(height: 10),
                                              _buildHeaders(),
                                              const SizedBox(height: 10),
                                              Container(
                                                // decoration: BoxDecoration(
                                                //   border: Border.all(
                                                //       color: Color.fromRGBO(
                                                //           152, 162, 179, .5)),
                                                // ),
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
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 6),
                                                      decoration: BoxDecoration(
                                                        color: index % 2 != 0
                                                            ? const Color(
                                                                0xFFF4F8FF)
                                                            : Colors.white,
                                                        border: Border.all(
                                                            color: const Color(
                                                                0xFFDBE0E5)),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
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
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              5,
                                                                          right:
                                                                              5),
                                                                      padding: !isExpanded
                                                                          ? const EdgeInsets
                                                                              .only(
                                                                              bottom:
                                                                                  10)
                                                                          : const EdgeInsets
                                                                              .only(
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
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 2,
                                                                      right: 2),
                                                              margin:
                                                                  const EdgeInsets
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
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          GestureDetector(
                                                                            onTap:
                                                                                () async {
                                                                              _showEditAccount(context, account);
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              height: 35,
                                                                              width: 35,
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.green.shade50,
                                                                                borderRadius: BorderRadius.circular(8),
                                                                              ),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  FaIcon(
                                                                                    FontAwesomeIcons.edit,
                                                                                    size: 15,
                                                                                    color: Colors.green,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              width: 10),
                                                                          GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              _showDeleteAlert(context, account.accountId!);
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              height: 35,
                                                                              width: 35,
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.red.shade50,
                                                                                borderRadius: BorderRadius.circular(8),
                                                                              ),
                                                                              child: const Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  FaIcon(
                                                                                    FontAwesomeIcons.trashCan,
                                                                                    size: 15,
                                                                                    color: Colors.red,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 10),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              10),
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
                                                              const EdgeInsets
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
                                                      decoration:
                                                          const BoxDecoration(
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
                                                            left: const BorderSide(
                                                                color: Color
                                                                    .fromRGBO(
                                                                        21,
                                                                        43,
                                                                        81,
                                                                        1)),
                                                            right:
                                                                const BorderSide(
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1)),
                                                            top: const BorderSide(
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
                                                                ? const BorderSide(
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
                        if (isdateformate)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 15),
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
                                  const Spacer(),
                                ],
                              ),
                              const SizedBox(height: 15),
                              // Row(
                              //   children: [
                              //     Text(
                              //       "Current Date Format :- dd-mm-yyyy",
                              //       style: TextStyle(
                              //         fontWeight: FontWeight.normal,
                              //         color: blueColor,
                              //         fontSize:
                              //             MediaQuery.of(context).size.width <
                              //                     500
                              //                 ? 16
                              //                 : 25,
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // SizedBox(height: 15),
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
                              const SizedBox(height: 10),
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
                                                          .updateDateFormatLocally(
                                                              'MM/dd/yyyy',
                                                              value);
                                                      dateformateselect =
                                                          value!;
                                                    });
                                                  })),
                                          const Text(
                                            "MM/DD/YYYY",
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
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
                                                const EdgeInsets.symmetric(
                                                    horizontal: 15),
                                            border: const OutlineInputBorder(),
                                            filled: true,
                                            fillColor: Colors.grey.shade200,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
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
                                                          .updateDateFormatLocally(
                                                              'yyyy-MM-dd',
                                                              value);
                                                      dateformateselect =
                                                          value!;
                                                    });
                                                  })),
                                          const Text(
                                            "YYYY-MM-DD",
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
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
                                                const EdgeInsets.symmetric(
                                                    horizontal: 15),
                                            border: const OutlineInputBorder(),
                                            filled: true,
                                            fillColor: Colors.grey.shade200,
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(
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
                                                          .updateDateFormatLocally(
                                                              'yyyy-MMM-dd',
                                                              value);
                                                      dateformateselect =
                                                          value!;
                                                    });
                                                  })),
                                          const Text(
                                            "YYYY-MMM-DD",
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
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
                                                const EdgeInsets.symmetric(
                                                    horizontal: 15),
                                            border: const OutlineInputBorder(),
                                            filled: true,
                                            fillColor: Colors.grey.shade200,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
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
                                                      customdate =
                                                          ""; // Clear the custom date format when switched to custom
                                                      _customDateController
                                                          .text = "";
                                                    });
                                                  })),
                                          const Text(
                                            "Custom",
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
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
                                          initialValue: customdate != null
                                              ? customdate
                                              : dateProvider.dateFormat
                                                      .toUpperCase() ??
                                                  "",
                                          enabled: dateformateselect == 3,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 15),
                                            border: const OutlineInputBorder(),
                                            filled: dateformateselect != 3,
                                            fillColor: Colors.grey.shade200,
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 30),
                                  Text(
                                    "Select Time Format",
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
                                  const SizedBox(height: 15),
                                  Column(
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                                      groupValue:
                                                          timeformateselect,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          dateProvider
                                                              .updateTimeFormat(
                                                                  '24', value);
                                                          timeformateselect =
                                                              value!;
                                                        });
                                                      })),
                                              const Text(
                                                "24-hour format (14:00:00)",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              )
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            height: 50,
                                            width: 150,
                                            child: TextFormField(
                                              enabled: false,
                                              initialValue: timeformate1 ?? "",
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15),
                                                border:
                                                    const OutlineInputBorder(),
                                                filled: true,
                                                fillColor: Colors.grey.shade200,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                                      groupValue:
                                                          timeformateselect,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          dateProvider
                                                              .updateTimeFormat(
                                                                  '12', value);
                                                          timeformateselect =
                                                              value!;
                                                        });
                                                      })),
                                              const Text(
                                                "12-hour format (2:00:00 PM)",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              )
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            height: 50,
                                            width: 150,
                                            child: TextFormField(
                                              enabled: false,
                                              initialValue: timeformate2 ?? "",
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15),
                                                border:
                                                    const OutlineInputBorder(),
                                                filled: true,
                                                fillColor: Colors.grey.shade200,
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "Formatted Date and Time Preview:",
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
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: blueColor),
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.grey.shade50,
                                    ),
                                    child: Text(
                                      dateProvider
                                          .getFormattedDateTimePreview(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: blueColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  customdate = customdate != null &&
                                          customdate!.isNotEmpty
                                      ? customdate
                                      : dateProvider.dateFormat;

                                  print("Custom Date: $customdate");

                                  // Save the date format based on selection
                                  if (dateformateselect == 0) {
                                    context
                                        .read<DateProvider>()
                                        .updateDateFormat('MM/dd/yyyy', 0);
                                  } else if (dateformateselect == 1) {
                                    context
                                        .read<DateProvider>()
                                        .updateDateFormat('yyyy-MM-dd', 1);
                                  } else if (dateformateselect == 2) {
                                    context
                                        .read<DateProvider>()
                                        .updateDateFormat('yyyy-MMM-dd', 2);
                                  } else if (dateformateselect == 3 &&
                                      customdate != null) {
                                    // Save the custom date format
                                    String fixedDate =
                                        fixDateFormat(customdate!);
                                    context
                                        .read<DateProvider>()
                                        .updateDateFormat(fixedDate!, 3);
                                  }

                                  // Show success message
                                  Fluttertoast.showToast(
                                    msg: "Date format updated successfully",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.black87,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5.0),
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.width < 500
                                            ? 40
                                            : 50,
                                    width:
                                        MediaQuery.of(context).size.width < 500
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
                              const SizedBox(height: 15),
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
                                  const Spacer(),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Configure Notifications",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: blueColor,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 15
                                              : 28,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 4),
                                    // decoration: BoxDecoration(
                                    //   color: Colors.white,
                                    //   borderRadius:
                                    //       BorderRadius.circular(10),
                                    //   boxShadow: [
                                    //     BoxShadow(
                                    //       color: Colors.grey
                                    //           .withOpacity(0.1),
                                    //       spreadRadius: 1,
                                    //       blurRadius: 5,
                                    //       offset: const Offset(0, 2),
                                    //     ),
                                    //   ],
                                    // ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Create Section
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFF4F8FF),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: blueColor.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Create',
                                                style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 15
                                                          : 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: blueColor,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Administrator',
                                                        style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 16,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      Checkbox(
                                                        value: createAdmin,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            createAdmin =
                                                                value ?? false;
                                                          });
                                                        },
                                                        activeColor: blueColor,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Assignee',
                                                        style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 16,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      Checkbox(
                                                        value: createAssignee,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            createAssignee =
                                                                value ?? false;
                                                          });
                                                        },
                                                        activeColor: blueColor,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Tenant',
                                                        style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 16,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      Checkbox(
                                                        value: createTenant,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            createTenant =
                                                                value ?? false;
                                                          });
                                                        },
                                                        activeColor: blueColor,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Update Section
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF4F8FF),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: blueColor.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Update',
                                                style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 15
                                                          : 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: blueColor,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Administrator',
                                                        style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 16,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      Checkbox(
                                                        value: updateAdmin,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            updateAdmin =
                                                                value ?? false;
                                                          });
                                                        },
                                                        activeColor: blueColor,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Assignee',
                                                        style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 16,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      Checkbox(
                                                        value: updateAssignee,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            updateAssignee =
                                                                value ?? false;
                                                          });
                                                        },
                                                        activeColor: blueColor,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Tenant',
                                                        style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 16,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      Checkbox(
                                                        value: updateTenant,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            updateTenant =
                                                                value ?? false;
                                                          });
                                                        },
                                                        activeColor: blueColor,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Complete Section
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF4F8FF),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: blueColor.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Complete',
                                                style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 15
                                                          : 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: blueColor,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Administrator',
                                                        style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 16,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      Checkbox(
                                                        value: completeAdmin,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            completeAdmin =
                                                                value ?? false;
                                                          });
                                                        },
                                                        activeColor: blueColor,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Assignee',
                                                        style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 16,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      Checkbox(
                                                        value: completeAssignee,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            completeAssignee =
                                                                value ?? false;
                                                          });
                                                        },
                                                        activeColor: blueColor,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Tenant',
                                                        style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 16,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      Checkbox(
                                                        value: completeTenant,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            completeTenant =
                                                                value ?? false;
                                                          });
                                                        },
                                                        activeColor: blueColor,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        height: 50,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: blueColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          onPressed: isSavingNotifications
                                              ? null
                                              : () async {
                                                  await saveWorkOrderNotificationSettings();
                                                },
                                          child: isSavingNotifications
                                              ? const Center(
                                                  child: SpinKitFadingCircle(
                                                    color: Colors.white,
                                                    size: 30.0,
                                                  ),
                                                )
                                              : Text(
                                                  'Save',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 16
                                                            : 25,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
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
                              const SizedBox(height: 15),
                              // Dynamic categories dropdown for work order
                              DropdownButtonHideUnderline(
                                child: DropdownButton2<allcategories_model>(
                                  isExpanded: true,
                                  hint: Text(_isLoadingCategories
                                      ? 'Loading categories...'
                                      : 'Select Category'),
                                  value: _dropdownCategories
                                          .contains(_selectedDropdownCategory)
                                      ? _selectedDropdownCategory
                                      : null,
                                  items: _dropdownCategories.map((cat) {
                                    return DropdownMenuItem<
                                        allcategories_model>(
                                      value: cat,
                                      child: Text(cat.name ?? ''),
                                    );
                                  }).toList(),
                                  onChanged: _isLoadingCategories
                                      ? null // disables dropdown while loading
                                      : (allcategories_model? newValue) {
                                          setState(() {
                                            _selectedDropdownCategory =
                                                newValue;
                                            _showTextField =
                                                newValue?.name == 'Other';
                                          });
                                        },
                                  buttonStyleData: ButtonStyleData(
                                    height: 45,
                                    padding: const EdgeInsets.only(
                                        left: 14, right: 14),
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
                                    maxHeight: 250,
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
                                    height: 50,
                                    padding:
                                        EdgeInsets.only(left: 14, right: 14),
                                  ),
                                ),
                              ),
                              if (_showTextField)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: buildTextField('Other Category',
                                      'Enter Other Category', other),
                                ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Vendor *',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: blueColor,
                                  fontSize:
                                      MediaQuery.of(context).size.width < 500
                                          ? 16
                                          : 25,
                                ),
                              ),
                              const SizedBox(
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
                                            child: DropdownButtonFormField2<
                                                String>(
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
                                                        color:
                                                            Color(0xFFb0b6c3),
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
                                                      fontWeight:
                                                          FontWeight.w400,
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
                                                padding: const EdgeInsets.only(
                                                    left: 14, right: 14),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  color: Colors.white,
                                                ),
                                                elevation: 2,
                                              ),
                                              iconStyleData:
                                                  const IconStyleData(
                                                icon:
                                                    Icon(Icons.arrow_drop_down),
                                                iconSize: 24,
                                                iconEnabledColor:
                                                    Color(0xFFb0b6c3),
                                                iconDisabledColor: Colors.grey,
                                              ),
                                              dropdownStyleData:
                                                  DropdownStyleData(
                                                maxHeight: 250,
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
                                                height: 50,
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
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Entery Allowed ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: blueColor,
                                  fontSize:
                                      MediaQuery.of(context).size.width < 500
                                          ? 16
                                          : 25,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: const Text('Select'),
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
                                    padding:
                                        EdgeInsets.only(left: 14, right: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Assigned To *',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: blueColor,
                                  fontSize:
                                      MediaQuery.of(context).size.width < 500
                                          ? 16
                                          : 25,
                                ),
                              ),
                              const SizedBox(
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
                                            child: DropdownButtonFormField2<
                                                String>(
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
                                                        color:
                                                            Color(0xFFb0b6c3),
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
                                                      fontWeight:
                                                          FontWeight.w400,
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
                                                  _selectedStaffs =
                                                      staffs[value];
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
                                                padding: const EdgeInsets.only(
                                                    left: 14, right: 14),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  color: Colors.white,
                                                ),
                                                elevation: 2,
                                              ),
                                              iconStyleData:
                                                  const IconStyleData(
                                                icon:
                                                    Icon(Icons.arrow_drop_down),
                                                iconSize: 24,
                                                iconEnabledColor:
                                                    Color(0xFFb0b6c3),
                                                iconDisabledColor: Colors.grey,
                                              ),
                                              dropdownStyleData:
                                                  DropdownStyleData(
                                                maxHeight: 250,
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
                                ],
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              // Configure Notifications Section
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
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
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      onPressed: () async {
                                        print("hello");
                                        updateWorkOrderSettings();
                                      },
                                      child: isLoading
                                          ? const Center(
                                              child: SpinKitFadingCircle(
                                                color: Colors.white,
                                                size: 55.0,
                                              ),
                                            )
                                          : Text(
                                              'Save',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        500
                                                    ? 16
                                                    : 25,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        if (ismanagetemplate) const manage_templates(),
                        if (ischargesetting)
                          Column(
                            children: [
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Manage Charges",
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
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Configure how charges should be recorded — either as a single bundled charge or as separate individual charges.",
                                      style: TextStyle(
                                        color: greyColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 14
                                                : 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: Row(
                                  children: [
                                    Switch(
                                      value: chargesetting == null
                                          ? true
                                          : chargesetting!["unbundle_charges"],
                                      onChanged: (value) {
                                        setState(() {
                                          if (chargesetting != null)
                                            chargesetting!["unbundle_charges"] =
                                                !chargesetting![
                                                    "unbundle_charges"];
                                          else
                                            chargesetting = {
                                              "unbundle_charges": value
                                            };
                                        });

                                        print(chargesetting);
                                      },
                                      activeColor:
                                          blueColor, // Color when switch is on
                                      inactiveThumbColor: Colors
                                          .grey, // Color when switch is off
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Unbundle Charges',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: blueColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      String? token = prefs.getString('token');
                                      String? id = prefs.getString('adminId');
                                      bool success = await AddChargeSettingData(
                                          id, {
                                        "admin_id": id,
                                        "unbundle_charges":
                                            chargesetting!["unbundle_charges"]
                                      });
                                      if (success) {
                                        // Refresh the charge settings data
                                        loadChargeSetting();
                                      }
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
                                    width: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        chargesetting = null;
                                        print(" $chargesetting");
                                      });
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
                                          color: Colors.white,
                                          border: Border.all(color: blueColor),
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
                                            "Reset",
                                            style: TextStyle(
                                                color: blueColor,
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
                                ],
                              ),
                            ],
                          ),
                        if (iscategories)
                          Column(
                            children: [
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Manage Categories",
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
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      height: 48,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade400),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: TextField(
                                        controller: categories,
                                        decoration:
                                            const InputDecoration.collapsed(
                                          hintText: 'Enter category name',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      addCategory();
                                    },
                                    child: Container(
                                      height: 43,
                                      width: 150,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                            0xFF1A2F5B), // Dark blue like the image
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'Add Category',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              // Category Table
                              FutureBuilder<List<categories_model>>(
                                future: futureCategories,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: SpinKitFadingCircle(
                                      color: Colors.black,
                                      size: 40.0,
                                    ));
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child:
                                            Text('Error: \\${snapshot.error}'));
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return const Center(
                                        child: Text('No categories found'));
                                  } else {
                                    final categoriesList = snapshot.data!;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Header
                                        Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade400,
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color: const Color(0xFFF4F8FF),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 8),
                                          child: const Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'CATEGORY NAME',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1.1,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'ACTION',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.1,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        // Rows
                                        ...categoriesList
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          int idx = entry.key;
                                          var cat = entry.value;
                                          return Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 8),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade400,
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: idx % 2 == 0
                                                  ? Colors.white
                                                  : const Color(0xFFF4F8FF),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16,
                                                        horizontal: 12),
                                                    child: Text(
                                                      cat.name ?? '',
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.black87),
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.red),
                                                  onPressed: () {
                                                    print(
                                                        "caling delete categories ");
                                                    setState(() {
                                                      _showDeleteCategoryAlert(
                                                          context,
                                                          cat.categoryId ?? '');
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        if (isvendor)
                          _isStaff
                              ? StaffVendor.Vendor_table(isEmbedded: true)
                              : Vendor_table(isEmbedded: true),
                        if (ispropertyowner)
                          _isStaff
                              ? StaffRentalOwner.Rentalowner_table(
                                  isEmbedded: true)
                              : Rentalowner_table(isEmbedded: true),
                        if (ispropertytype)
                          _isStaff
                              ? StaffPropertyType.PropertyTable(
                                  isEmbedded: true)
                              : PropertyTable(isEmbedded: true),
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
                    const Text(
                      'No Internet',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text(
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
        return match
            .group(0)!; // Return the character unchanged if it doesn't match
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

  // Add this function to handle category addition
  Future<void> addCategory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString('adminId');
    String categoryName = categories.text.trim();
    String? token = prefs.getString('token');

    print("adminId: $adminId, categoryName: $categoryName, token: $token");

    if (categoryName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }
    if (adminId == null || adminId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin ID is missing')),
      );
      return;
    }

    final url = Uri.parse('${Api_url}/api/settings/categories');
    final response = await http.post(
      url,
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $adminId",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "admin_id": adminId,
        "name": categoryName,
      }),
    );

    final responseData = jsonDecode(response.body);
    print("responce categories $responseData");
    if (response.statusCode == 200 && responseData["statusCode"] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category added successfully')),
      );
      categories.clear();
      setState(() {
        futureCategories = accountRepository().fetchCategories();
      }); // Refresh UI and reload categories
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(responseData["message"] ?? 'Failed to add category')),
      );
    }
  }

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
                  // const SizedBox(height: 20),
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
                                  ? const SpinKitFadingCircle(
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  : const Text(
                                      'Add',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
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
                              border: Border.all(color: blueColor),
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
                  const SizedBox(height: 10),
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

  void _showEditAccount(BuildContext context, Setting4 account) {
    // Store original values for comparison
    final String originalAccountName = account.account ?? '';
    final String originalNote = account.notes ?? '';
    final String? originalAccountType = account.accountType;
    final String? originalFundType = account.fundType;

    // Create controllers for edit dialog
    TextEditingController editAccountName =
        TextEditingController(text: account.account ?? '');
    TextEditingController editNote =
        TextEditingController(text: account.notes ?? '');
    String? editSelectedAccounttype = account.accountType;
    String? editSelectedFundtype = account.fundType;
    bool editIsLoading = false;
    bool editIsError = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Edit Account',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: blueColor,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const SizedBox(height: 20),
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
                    controller: editAccountName,
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
                      if (editSelectedAccounttype == null) {
                        return 'Please select an account type';
                      }
                      return null;
                    },
                    labelText: 'Select',
                    items: accounttypeitems,
                    selectedValue: editSelectedAccounttype,
                    onChanged: (String? value) {
                      setState(() {
                        editSelectedAccounttype = value;
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
                      if (editSelectedFundtype == null) {
                        return 'Please select a fund type';
                      }
                      return null;
                    },
                    labelText: 'Select',
                    items: fundtypeitems,
                    selectedValue: editSelectedFundtype,
                    onChanged: (String? value) {
                      setState(() {
                        editSelectedFundtype = value;
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
                    controller: editNote,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            if (editSelectedAccounttype == null ||
                                editAccountName.text.trim().isEmpty ||
                                editSelectedFundtype == null) {
                              setState(() {
                                editIsError = true;
                              });
                            } else {
                              // Check if any changes were made
                              final String currentAccountName =
                                  editAccountName.text.trim();
                              final String currentNote = editNote.text.trim();

                              bool hasChanges =
                                  currentAccountName != originalAccountName ||
                                      currentNote != originalNote ||
                                      editSelectedAccounttype !=
                                          originalAccountType ||
                                      editSelectedFundtype != originalFundType;

                              if (!hasChanges) {
                                // No changes made, just close dialog and show message
                                Navigator.pop(context);
                                Fluttertoast.showToast(msg: "No changes made");
                                return;
                              }

                              setState(() {
                                editIsLoading = true;
                                editIsError = false;
                              });

                              try {
                                await accountRepository().updateAccount(
                                  accountId: account.accountId!,
                                  account: currentAccountName,
                                  accounttype: editSelectedAccounttype,
                                  fundtype: editSelectedFundtype,
                                  chargetype: account.chargeType ?? "",
                                  notes: currentNote,
                                );
                                Navigator.pop(context);
                                _refreshAccounts();
                              } catch (e) {
                                setState(() {
                                  editIsError = true;
                                });
                              } finally {
                                setState(() {
                                  editIsLoading = false;
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
                              child: editIsLoading
                                  ? const SpinKitFadingCircle(
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  : const Text(
                                      'Update',
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
                              border: Border.all(color: blueColor),
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
                  const SizedBox(height: 10),
                  if (editIsError)
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

  Widget buildTextField(
      String label, String hintText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8.0),
        Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(5),
          child: Container(
            padding: const EdgeInsets.only(left: 10),
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

  // Add this function to show a delete confirmation dialog with reason for categories
  void _showDeleteCategoryAlert(BuildContext context, String id) {
    print("calling this detele categories 1");
    TextEditingController reason = TextEditingController();
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this category!",
      content: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          SizedBox(
            height: 45,
            child: TextField(
              controller: reason,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter reason for deletion',
                contentPadding: EdgeInsets.only(top: 8, left: 15),
              ),
            ),
          ),
        ],
      ),
      style: const AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
        DialogButton(
          child: const Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            print("calling this detele categories 2");
            if (reason.text.isEmpty) {
              Fluttertoast.showToast(msg: "Please enter a reason for deletion");
            } else {
              await accountRepository()
                  .DeleteCategories(categories_id: id, reason: reason.text);
              setState(() {
                futureCategories = accountRepository().fetchCategories();
              });
              Navigator.pop(context);
            }
          },
          color: blueColor,
        ),
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
      ],
    ).show();
  }

  // Vendor table helper functions
  void vendorSortData(List<Vendor> data) {
    if (vendorSorting1) {
      data.sort((a, b) => vendorAscending1
          ? a.vendorName!.toLowerCase().compareTo(b.vendorName!.toLowerCase())
          : b.vendorName!.toLowerCase().compareTo(a.vendorName!.toLowerCase()));
    } else if (vendorSorting2) {
      data.sort((a, b) => vendorAscending2
          ? a.vendorPhoneNumber!.compareTo(b.vendorPhoneNumber!)
          : b.vendorPhoneNumber!.compareTo(a.vendorPhoneNumber!));
    }
  }

  Widget _buildVendorHeaders() {
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFF4F8FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDBE0E5))),
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
              flex: 3,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (vendorSorting1 == true) {
                      vendorSorting2 = false;
                      vendorAscending1 =
                          vendorSorting1 ? !vendorAscending1 : true;
                      vendorAscending2 = false;
                    } else {
                      vendorSorting1 = !vendorSorting1;
                      vendorSorting2 = false;
                      vendorAscending1 =
                          vendorSorting1 ? !vendorAscending1 : true;
                      vendorAscending2 = false;
                    }
                  });
                },
                child: Row(
                  children: [
                    width < 400
                        ? Text("Name ",
                            style: TextStyle(
                                color: blueColor, fontWeight: FontWeight.bold))
                        : Text("Name",
                            style: TextStyle(
                                color: blueColor, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 3),
                    vendorSorting1
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 7, left: 2),
                            child: FaIcon(FontAwesomeIcons.sortDown,
                                size: 20, color: blueColor),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (vendorSorting2) {
                      vendorSorting1 = false;
                      vendorAscending2 =
                          vendorSorting2 ? !vendorAscending2 : true;
                      vendorAscending1 = false;
                    } else {
                      vendorSorting1 = false;
                      vendorSorting2 = !vendorSorting2;
                      vendorAscending2 =
                          vendorSorting2 ? !vendorAscending2 : true;
                      vendorAscending1 = false;
                    }
                  });
                },
                child: Row(
                  children: [
                    width < 400
                        ? Text("Phone Number ",
                            style: TextStyle(
                                color: blueColor, fontWeight: FontWeight.bold))
                        : Text("Phone Number",
                            style: TextStyle(
                                color: blueColor, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 3),
                    vendorSorting2
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 7, left: 2),
                            child: FaIcon(FontAwesomeIcons.sortDown,
                                size: 20, color: blueColor),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add this function to show a delete confirmation dialog for vendors
  void _showDeleteVendorAlert(BuildContext context, String id) {
    print("calling this delete vendor 1");
    TextEditingController reason = TextEditingController();
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this vendor!",
      content: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          SizedBox(
            height: 45,
            child: TextField(
              controller: reason,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter reason for deletion',
                contentPadding: EdgeInsets.only(top: 8, left: 15),
              ),
            ),
          ),
        ],
      ),
      style: const AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
        DialogButton(
          child: const Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            print("calling this delete vendor 2");
            if (reason.text.isEmpty) {
              Fluttertoast.showToast(msg: "Please enter a reason for deletion");
            } else {
              await VendorRepository(baseUrl: '')
                  .DeleteVender(vender_id: id, reason: reason.text);
              setState(() {
                futureVendors = VendorRepository(baseUrl: '').getVendors();
              });
              Navigator.pop(context);
            }
          },
          color: blueColor,
        ),
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
      ],
    ).show();
  }
}
