import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';
import 'package:three_zero_two_property/Model/SavedReportModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/CustomReportService.dart';
import 'package:three_zero_two_property/screens/Reports/ReportScreens/CreateCustomReportScreen.dart';
import 'package:three_zero_two_property/screens/Reports/ReportScreens/CustomReportConstants.dart';
import 'package:three_zero_two_property/StaffModule/widgets/appbar.dart';
import 'package:three_zero_two_property/StaffModule/widgets/custom_drawer.dart';
import 'package:three_zero_two_property/widgets/report_header.dart';

class CustomReportBuilder extends StatefulWidget {
  const CustomReportBuilder({super.key});

  @override
  State<CustomReportBuilder> createState() => _CustomReportBuilderState();
}

class _CustomReportBuilderState extends State<CustomReportBuilder> {
  final CustomReportService _service = CustomReportService();
  List<SavedReport> _savedReports = [];
  SavedReport? _selectedReport;
  bool _loading = true;
  String? _errorMessage;
  String? _adminId;
  List<Map<String, dynamic>> _reportData = [];
  int _reportCount = 0;
  bool _reportDataLoading = false;
  String? _reportDataError;
  Set<int> _expandedRows = {};

  @override
  void initState() {
    super.initState();
    _loadAdminAndReports();
  }

  Future<void> _loadAdminAndReports() async {
    final prefs = await SharedPreferences.getInstance();
    final adminId = prefs.getString('adminId');
    if (adminId == null || adminId.isEmpty) {
      setState(() {
        _loading = false;
        _errorMessage = 'Admin ID not found. Please login again.';
      });
      return;
    }
    setState(() => _adminId = adminId);
    await _fetchSavedReports();
  }

  Future<void> _fetchSavedReports() async {
    if (_adminId == null) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    final result = await _service.fetchSavedReports(adminId: _adminId!);
    setState(() {
      _loading = false;
      _savedReports = result.data;
      if (result.statusCode != 200) _errorMessage = result.message;
      // Do not auto-select: user must select a report to see data
    });
  }

  Future<void> _fetchReportData() async {
    if (_adminId == null || _selectedReport == null) {
      setState(() {
        _reportData = [];
        _reportDataError = null;
      });
      return;
    }
    setState(() {
      _reportDataLoading = true;
      _reportDataError = null;
      _reportData = [];
    });
    final result = await _service.fetchCustomReportData(
      adminId: _adminId!,
      reportId: _selectedReport!.reportId,
    );
    setState(() {
      _reportDataLoading = false;
      if (result.statusCode == 200) {
        final rawList = result.data.map((e) => Map<String, dynamic>.from(e)).toList();
        final count = result.count;
        _reportData = rawList.length > count
            ? rawList.sublist(0, count)
            : rawList;
        _reportCount = count;
        _reportDataError = null;
      } else {
        _reportDataError = result.message;
        _reportData = [];
        _reportCount = 0;
      }
    });
  }

