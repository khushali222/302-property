import 'package:flutter/material.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../repository/workorder.dart';
import '../widgets/appbar.dart';

/// "Work Order Details" — last-12-months monthly breakdown.
/// Opened when the vendor taps the dashboard "Statistics" chart.
class WorkOrderMonthlyBreakdown extends StatelessWidget {
  final List<MonthStat> stats;

  const WorkOrderMonthlyBreakdown({Key? key, this.stats = const []})
      : super(key: key);

  static const Map<String, String> _fullMonth = {
    'Jan': 'January',
    'Feb': 'February',
    'Mar': 'March',
    'Apr': 'April',
    'May': 'May',
    'Jun': 'June',
    'Jul': 'July',
    'Aug': 'August',
    'Sep': 'September',
    'Oct': 'October',
    'Nov': 'November',
    'Dec': 'December',
  };

  static const Color _bg = Color(0xFFF1F4FA);
  static const Color _chipBg = Color(0xFFEAEEFB);
  static const Color _chipText = Color(0xFF4B6FE8);
  static const Color _overdue = Color(0xFF5A86D5);
  static const Color _border = Color(0xFFE6E9F0);
  static const Color _muted = Color(0xFF8A95A8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: widget_302.App_Bar(
        context: context,
        onDrawerIconPressed: () {},
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Text(
                "Monthly Breakdown",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: blueColor,
                ),
              ),
            ),
            Expanded(
              child: stats.isEmpty
                  ? const Center(
                      child: Text("No statistics available",
                          style: TextStyle(color: _muted)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: stats.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) => _monthCard(stats[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: 44,
              width: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: Icon(Icons.chevron_left, color: blueColor, size: 28),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Work Order Details",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: blueColor,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                "Last 12 Months",
                style: TextStyle(fontSize: 14, color: _muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _monthCard(MonthStat m) {
    final String full = _fullMonth[m.month] ?? m.month;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 64,
            width: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _chipBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              m.month,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _chipText,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$full ${m.year}",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: blueColor,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  "New & Overdue Work Orders",
                  style: TextStyle(fontSize: 13, color: _muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _statRow(blueColor, m.received),
              const SizedBox(height: 8),
              _statRow(_overdue, m.overdue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statRow(Color color, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
