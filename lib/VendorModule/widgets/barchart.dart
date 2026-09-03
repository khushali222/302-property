import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../repository/workorder.dart';
import '../screen/work_order_monthly_breakdown.dart';

// Palette (matches the legend dots / web source of truth):
//   New     = blueColor                       (#152B51 navy)
//   Overdue = Color.fromRGBO(90, 134, 213, 1) (#5A86D5 blue)
final Color _kNewColor = blueColor;
const Color _kOverdueColor = Color.fromRGBO(90, 134, 213, 1);
const Color _kChipBg = Color(0xFFEDF1F8); // light grey legend chip
const Color _kCardFill = Color(0xFFF1F4FA); // chart card fill (stands off white page)
const Color _kCardBorder = Color(0xFFDDE3EE); // card border + dotted gridlines
const Color _kMutedText = Color(0xFF8A95A8); // "Last 12 Months" / labels

/// Self-contained "Statistics" card for the vendor dashboard.
/// Header (Statistics / Last 12 Months), two legend chips, a flat chart
/// (tap a bar → popup tooltip), and a "View Monthly Breakdown" button.
class VendorStatisticsCard extends StatefulWidget {
  final List<MonthStat> stats;
  final bool isLoading;
  final bool isTablet;

  const VendorStatisticsCard({
    Key? key,
    this.stats = const [],
    this.isLoading = false,
    this.isTablet = false,
  }) : super(key: key);

  @override
  State<VendorStatisticsCard> createState() => _VendorStatisticsCardState();
}

class _VendorStatisticsCardState extends State<VendorStatisticsCard> {
  late final TooltipBehavior _tooltip;

  @override
  void initState() {
    super.initState();
    // Tap a bar → popup card with the month + New / Overdue values.
    _tooltip = TooltipBehavior(
      enable: true,
      shared: true,
      activationMode: ActivationMode.singleTap,
      color: blueColor,
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: widget.isTablet ? 15 : 13,
      ),
    );
  }

  void _openBreakdown() {
    if (widget.stats.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkOrderMonthlyBreakdown(stats: widget.stats),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double titleSize = widget.isTablet ? 22 : 18;
    final double chipFont = widget.isTablet ? 15 : 13;
    final double chartHeight = widget.isTablet ? 320 : 250;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header — Statistics (left) / Last 12 Months (right)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Text(
                "Statistics",
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: blueColor,
                ),
              ),
              const Spacer(),
              Text(
                "Last 12 Months",
                style: TextStyle(fontSize: chipFont, color: _kMutedText),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Legend chips — two equal, full-width side by side when both labels
        // fit, stacked when they do not.
        //
        // CRM-4358: side-by-side Expanded chips pin each to exactly half the
        // row. On a phone that leaves ~86dp for "Overdue Work Orders", which
        // needs ~133dp, so the ellipsis clipped it to "Overdue Work...". It is
        // not device-specific — the same happens on a large phone. Measuring
        // the real text and stacking when it will not fit keeps both labels
        // whole at every width, which is what the design asks for.
        LayoutBuilder(
          builder: (context, constraints) {
            const double chipPadding = 14 * 2;
            const double swatch = 18;
            const double swatchGap = 10;
            const double betweenChips = 12;

            double textWidth(String label) {
              final tp = TextPainter(
                text: TextSpan(
                  text: label,
                  style: TextStyle(
                    fontSize: chipFont,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                maxLines: 1,
                textDirection: TextDirection.ltr,
              )..layout();
              return tp.width;
            }

            final double widest = [
              textWidth("New Work Orders"),
              textWidth("Overdue Work Orders"),
            ].reduce((a, b) => a > b ? a : b);

            final double sideBySideChip =
                (constraints.maxWidth - betweenChips) / 2;
            final bool fitsSideBySide =
                sideBySideChip - chipPadding - swatch - swatchGap >= widest;

            if (fitsSideBySide) {
              return Row(
                children: [
                  Expanded(
                      child: _legendChip(
                          "New Work Orders", _kNewColor, chipFont)),
                  const SizedBox(width: betweenChips),
                  Expanded(
                      child: _legendChip(
                          "Overdue Work Orders", _kOverdueColor, chipFont)),
                ],
              );
            }

            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: _legendChip("New Work Orders", _kNewColor, chipFont),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: _legendChip(
                      "Overdue Work Orders", _kOverdueColor, chipFont),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        // Flat chart card — no elevation, rounded, light border. Tap a bar = popup.
        Container(
          height: chartHeight,
          padding: const EdgeInsets.fromLTRB(8, 18, 14, 10),
          decoration: BoxDecoration(
            color: _kCardFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kCardBorder),
          ),
          child: widget.isLoading
              ? Center(
                  child: SpinKitFadingCircle(
                      color: blueColor, size: widget.isTablet ? 48 : 40),
                )
              : _buildChart(),
        ),
        // "View Monthly Breakdown" button → opens the full breakdown screen.
        if (!widget.isLoading && widget.stats.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: _openBreakdown,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEAEEFB), // light navy tint
                  foregroundColor: blueColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFD5DDF2)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "View Monthly Breakdown",
                      style: TextStyle(
                        color: blueColor, // dark blue / navy text
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: blueColor, size: 18),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _legendChip(String label, Color color, double font) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kChipBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: font,
                fontWeight: FontWeight.w600,
                color: blueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (widget.stats.isEmpty) {
      return const Center(
        child: Text(
          "No statistics available",
          style: TextStyle(color: _kMutedText),
        ),
      );
    }

    return SfCartesianChart(
      margin: EdgeInsets.zero,
      tooltipBehavior: _tooltip,
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        axisLine: const AxisLine(width: 0),
        labelStyle: TextStyle(
          fontSize: widget.isTablet ? 15 : 13,
          color: _kMutedText,
        ),
      ),
      primaryYAxis: const NumericAxis(
        minimum: 0,
        // Faint dotted horizontal gridlines.
        majorGridLines:
            MajorGridLines(width: 1, color: _kCardBorder, dashArray: <double>[5, 5]),
        axisLine: AxisLine(width: 0),
        majorTickLines: MajorTickLines(size: 0),
        // Hide Y labels but keep the gridlines.
        labelStyle: TextStyle(color: Colors.transparent, fontSize: 0.1),
      ),
      plotAreaBorderWidth: 0,
      series: <CartesianSeries<MonthStat, String>>[
        ColumnSeries<MonthStat, String>(
          name: 'New',
          dataSource: widget.stats,
          color: _kNewColor,
          xValueMapper: (MonthStat d, _) => d.month,
          yValueMapper: (MonthStat d, _) => d.received,
          width: 0.85,
          spacing: 0.15,
          borderRadius: BorderRadius.circular(4),
        ),
        ColumnSeries<MonthStat, String>(
          name: 'Overdue',
          dataSource: widget.stats,
          color: _kOverdueColor,
          xValueMapper: (MonthStat d, _) => d.month,
          yValueMapper: (MonthStat d, _) => d.overdue,
          width: 0.85,
          spacing: 0.15,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