  void _navigateToCreate() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateCustomReportScreen(adminId: _adminId ?? ''),
      ),
    );
    if (created == true) await _fetchSavedReports();
  }

  void _onEditReport(SavedReport report) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateCustomReportScreen(
          adminId: _adminId ?? '',
          existingReport: report,
        ),
      ),
    );
    if (updated == true) await _fetchSavedReports();
  }

  void _onDeleteReport(SavedReport report) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Report'),
        content: Text(
            'Are you sure you want to delete "${report.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _fetchSavedReports();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: CustomDrawerStaff(
        currentpage: "Reports",
        dropdown: false,
      ),
      appBar: widget_302_Staff.App_Bar(context: context),
      body: Column(
        children: [
          const ReportHeader(title: "Custom Report Builder"),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final padding = 24.0 * 2;
                final contentWidth = constraints.maxWidth > 0
                    ? constraints.maxWidth - padding
                    : MediaQuery.of(context).size.width - padding;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage!,   
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    SizedBox(
                      width: contentWidth > 400 ? 280 : contentWidth,
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saved Reports',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<SavedReport>(
                            isExpanded: true,
                            hint: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                _loading
                                    ? 'Loading...'
                                    : _savedReports.isEmpty
                                        ? 'No saved reports'
                                        : _selectedReport?.name ?? 'Select report',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _selectedReport == null
                                      ? const Color(0xFF8A95A8)
                                      : Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            items: _savedReports
                                .map((r) => DropdownMenuItem<SavedReport>(
                                      value: r,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              r.name,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined,
                                                size: 18, color: Colors.grey),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _onEditReport(r);
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          const SizedBox(width: 4),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline,
                                                size: 18, color: Colors.red),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _onDeleteReport(r);
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                            value: _selectedReport,
                            onChanged: _loading || _savedReports.isEmpty
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedReport = value;
                                      _fetchReportData();
                                    });
                                  },
                            buttonStyleData: const ButtonStyleData(
                              height: 42,
                              padding: EdgeInsets.symmetric(horizontal: 12),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 300,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _navigateToCreate,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Create'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blueColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    hint: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Export',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down,
                              size: 20, color: Colors.white),
                        ],
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'pdf', child: Text('Export as PDF')),
                      DropdownMenuItem(
                          value: 'excel', child: Text('Export as Excel')),
                      DropdownMenuItem(
                          value: 'csv', child: Text('Export as CSV')),
                    ],
                    onChanged: (value) {},
                    buttonStyleData: ButtonStyleData(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: blueColor,
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTableSection(contentWidth),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static const _currencyKeys = {
    'lease_amount', 'balance', 'rentDueAmount', 'purchase_price',
    'insured_value', 'insurance_premium', 'tax_amount', 'zillow_value',
    'remaining_balance', 'monthly_payment', 'loan_amount',
  };

  static const _dateKeys = {
    'start_date', 'end_date', 'purchase_date', 'mortgage_start_date',
    'mortgage_end_date', 'mortgage_update_date', 'placed_in_service',
  };

  String _formatCellValue(String key, dynamic value, [String Function(String)? formatDate]) {
    if (value == null) return 'N/A';
    if (value is bool) return value ? 'Yes' : 'No';
    final s = value.toString().trim();
    if (s.isEmpty) return 'N/A';
    if (_currencyKeys.contains(key)) {
      final num? n = num.tryParse(s);
      if (n != null) return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(n);
    }
    if (key == 'interest_rate' && num.tryParse(s) != null) return '$s%';
    if (_dateKeys.contains(key) && formatDate != null) return formatDate(s);
    return s;
  }

  Widget _buildTableSection(double contentWidth) {
    final columns = _selectedReport?.selectedColumns ?? [];
    final maxW = contentWidth > 0 ? contentWidth : double.infinity;

    if (_selectedReport == null || columns.isEmpty) {
      return Container(
        constraints: BoxConstraints(maxWidth: maxW),
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No data available. Select a report from Saved Reports to view data.',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_reportDataLoading) {
      return Container(
        constraints: BoxConstraints(maxWidth: maxW),
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: blueColor),
              const SizedBox(height: 16),
              const Text('Loading report data...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    if (_reportDataError != null) {
      return Container(
        constraints: BoxConstraints(maxWidth: maxW),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          _reportDataError!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_reportData.isEmpty) {
      return Container(
        constraints: BoxConstraints(maxWidth: maxW),
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Center(
          child: Text(
            'No data for this report.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final includeHistory = _selectedReport!.includeHistory;
    return Container(
      constraints: BoxConstraints(maxWidth: maxW),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedReport!.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: blueColor,
                      ),
                    ),
                  ),
                  Text(
                    '(${_reportData.length} ${_reportData.length == 1 ? 'result' : 'results'})',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ...List.generate(_reportData.length, (index) {
              final row = _reportData[index];
              final address = row['rental_adress']?.toString().trim() ?? '—';
              final unit = row['rental_unit']?.toString().trim();
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: index % 2 != 0 ? const Color(0xFFF4F8FF) : Colors.white,
                  border: Border.all(color: const Color(0xFFDBE0E5)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: false,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        if (expanded) {
                          _expandedRows.add(index);
                        } else {
                          _expandedRows.remove(index);
                        }
                      });
                    },
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    collapsedBackgroundColor: index % 2 != 0 ? const Color(0xFFF4F8FF) : Colors.white,
                    backgroundColor: Colors.white,
                    iconColor: blueColor,
                    collapsedIconColor: blueColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    title: Text(
                      'Property: $address${unit != null && unit.isNotEmpty ? ' - Unit $unit' : ''}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: blueColor,
                      ),
                    ),
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final dateProvider = Provider.of<DateProvider>(context, listen: false);
                          final entries = <MapEntry<String, String>>[];
                          for (final key in columns) {
                            final label = customReportColumnLabels[key] ?? key;
                            final raw = row[key];
                            final value = _formatCellValue(key, raw, dateProvider.formatCurrentDate);
                            entries.add(MapEntry(label, value));
                          }
                          final historyStr = row['history']?.toString().trim();
                          final showHistory = includeHistory && historyStr != null && historyStr.isNotEmpty;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(0.35),
                                  1: FlexColumnWidth(0.65),
                                },
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children: entries.map((e) => TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 12, bottom: 10),
                                      child: Text(
                                        '${e.key}:',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: blueColor,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        e.value,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ],
                                )).toList(),
                              ),
                              if (showHistory) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: blueColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: blueColor.withOpacity(0.3)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'History',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: blueColor,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        historyStr,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: blueColor,
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

}
