import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/PortfolioOverviewService.dart';
import 'package:three_zero_two_property/widgets/report_header.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_drawer.dart';

class PortfolioOverviewReport extends StatefulWidget {
  const PortfolioOverviewReport({super.key});

  @override
  State<PortfolioOverviewReport> createState() =>
      _PortfolioOverviewReportState();
}

class _PortfolioOverviewReportState extends State<PortfolioOverviewReport> {
  PortfolioOverviewData? _data;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final adminId = prefs.getString('adminId') ?? '';

      final data =
          await PortfolioOverviewService().fetchPortfolioOverview(adminId);

      setState(() {
        _data = data;
        _error = data == null ? 'Failed to load portfolio overview.' : null;
      });
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${formatMoney(value / 1000000)}M';
    } else if (value >= 1000) {
      return formatMoneyWhole(value);
    }
    return formatMoneyWhole(value);
  }

  String _formatPercent(double value) => '${value.toStringAsFixed(1)}%';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: 'Reports',
        dropdown: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportHeader(title: 'Portfolio Overview'),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: SpinKitThreeBounce(color: blueColor, size: 24),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(backgroundColor: blueColor),
              child:
                  const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_data == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildKpiTable(),
    );
  }

  Widget _buildKpiTable() {
    final rows = [
      _KpiRow('Properties', _data!.properties.toString()),
      _KpiRow('Total Estimated Value', _formatCurrency(_data!.totalEstimatedValue)),
      _KpiRow('Total Loan Balance', _formatCurrency(_data!.totalLoanBalance)),
      _KpiRow('Portfolio LTV', _formatPercent(_data!.portfolioLtv)),
      _KpiRow('Avg DSCR (loan-weighted)', _data!.avgDscrLoanWeighted.toStringAsFixed(2)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          ...rows.asMap().entries.map((e) => _buildTableRow(e.value, e.key)),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEEF6),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('KPI',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: blueColor,
                  fontSize: 14)),
          Text('Value',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: blueColor,
                  fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTableRow(_KpiRow row, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : const Color(0xFFF9FAFB),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(row.label,
              style: TextStyle(
                  color: blueColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          Text(row.value,
              style: TextStyle(
                  color: blueColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _KpiRow {
  final String label;
  final String value;
  const _KpiRow(this.label, this.value);
}
