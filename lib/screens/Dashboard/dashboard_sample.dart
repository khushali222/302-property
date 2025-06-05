import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../../StaffModule/model/staffpermission.dart';
import '../../StaffModule/repository/staffpermission_provider.dart';
import '../../StaffModule/screen/Dashboard/cronjob_payment_table.dart';
import '../../constant/constant.dart';

class DashboardMobileSimple extends StatelessWidget {
  final int propertyCount;
  final int tenantCount;
  final int applicantCount;
  final int vendorCount;
  final int workOrderCount;
  final int newWorkOrder;
  final int overdueWorkOrder;
  final int totalWorkOrders;

  const DashboardMobileSimple({
    Key? key,
    required this.propertyCount,
    required this.tenantCount,
    required this.applicantCount,
    required this.vendorCount,
    required this.workOrderCount,
    required this.newWorkOrder,
    required this.overdueWorkOrder,
    required this.totalWorkOrders,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardTextStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: blueColor);
    final subTextStyle = TextStyle(
        color: Color.fromRGBO(16, 24, 40, 0.7), fontWeight: FontWeight.bold, fontSize: 14);

    Widget dashboardCard(IconData icon, String count, String label) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: blueColor.withOpacity(.1),
                child: Icon(icon, color: blueColor),
              ),
              const SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(count, style: cardTextStyle),
                  Text(label, style: subTextStyle),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      );
    }

    Widget paymentCard(String name, String address, String amount) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(name, style: cardTextStyle),
                const Spacer(),
                Text('$amount', style: cardTextStyle),
              ],
            ),
            Divider(
              thickness: 2,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rental Address',
                    style: subTextStyle.copyWith(
                        color: blueColor, fontWeight: FontWeight.bold)),
                Text('Action',
                    style: subTextStyle.copyWith(
                        color: blueColor, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(address, style: subTextStyle),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8)),
                      height: 30,
                      width: 30,
                      child: Icon(Icons.check, color: blueColor),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8)),
                      height: 30,
                      width: 30,
                      child: Icon(Icons.recycling_outlined, color: blueColor),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8)),
                      height: 30,
                      width: 30,
                      child:
                      Icon(Icons.calendar_month_outlined, color: blueColor),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    }

    Widget workOrderCard(String title, int total) {
      // Determine background color based on title
      Color cardColor;
      Color iconBgColor;
      Color iconColor;
      Color arrowBgColor;
      Color arrowIconColor;

      if (title.toLowerCase().contains('overdue')) {
        // Overdue Work Orders: use a custom blue background instead of red
        cardColor = Colors
            .white; // light red (unchanged, as it's a background, but can be changed if needed)
        iconBgColor = const Color.fromRGBO(90, 134, 213, 1);
        iconColor = Colors.white;
        arrowBgColor =
        const Color.fromRGBO(90, 134, 213, 0.1); // light blue with opacity
        arrowIconColor = const Color.fromRGBO(90, 134, 213, 1);
      } else if (title.toLowerCase().contains('new')) {
        // New Work Order: use a blue background
        cardColor = Colors.white; // light blue
        iconBgColor = blueColor ?? blueColor;
        iconColor = Colors.white;
        arrowBgColor = blueColor.withOpacity(0.1) ?? blueColor;
        arrowIconColor = blueColor ?? blueColor;
      } else {
        // Default
        cardColor = Colors.white;
        iconBgColor = blueColor ?? blueColor;
        iconColor = Colors.white;
        arrowBgColor = blueColor ?? blueColor;
        arrowIconColor = blueColor;
      }

      return Container(

        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: (iconBgColor).withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.add, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: cardTextStyle.copyWith(
                      fontSize: 18,
                      color: blueColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Total : ${total.toString()}',
                        style: subTextStyle.copyWith(
                          color: blueColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: arrowBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.arrow_forward_ios,
                  size: 16, color: arrowIconColor),
            ),
          ],
        ),
      );
    }

    Widget analyticCard() {
      // Example data for the pie chart
      final List<PieChartSectionData> pieChartData = [
        PieChartSectionData(
          color: blueColor,
          value: newWorkOrder.toDouble(),
          title: '',
          radius: 50,
        ),
        PieChartSectionData(
          color: Color.fromRGBO(90, 134, 213, 1),
          value: overdueWorkOrder.toDouble(),
          title: '',
          radius: 50,
        ),
      ];

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            SizedBox(
              width: 80,
              height: 80,
              child: PieChart(
                PieChartData(
                  sections: pieChartData,
                  centerSpaceRadius: 0,
                  sectionsSpace: 2,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(width: 35),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Analytic', style: cardTextStyle.copyWith(fontSize: 20)),
                Row(
                  children: [
                    CircleAvatar(
                        radius: 7, backgroundColor: blueColor.withOpacity(.9)),
                    const SizedBox(width: 6),
                    Text('New Work Orders', style: subTextStyle.copyWith(fontSize: 16)),
                  ],
                ),
                Row(
                  children: [
                    CircleAvatar(
                        radius: 7,
                        backgroundColor: Color.fromRGBO(90, 134, 213, 1)),
                    const SizedBox(width: 6),
                    Text('Overdue Work Orders', style: subTextStyle.copyWith(fontSize: 16)),
                  ],
                ),
                Text('Total Work orders : $totalWorkOrders',
                    style: subTextStyle.copyWith(fontSize: 16)),
              ],
            ),
          ],
        ),
      );
    }
    StaffPermission? permissions;
    final permissionProvider = Provider.of<StaffPermissionProvider>(context);
    permissions = permissionProvider.permissions;
    return Container(
      color: Color.fromRGBO(241, 244, 250, 1),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text('Main Dashboard',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: blueColor)),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                // Build a list of cards based on permissions, maintaining order
                final List<Widget> cards = [];
                if (permissions?.propertyView == true) {
                  cards.add(dashboardCard(
                      Icons.home, propertyCount.toString(), 'Properties'));
                }
                if (permissions?.tenantView == true) {
                  cards.add(dashboardCard(
                      Icons.people, tenantCount.toString(), 'Tenants'));
                }
                if (permissions?.applicantView == true) {
                  cards.add(dashboardCard(Icons.assignment_ind,
                      applicantCount.toString(), 'Applicants'));
                }
                if (permissions?.vendorView == true) {
                  cards.add(dashboardCard(
                      Icons.store, vendorCount.toString(), 'Vendors'));
                }
                if (permissions?.workorderView == true) {
                  cards.add(dashboardCard(
                      Icons.work, workOrderCount.toString(), 'Work Orders'));
                }

                // Group cards into rows of 2, but use IntrinsicHeight to avoid Expanded inside Padding
                List<Widget> rows = [];
                for (int i = 0; i < cards.length; i += 2) {
                  if (i + 1 < cards.length) {
                    rows.add(
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                             cards[i],
                            SizedBox(width: 8),
                             cards[i + 1],
                          ],
                        ),
                      ),
                    );
                  } else {
                    rows.add(
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                             cards[i],

                          ],
                        ),
                      ),
                    );
                  }
                }
                return Column(
                  children: rows,
                );
              },
            ),
            workOrderCard('New Work Order', newWorkOrder),
            workOrderCard('Overdue Work Order', overdueWorkOrder),
            analyticCard(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(
                  left: 8, right: 8),
              child: Cronjob_payment_table(),
            ),
          ],
        ),
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = blueColor.withOpacity(.9)!
      ..style = PaintingStyle.fill;
    final paint2 = Paint()
      ..color = blueColor.withOpacity(0.3)!
      ..style = PaintingStyle.fill;

    canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height), -0.5, 2, true, paint1);
    canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height), 1.5, 1, true, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ExpandablePaymentCard extends StatefulWidget {
  final String name;
  final String address;
  final String amount;

  const ExpandablePaymentCard({
    Key? key,
    required this.name,
    required this.address,
    required this.amount,
  }) : super(key: key);

  @override
  State<ExpandablePaymentCard> createState() => _ExpandablePaymentCardState();
}

