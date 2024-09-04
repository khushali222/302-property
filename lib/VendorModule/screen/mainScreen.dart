import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/screens/Leasing/RentalRoll/newAddLease.dart';
import '../screen/dashboard.dart';
import '../screen/profile.dart';
import '../screen/work_order/workorder_table.dart';

class MainScreen extends StatefulWidget {
  String? workorder;

  MainScreen({this.workorder});
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _workOrderFilter = "";
  // List of screens corresponding to each BottomNavigationBarItem
   List<Widget> _screens = [
    Dashboard_vendors(),
    Profile_screen(),
  //  WorkOrderTable(),
  ];
  void initState() {
    super.initState();
    _screens = [
      Dashboard_vendors(
        onWorkOrderSelected: (filter) {
          setState(() {
            print(filter);
            _workOrderFilter = filter; // Update the filter value
            _onItemTapped(2);
            // Switch to the Work Order tab
          });
        },
      ),
      Profile_screen(),
      WorkOrderTable(),
    ];
  }
  void _onItemTapped(int index) {
    setState(() {

      _selectedIndex = index;
      _screens[2] = _workOrderFilter == "" ? WorkOrderTable() : WorkOrderTable(filter: _workOrderFilter,);
      _workOrderFilter = "";
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
      onWillPop: ()async{
        if(_selectedIndex != 0){
          setState(() {
            _selectedIndex = 0;
          });
        }
        else{

            return await _showExitPopup(context);

        }
        return false;
      },
      child: Scaffold(

        body:  _screens[_selectedIndex],// Display the selected screen
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items:  [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                "assets/images/tenants/dashboard.svg",
                height: 20,
                width: 20,
                color: _selectedIndex == 0 ? blueColor :grey,
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                "assets/images/tenants/Admin.svg",
                height: 20,
                width: 20,
                color: _selectedIndex == 1 ? blueColor : grey,
              ),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                "assets/images/tenants/Work.svg",
                height: 20,
                width: 20,
                color: _selectedIndex == 2 ? blueColor : grey,
              ),
              label: 'Work Order',
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
