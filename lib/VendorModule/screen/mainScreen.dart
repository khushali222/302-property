import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../screen/dashboard.dart';
import '../screen/profile.dart';
import '../screen/work_order/workorder_table.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _workOrderFilter = "";

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      Dashboard_vendors(
        onWorkOrderSelected: (filter) {
          setState(() {
            print(filter);
            _workOrderFilter = filter; // Update the filter value
            _selectedIndex = 2; // Switch to the Work Order tab
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          _onItemTapped(index);
          // Update the WorkOrderTable filter if needed
          if (index == 2 && _workOrderFilter.isNotEmpty) {
            setState(() {
              _screens[2] = WorkOrderTable(filter: _workOrderFilter);
            });
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/tenants/dashboard.svg",
              height: 24,
              width: 24,
              color: _selectedIndex == 0 ? Colors.blue : Colors.grey,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/tenants/Admin.svg",
              height: 24,
              width: 24,
              color: _selectedIndex == 1 ? Colors.blue : Colors.grey,
            ),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/tenants/Work.svg",
              height: 24,
              width: 24,
              color: _selectedIndex == 2 ? Colors.blue : Colors.grey,
            ),
            label: 'Work Order',
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MainScreen(),
  ));
}
