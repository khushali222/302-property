import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/screens/Leasing/RentalRoll/newAddLease.dart';
import '../screen/dashboard.dart';
import '../screen/profile.dart';
import '../screen/work_order/workorder_table.dart';
import 'package:three_zero_two_property/VendorModule/screen/bid_room/vendor_bid_room_table.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainScreen extends StatefulWidget {
  String? workorder;

  MainScreen({this.workorder});
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  ConnectivityResult? _connectivityResult;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  int _selectedIndex = 0;
  String _workOrderFilter = "";
  // List of screens corresponding to each BottomNavigationBarItem
  List<Widget> _screens = [
    Dashboard_vendors(),
    Profile_screen(),
    //  WorkOrderTable(),
    VendorBidRoomTable(),
  ];
  void initState() {
    super.initState();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (!mounted) return;
      // The event is only a trigger: checkInternet() verifies
      // against the network before deciding, so a stale `none`
      // from the plugin cannot strand this screen offline.
      checkInternet();
    });
    checkInternet();
    _screens = [
      Dashboard_vendors(
        onWorkOrderSelected: (filter) {
          setState(() {
            _workOrderFilter = filter; // Update the filter value
            _onItemTapped(2);
            // Switch to the Work Order tab
          });
        },
      ),
      Profile_screen(),
      WorkOrderTable(),
      VendorBidRoomTable(),
    ];
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    // connectivity_plus can report a stale `none` after the
    // connection is back; confirm before believing it.
    if (connectiondata == ConnectivityResult.none &&
        await hasNetworkNow()) {
      connectiondata = ConnectivityResult.wifi;
    }
    if (!mounted) return;
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedIndex = index;
      if (index == 2) {
        _screens[2] = _workOrderFilter == ""
            ? WorkOrderTable()
            : WorkOrderTable(
                filter: _workOrderFilter,
              );
        _workOrderFilter = "";
      }
    });
  }

  Future<bool> _showExitPopup(BuildContext context) async {
    bool exitConfirmed = false;

    await Alert(
      context: context,
      type: AlertType.warning,
      title: "Exit App",
      desc: "Do you want to exit the app?",
      style: AlertStyle(
        backgroundColor: Colors.white,
        titleStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        descStyle: TextStyle(
          fontSize: 16,
          color: Colors.black54,
        ),
        animationType: AnimationType.grow,
        isOverlayTapDismiss: false,
        overlayColor: Colors.black.withOpacity(0.5),
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(color: Colors.blue, width: 2),
        ),
        alertPadding: EdgeInsets.all(16.0),
      ),
      buttons: [
        DialogButton(
          child: Text(
            "No",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.red,
          radius: BorderRadius.circular(8.0),
        ),
        DialogButton(
          child: Text(
            "Yes",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            exitConfirmed = true;
            if (Platform.isAndroid) {
              SystemNavigator.pop();
            } else if (Platform.isIOS) {
              exit(0);
            }
          },
          color: Colors.green,
          radius: BorderRadius.circular(8.0),
        ),
      ],
    ).show();

    return exitConfirmed;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        } else {
          return await _showExitPopup(context);
        }
        return false;
      },
      child: Scaffold(
        // The offline state deliberately does NOT live here any more. Gating the
        // shell replaced the whole child, app bar included — and that app bar is
        // what keeps fetching notifications, i.e. the only thing that could
        // report the connection coming back. Blocked here, the module could
        // never recover and lost its header at the same time. Each tab now owns
        // its own offline state, which keeps the header on screen and keeps a
        // request flowing.
        body: _screens[_selectedIndex], // Display the selected screen
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: blueColor,
          unselectedItemColor: grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 24,
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                "assets/images/tenants/dashboard.svg",
                height: 24,
                width: 24,
                color: _selectedIndex == 0 ? blueColor : grey,
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                "assets/images/tenants/Admin.svg",
                height: 24,
                width: 24,
                color: _selectedIndex == 1 ? blueColor : grey,
              ),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                "assets/images/tenants/Work.svg",
                height: 24,
                width: 24,
                color: _selectedIndex == 2 ? blueColor : grey,
              ),
              label: 'Work Orders',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.fileLines,
                size: 24,
                color: _selectedIndex == 3 ? blueColor : grey,
              ),
              label: 'Bid Room',
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MainScreen(),
  ));
}
