import 'package:flutter/material.dart';

import 'package:three_zero_two_property/screens/Team_Access/permission_matrix_view.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/custom_drawer.dart';

/// Standalone User Permission screen (opened from the app bar menu).
///
/// Hosts the shared [PermissionMatrixView] — the same Staff / Vendor / Tenant
/// matrix used inside Settings → Team & Access — so both stay in sync. The
/// permission API (GET/POST /api/permission/permission) is unchanged; only the
/// UI is the new design.
class UserPermissionScreen extends StatelessWidget {
  const UserPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar:
          widget_302.App_Bar(context: context, isUserPermitePageActive: true),
      drawer: CustomDrawer(currentpage: "Dashboard", dropdown: false),
      body: const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 30),
        child: PermissionMatrixView(),
      ),
    );
  }
}