class _ExpandablePaymentCardState extends State<ExpandablePaymentCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final cardTextStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: blueColor);
    final subTextStyle = TextStyle(
        color: Colors.grey[700], fontWeight: FontWeight.bold, fontSize: 14);

    return GestureDetector(
      onTap: () => setState(() => expanded = !expanded),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: expanded
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  color: blueColor,
                ),
                const SizedBox(width: 8),
                Text(widget.name, style: cardTextStyle),
                const Spacer(),
                Text('${widget.amount}', style: cardTextStyle),
              ],
            ),
            Divider(thickness: 2),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rental Address',
                    style: subTextStyle.copyWith(
                        color: blueColor, fontWeight: FontWeight.bold)),
                Text('Action',
                    style: subTextStyle.copyWith(
                        color: blueColor, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.address, style: subTextStyle),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      height: 30,
                      width: 30,
                      child: Icon(Icons.check, color: blueColor),
                    ),
                    SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      height: 30,
                      width: 30,
                      child: Icon(Icons.recycling_outlined,
                          color: blueColor),
                    ),
                    SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      height: 30,
                      width: 30,
                      child: Icon(Icons.calendar_month_outlined,
                          color: blueColor),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        )
            : Row(
          children: [
            Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              color: blueColor,
            ),
            const SizedBox(width: 8),
            Text(widget.name, style: cardTextStyle),
            const Spacer(),
            Text('${widget.amount}', style: cardTextStyle),
          ],
        ),
      ),
    );
  }
}
