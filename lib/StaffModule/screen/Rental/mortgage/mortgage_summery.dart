import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/enums/history_type.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/custom_drawer.dart';
import 'package:three_zero_two_property/widgets/custom_history_table.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:dio/io.dart' as dio_io;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import '../../../../provider/dateProvider.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_drawer.dart';

class MortgageSummary extends StatefulWidget {
  final Map<String, dynamic>? mortgageData;

  const MortgageSummary({Key? key, this.mortgageData}) : super(key: key);

  @override
  State<MortgageSummary> createState() => _MortgageSummaryState();
}

class _MortgageSummaryState extends State<MortgageSummary> {
  Map<String, dynamic>? mortgageData;
  bool _isLoading = false;
  Set<int> _expandedPayoffIndices = {}; // Track which payoff rows are expanded
  int? _lifecycleExpandedIndex;
  bool _isAddingEvent = false;
  int _lifecyclePage = 1;
  static const int _lifecycleItemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    print(widget.mortgageData!['_id']);
    //mortgageData = widget.mortgageData;
    // if (mortgageData == null) {
    _loadMortgageData();
    //}
  }

  Future<void> _loadMortgageData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? adminid = prefs.getString("adminId");
      String? id = prefs.getString("staff_id");

      final response = await http.get(
        Uri.parse(
            '${Api_url}/api/mortgage/details/${widget.mortgageData!['_id']}'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'CRM $token',
          'id': 'CRM $id',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          mortgageData = data["data"];

          print(mortgageData!["properties"]);
        });
      }
    } catch (e) {
      setState(() {
        mortgageData = {
          '_id': '85d15d7a-77dc-401b-9d48-cd88d5f1abf3',
          'properties': ['1752748973359'],
          'bank_name': 'Test Bank',
          'mortgage_no': '11',
          'loan_amount': 4500,
          'interest_rate': 5,
          'status': 'active',
          'remaining_balance': 4500,
          'start_date': '2025-09-02T00:00:00.000Z',
          'end_date': '2025-09-24T00:00:00.000Z',
          'last_payment_date': '2025-09-02T00:00:00.000Z',
          'next_payment_date': '2025-09-16T00:00:00.000Z',
          'borrower_first_name': 'John',
          'borrower_last_name': 'Doe',
          'monthly_payment': 4518.75,
        };
      });
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '\$0.00';
    final numValue = amount is String ? double.tryParse(amount) ?? 0 : amount;
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(numValue);
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'paid off':
        return Colors.blue;
      case 'defaulted':
        return Colors.red;
      case 'refinanced':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  double _getPaymentProgress() {
    if (mortgageData == null) return 0.0;
    final loanAmount = mortgageData!['loan_amount'] ?? 0;
    final remainingBalance = mortgageData!['remaining_balance'] ?? 0;
    if (loanAmount == 0) return 0.0;
    return ((loanAmount - remainingBalance) / loanAmount) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    if (_isLoading) {
      return Scaffold(
          appBar: widget_302.App_Bar(context: context),
          backgroundColor: Colors.white,
          drawer: CustomDrawer(
            currentpage: "Mortgage Summary",
            dropdown: true,
          ),
          body: Center(
            child: SpinKitFadingCircle(
              color: Colors.black,
              size: 44,
            ),
          ));
    }

    if (mortgageData == null) {
      return Scaffold(
        appBar: widget_302.App_Bar(context: context),
        backgroundColor: Colors.white,
        drawer: CustomDrawer(
          currentpage: "Mortgage Summary",
          dropdown: true,
        ),
        body: const Center(
          child: Text('No mortgage data available'),
        ),
      );
    }

    final paymentProgress = _getPaymentProgress();
    final status = mortgageData!['status'] ?? 'unknown';

    return Scaffold(
      appBar: widget_302_Staff.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawerStaff(
        currentpage: "Mortgage",
        dropdown: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width > 500 ? 12 : 0,
                    right: MediaQuery.of(context).size.width > 500 ? 12 : 0),
                child: titleBar(
                  width: double.infinity,
                  title: 'Mortgage Summary',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header

                  // Status and Progress Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getStatusColor(status)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(status),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Last updated: ${_formatDate(mortgageData!['updatedAt'])}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_formatCurrency(mortgageData!['remaining_balance'])} Remaining Balance',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Payment Progress
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${paymentProgress.toStringAsFixed(0)}% COMPLETE',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: paymentProgress / 100,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getStatusColor(status),
                                    ),
                                    minHeight: 8,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Paid: ${_formatCurrency((mortgageData!['loan_amount'] ?? 0) - (mortgageData!['remaining_balance'] ?? 0))}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Total: ${_formatCurrency(mortgageData!['loan_amount'])}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Financial Information Cards
                  const Text(
                    'Financial Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Column(
                    children: [
                      _buildSummaryCard(
                        title: 'Original Loan',
                        value: _formatCurrency(mortgageData!['loan_amount']),
                        icon: FontAwesomeIcons.dollarSign,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryCard(
                        title: 'Interest Rate',
                        value: '${mortgageData!['interest_rate'] ?? 0}%',
                        icon: FontAwesomeIcons.percent,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryCard(
                        title: 'Monthly Payment',
                        value:
                            _formatCurrency(mortgageData!['monthly_payment']),
                        icon: FontAwesomeIcons.calendar,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryCard(
                        title: 'Total Interest',
                        value: _formatCurrency(
                          ((mortgageData!['loan_amount'] ?? 0) *
                              (mortgageData!['interest_rate'] ?? 0) /
                              100),
                        ),
                        icon: FontAwesomeIcons.chartLine,
                        color: Colors.purple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Dates Information
                  _buildInfoCard(
                    title: 'Important Dates',
                    children: [
                      _buildDateRow(
                          'Start Date',
                          dateProvider.formatCurrentDate(
                              '${_formatDate(mortgageData!['start_date'])}')),
                      _buildDateRow(
                          'End Date',
                          dateProvider.formatCurrentDate(
                              '${_formatDate(mortgageData!['end_date'])}')),
                      _buildDateRow(
                          'Last Payment',
                          dateProvider.formatCurrentDate(
                              '${_formatDate(mortgageData!['last_payment_date'])}')),
                      _buildDateRow(
                          'Next Payment',
                          dateProvider.formatCurrentDate(
                              '${_formatDate(mortgageData!['next_payment_date'])}')),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Bank Information
                  _buildInfoCard(
                    title: 'Bank Information',
                    children: [
                      _buildInfoRow(
                          'Bank Name', mortgageData!['bank_name'] ?? 'N/A'),
                      _buildInfoRow(
                          'Contact', mortgageData!['bank_contact_no'] ?? 'N/A'),
                      _buildInfoRow(
                          'Email', mortgageData!['bank_email'] ?? 'N/A'),
                      _buildInfoRow(
                          'Address', mortgageData!['bank_address'] ?? 'N/A'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Borrower Information
                  _buildInfoCard(
                    title: 'Borrower Information',
                    children: [
                      _buildInfoRow(
                          'Name',
                          '${mortgageData!['borrower_first_name'] ?? ''} ${mortgageData!['borrower_last_name'] ?? ''}'
                              .trim()),
                      _buildInfoRow(
                          'Phone', mortgageData!['borrower_phone'] ?? 'N/A'),
                      _buildInfoRow(
                          'Email', mortgageData!['borrower_email'] ?? 'N/A'),
                      _buildInfoRow('Address',
                          mortgageData!['borrower_address'] ?? 'N/A'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Properties Section
                  _buildPropertiesSection(),

                  const SizedBox(height: 20),

                  // Documents Section
                  _buildDocumentsSection(),

                  const SizedBox(height: 20),

                  // // Payoff History Section
                  _buildPayoffHistorySection(),

                  const SizedBox(height: 20),

                  // Payment Information Section
                  _buildPaymentInfoSection(),
                  // Property Information
                  // _buildInfoCard(
                  //   title: 'Property Information',
                  //   children: [
                  //     _buildInfoRow('Properties',
                  //         '${(mortgageData!['properties'] as List).length} Property${(mortgageData!['properties'] as List).length > 1 ? 's' : ''}'),
                  //     _buildInfoRow(
                  //         'Mortgage #', mortgageData!['mortgage_no'] ?? 'N/A'),
                  //     _buildInfoRow('Status', status.toUpperCase()),
                  //   ],
                  // ),
                  const SizedBox(height: 20),
                  // Mortgage Lifecycle section
                  _buildLifecycleSection(),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: CustomHistoryTable(
                        historyType: HistoryType.mortgage,
                        entityId: mortgageData!['id'] ??
                            mortgageData!['_id'] ??
                            widget.mortgageData!['_id'],
                        title: 'Audit History',
                        blueColor: blueColor,
                        itemsPerPage: 10),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────── Mortgage Lifecycle ───────────────────

  String _getPropertyAddress(String? rentalId) {
    if (rentalId == null || mortgageData == null) return 'Property';
    final props = mortgageData!['properties'];
    if (props is List) {
      for (var p in props) {
        if (p is Map && p['rental_id'] == rentalId) {
          return p['address'] ?? 'Property';
        }
      }
    }
    return 'Property';
  }

  List<Map<String, dynamic>> _getLifecycleEvents() {
    final events = <Map<String, dynamic>>[];
    if (mortgageData == null) return events;

    // ── Payoffs ────────────────────────────────────────────────
    for (var p in (mortgageData!['payoffs'] as List? ?? [])) {
      final by = p['added_by'];
      final byName = by is Map
          ? '${by['first_name'] ?? ''} ${by['last_name'] ?? ''}'.trim()
          : '';
      events.add({
        'eventKind': 'payoff',
        'eventType': 'Payoff',
        'date': p['date'] ?? p['created_at'] ?? '',
        'details': '\$${p['amount']}${byName.isNotEmpty ? ' ($byName)' : ''}',
      });
    }

    // ── Collateral events ──────────────────────────────────────
    for (var c
        in (mortgageData!['lifecycle_events']?['collateral'] as List? ?? [])) {
      final isAdd = (c['type'] ?? '') == 'add';
      final address = _getPropertyAddress(c['rental_id']?.toString());
      events.add({
        'eventKind': isAdd ? 'collateral_add' : 'collateral_release',
        'eventType': isAdd ? 'Collateral add' : 'Collateral release',
        'date': c['date'] ?? '',
        'details':
            '${isAdd ? 'Collateral added' : 'Collateral released'} — $address',
      });
    }

    // ── Renewals (balance updates shown as Renewal / Refinance) ─
    for (var r
        in (mortgageData!['lifecycle_events']?['renewals'] as List? ?? [])) {
      events.add({
        'eventKind': 'renewal',
        'eventType': 'Renewal / Refinance',
        'date': r['date'] ?? '',
        'details': r['notes'] ?? '',
      });
    }

    // ── Old terms ──────────────────────────────────────────────
    for (var o
        in (mortgageData!['lifecycle_events']?['old_terms'] as List? ?? [])) {
      events.add({
        'eventKind': 'old_terms',
        'eventType': 'Old terms',
        'date': o['date'] ?? '',
        'details': o['notes'] ?? '',
      });
    }

    events.sort((a, b) {
      try {
        return DateTime.parse(b['date']).compareTo(DateTime.parse(a['date']));
      } catch (_) {
        return 0;
      }
    });
    return events;
  }

  Widget _buildLifecycleSection() {
    final allEvents = _getLifecycleEvents();
    final totalEvents = allEvents.length;
    final totalPages =
        totalEvents == 0 ? 1 : (totalEvents / _lifecycleItemsPerPage).ceil();
    final startIndex = (_lifecyclePage - 1) * _lifecycleItemsPerPage;
    final endIndex =
        (startIndex + _lifecycleItemsPerPage).clamp(0, totalEvents);
    final pageEvents = totalEvents == 0
        ? <Map<String, dynamic>>[]
        : allEvents.sublist(startIndex, endIndex);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row ──────────────────────────────────────────
          Row(
            children: [
              const SizedBox(width: 2),
              Text(
                'Mortgage Lifecycle',
                style: TextStyle(
                  color: blueColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _isAddingEvent ? () {} : _showAddEventDialog,
                icon: const Icon(Icons.add, size: 15, color: Colors.white),
                label: const Text('Add Event',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Column headers ─────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDBE0E5)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                const SizedBox(width: 28),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Date',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: blueColor,
                        fontSize: 14),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Event Type',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: blueColor,
                        fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          // ── Rows / empty state ─────────────────────────────────
          if (allEvents.isEmpty)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFDBE0E5)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('No lifecycle events',
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pageEvents.length,
              itemBuilder: (_, i) =>
                  _buildLifecycleRow(pageEvents[i], startIndex + i),
            ),

          // ── Pagination controls ────────────────────────────────
          if (totalEvents > _lifecycleItemsPerPage) ...[
            const SizedBox(height: 6),
            _buildLifecyclePagination(
                totalEvents, totalPages, startIndex, endIndex),
          ],
        ],
      ),
    );
  }

  Widget _buildLifecyclePagination(
      int totalEvents, int totalPages, int startIndex, int endIndex) {
    final canPrev = _lifecyclePage > 1;
    final canNext = _lifecyclePage < totalPages;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ── Left chevron circle ──────────────────────────────────
        GestureDetector(
          onTap: canPrev
              ? () => setState(() {
                    _lifecyclePage--;
                    _lifecycleExpandedIndex = null;
                  })
              : null,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: canPrev ? blueColor : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.chevron_left, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 14),
        // ── "Page X of Y" label ──────────────────────────────────
        Text(
          'Page $_lifecyclePage of $totalPages',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 14),
        // ── Right chevron circle ─────────────────────────────────
        GestureDetector(
          onTap: canNext
              ? () => setState(() {
                    _lifecyclePage++;
                    _lifecycleExpandedIndex = null;
                  })
              : null,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: canNext ? blueColor : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.chevron_right, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildLifecycleRow(Map<String, dynamic> event, int index) {
    final isExpanded = _lifecycleExpandedIndex == index;
    final dateProvider = Provider.of<DateProvider>(context, listen: false);

    // Use DateProvider to format date for display (respects user's date format preference)
    String dateStr;
    try {
      final raw = event['date'] as String? ?? '';
      final dt = DateTime.parse(raw);
      dateStr =
          dateProvider.formatCurrentDate(DateFormat('yyyy-MM-dd').format(dt));
    } catch (_) {
      dateStr = _formatDate(event['date']);
    }

    final eventType = event['eventType'] as String;
    final details = event['details'] as String;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: index % 2 != 0 ? const Color(0xFFF4F8FF) : Colors.white,
        border: Border.all(color: const Color(0xFFDBE0E5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Expand icon
                  GestureDetector(
                    onTap: () => setState(() =>
                        _lifecycleExpandedIndex = isExpanded ? null : index),
                    child: Container(
                      margin: const EdgeInsets.only(left: 5),
                      padding: !isExpanded
                          ? const EdgeInsets.only(bottom: 10)
                          : const EdgeInsets.only(top: 10),
                      child: FaIcon(
                        isExpanded
                            ? FontAwesomeIcons.sortUp
                            : FontAwesomeIcons.sortDown,
                        size: 20,
                        color: blueColor,
                      ),
                    ),
                  ),
                  // Date
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () => setState(() =>
                          _lifecycleExpandedIndex = isExpanded ? null : index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 12),
                        child: Text(dateStr,
                            style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Event Type
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () => setState(() =>
                          _lifecycleExpandedIndex = isExpanded ? null : index),
                      child: Text(eventType,
                          style: TextStyle(
                              color: blueColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(height: 1, color: const Color(0xFFDBE0E5)),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF4FF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Details :',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: blueColor,
                          fontSize: 13)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFDBE0E5)),
                    ),
                    child: Text(details,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddEventDialog() {
    // Get DateProvider once — used only for display formatting
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    String selectedType = 'payoff';
    final amountCtrl = TextEditingController();
    final balanceCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String? amountError; // persists across StatefulBuilder rebuilds
    String? balanceError; // persists across StatefulBuilder rebuilds
    bool isSubmitting = false; // controls loading on dialog submit button

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                decoration: BoxDecoration(
                  color: blueColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_note_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Add Lifecycle Event',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Event Type',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            value: 'payoff',
                            groupValue: selectedType,
                            activeColor: blueColor,
                            title: const Text('Payoff Event',
                                style: TextStyle(fontSize: 14)),
                            dense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            onChanged: (v) => setDialog(() {
                              selectedType = v!;
                              amountError = null;
                              balanceError = null;
                            }),
                          ),
                          Divider(height: 1, color: Colors.grey.shade200),
                          RadioListTile<String>(
                            value: 'balance_update',
                            groupValue: selectedType,
                            activeColor: blueColor,
                            title: const Text('Balance Update',
                                style: TextStyle(fontSize: 14)),
                            dense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            onChanged: (v) => setDialog(() {
                              selectedType = v!;
                              amountError = null;
                              balanceError = null;
                            }),
                          ),
                        ],
                      ),
                    ),
                    if (selectedType == 'balance_update') ...[
                      const SizedBox(height: 16),
                      Text(
                        'Remaining Balance (\$)',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: balanceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (_) {
                          if (balanceError != null) {
                            setDialog(() => balanceError = null);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter remaining balance',
                          prefixText: '\$ ',
                          errorText: balanceError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: balanceError != null
                                  ? Colors.red
                                  : Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color:
                                  balanceError != null ? Colors.red : blueColor,
                              width: 1.5,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 1.5),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                      ),
                    ],
                    if (selectedType == 'payoff') ...[
                      const SizedBox(height: 16),
                      Text(
                        'Amount',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (_) {
                          if (amountError != null) {
                            setDialog(() => amountError = null);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter payoff amount',
                          prefixText: '\$ ',
                          errorText: amountError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: amountError != null
                                  ? Colors.red
                                  : Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color:
                                  amountError != null ? Colors.red : blueColor,
                              width: 1.5,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 1.5),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Date',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            initialEntryMode: DatePickerEntryMode.calendarOnly,
                            builder: (BuildContext c, Widget? child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  primaryColor: blueColor,
                                  colorScheme: ColorScheme.light(
                                    primary: blueColor,
                                  ),
                                  buttonTheme: const ButtonThemeData(
                                    textTheme: ButtonTextTheme.primary,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null)
                            setDialog(() => selectedDate = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 16, color: blueColor),
                              const SizedBox(width: 10),
                              Text(
                                // Display using user's date format preference
                                dateProvider.formatCurrentDate(
                                    DateFormat('yyyy-MM-dd')
                                        .format(selectedDate)),
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              const Spacer(),
                              Icon(Icons.arrow_drop_down,
                                  color: Colors.grey.shade500),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Footer buttons ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            isSubmitting ? null : () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blueColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          elevation: 0,
                        ),
                        onPressed: isSubmitting
                            ? () {}
                            : () async {
                                if (selectedType == 'payoff') {
                                  final text = amountCtrl.text.trim();
                                  final amount = double.tryParse(text);
                                  if (text.isEmpty) {
                                    setDialog(() =>
                                        amountError = 'Amount is required');
                                    return;
                                  }
                                  if (amount == null || amount <= 0) {
                                    setDialog(() => amountError =
                                        'Please enter a valid amount greater than 0');
                                    return;
                                  }
                                  setDialog(() {
                                    amountError = null;
                                    isSubmitting = true;
                                  });
                                  await _addPayoffEvent(amount, selectedDate);
                                } else if (selectedType == 'balance_update') {
                                  final text = balanceCtrl.text.trim();
                                  final balance = double.tryParse(text);
                                  if (text.isEmpty) {
                                    setDialog(() => balanceError =
                                        'Remaining balance is required');
                                    return;
                                  }
                                  if (balance == null || balance < 0) {
                                    setDialog(() => balanceError =
                                        'Please enter a valid amount');
                                    return;
                                  }
                                  setDialog(() {
                                    balanceError = null;
                                    isSubmitting = true;
                                  });
                                  await _addBalanceUpdateEvent(balance);
                                }
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                        child: isSubmitting
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SpinKitFadingCircle(
                                      color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  const Text('Saving...',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                ],
                              )
                            : const Text('Add Event',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addPayoffEvent(double amount, DateTime date) async {
    setState(() => _isAddingEvent = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? id = prefs.getString('staff_id'); // staff uses staff_id
      final mortgageId = mortgageData!['_id'] ?? widget.mortgageData!['_id'];

      final existing = (mortgageData!['payoffs'] as List? ?? [])
          .map((p) => {
                if (p['_id'] != null) '_id': p['_id'],
                'amount': p['amount'],
                'date': p['date'],
              })
          .toList();
      existing.add({
        'amount': amount,
        'date': '${DateFormat('yyyy-MM-dd').format(date)}T00:00:00.000Z',
      });

      final response = await http
          .put(
            Uri.parse('${Api_url}/api/mortgage/$mortgageId'),
            headers: {
              'Content-Type': 'application/json',
              'authorization': 'CRM $token',
              'id': 'CRM $id',
            },
            body: json.encode({'payoffs': existing}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        await _loadMortgageData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Payoff event added successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to add payoff event'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('Error adding payoff event: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingEvent = false);
    }
  }

  Future<void> _addBalanceUpdateEvent(double newBalance) async {
    setState(() => _isAddingEvent = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? id = prefs.getString('staff_id'); // staff uses staff_id
      final mortgageId = mortgageData!['_id'] ?? widget.mortgageData!['_id'];

      final response = await http
          .put(
            Uri.parse('${Api_url}/api/mortgage/$mortgageId'),
            headers: {
              'Content-Type': 'application/json',
              'authorization': 'CRM $token',
              'id': 'CRM $id',
            },
            body: json.encode({'remaining_balance': newBalance}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        await _loadMortgageData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Balance updated successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to update balance'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('Error updating remaining balance: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingEvent = false);
    }
  }

  // ───────────────────────────────────────────────────────────

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E3A8A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── Documents ───────────────────

  Widget _buildDocumentsSection() {
    final documents = mortgageData!['documents'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Documents (${documents.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              GestureDetector(
                onTap: _showUploadDocumentsDialog,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: blueColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (documents.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'No documents uploaded yet',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            )
          else
            ...documents
                .map((doc) => _buildDocumentCard(doc as Map<String, dynamic>))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> doc) {
    final originalName = doc['original_name'] as String? ?? 'Unknown';
    final uploadedAt = doc['uploaded_at'] as String? ?? '';
    final docId = doc['_id'] as String? ?? '';
    final filename = doc['filename'] as String? ?? '';

    // Derive extension from filename — reliable even when server returns "octet-stream"
    final ext = originalName.contains('.')
        ? originalName.split('.').last.toLowerCase()
        : (filename.contains('.')
            ? filename.split('.').last.toLowerCase()
            : (doc['file_type'] as String? ?? '').toLowerCase());
    final fileType = ext.toUpperCase();

    String formattedDate = 'N/A';
    if (uploadedAt.isNotEmpty) {
      try {
        final date = DateTime.parse(uploadedAt);
        formattedDate =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
            '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    Color typeColor;
    IconData typeIcon;
    switch (ext) {
      case 'pdf':
        typeColor = Colors.red;
        typeIcon = FontAwesomeIcons.filePdf;
        break;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'jfif':
      case 'gif':
      case 'webp':
        typeColor = Colors.blue;
        typeIcon = FontAwesomeIcons.fileImage;
        break;
      case 'doc':
      case 'docx':
        typeColor = const Color(0xFF1565C0);
        typeIcon = FontAwesomeIcons.fileWord;
        break;
      case 'xls':
      case 'xlsx':
        typeColor = Colors.green;
        typeIcon = FontAwesomeIcons.fileExcel;
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = FontAwesomeIcons.file;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: FaIcon(typeIcon, size: 18, color: typeColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  originalName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        fileType,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        formattedDate,
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _viewDocument(filename),
            icon: const Icon(Icons.visibility_outlined,
                color: Colors.blueGrey, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _confirmDeleteDocument(filename, originalName),
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _viewDocument(String filename) async {
    final ext = filename.split('.').last.toLowerCase();
    const imageExts = {'png', 'jpg', 'jpeg', 'jfif', 'gif', 'webp'};
    if (imageExts.contains(ext)) {
      await _previewImageDocument(filename);
    } else {
      await _downloadDocument(filename);
    }
  }

  Future<void> _previewImageDocument(String filename) async {
    final mortgageId = mortgageData!['_id'] ?? widget.mortgageData!['_id'];
    final url = '${Api_url}/api/mortgage/$mortgageId/documents/$filename';
    // Hoist future so FutureBuilder never recreates it on rebuild
    final imageFuture = _fetchDocumentBytes(url);
    if (!mounted) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) {
        final screenH = MediaQuery.of(ctx).size.height;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Image box
              Container(
                constraints: BoxConstraints(maxHeight: screenH * 0.65),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: FutureBuilder<http.Response>(
                    future: imageFuture,
                    builder: (_, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 260,
                          child: Center(
                            child:
                                SpinKitFadingCircle(color: Colors.white, size: 44),
                          ),
                        );
                      }
                      if (snap.hasError ||
                          snap.data == null ||
                          snap.data!.statusCode != 200) {
                        return const SizedBox(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.broken_image,
                                    color: Colors.white54, size: 48),
                                SizedBox(height: 8),
                                Text('Could not load image',
                                    style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                        );
                      }
                      return InteractiveViewer(
                        minScale: 0.8,
                        maxScale: 5.0,
                        child: Image.memory(
                          snap.data!.bodyBytes,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Close button — top-right corner of the box
              Positioned(
                top: -14,
                right: -14,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<http.Response> _fetchDocumentBytes(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('staff_id');
    return http.get(Uri.parse(url), headers: {
      'authorization': 'CRM $token',
      'id': 'CRM $id',
    }).timeout(const Duration(seconds: 30));
  }

  Future<void> _downloadDocument(String filename) async {
    final mortgageId = mortgageData!['_id'] ?? widget.mortgageData!['_id'];
    final url = '${Api_url}/api/mortgage/$mortgageId/documents/$filename';

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text('Downloading $filename...')),
          ]),
          duration: const Duration(seconds: 30),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? id = prefs.getString('staff_id');

      // Save to temp directory, then open native share/open sheet
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/$filename';

      final dioClient = dio_pkg.Dio();
      await dioClient.download(
        url,
        savePath,
        options: dio_pkg.Options(headers: {
          'authorization': 'CRM $token',
          'id': 'CRM $id',
        }),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      // Open native share sheet — user can save to Files, Downloads, open with app, etc.
      await Share.shareXFiles(
        [XFile(savePath)],
        subject: filename,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Download failed. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _confirmDeleteDocument(String filename, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_forever_rounded,
                  color: Colors.red, size: 34),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delete Document',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '"$name" will be permanently removed.\nThis cannot be undone.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 4),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _deleteDocument(filename);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blueColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text('Delete',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDocument(String filename) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? id = prefs.getString('staff_id');
      final mortgageId = mortgageData!['_id'] ?? widget.mortgageData!['_id'];

      final response = await http.delete(
        Uri.parse('${Api_url}/api/mortgage/$mortgageId/documents/$filename'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'CRM $token',
          'id': 'CRM $id',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        await _loadMortgageData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Document deleted successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to delete document'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('Error deleting document: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showUploadDocumentsDialog() {
    List<PlatformFile> selectedFiles = [];
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                decoration: BoxDecoration(
                  color: blueColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Attach Documents',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select files to attach to this mortgage. Supported formats:',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text('• PDF',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const Text('• Images (JPG, PNG, GIF, WebP)',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const Text('• Word (DOC, DOCX)',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const Text('• Excel (XLS, XLSX)',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: isUploading
                            ? null
                            : () async {
                                final result =
                                    await FilePicker.platform.pickFiles(
                                  allowMultiple: true,
                                  type: FileType.custom,
                                  allowedExtensions: [
                                    'pdf',
                                    'jpg',
                                    'jpeg',
                                    'png',
                                    'gif',
                                    'webp',
                                    'doc',
                                    'docx',
                                    'xls',
                                    'xlsx',
                                  ],
                                );
                                if (result != null) {
                                  setDialog(() => selectedFiles = [
                                        ...selectedFiles,
                                        ...result.files
                                      ]);
                                }
                              },
                        icon: const Icon(Icons.attach_file),
                        label: const Text('CHOOSE FILES'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                          side: BorderSide(color: blueColor),
                          foregroundColor: blueColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      if (selectedFiles.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ...selectedFiles.asMap().entries.map((entry) {
                          final i = entry.key;
                          final file = entry.value;
                          final sizeKB =
                              ((file.size) / 1024).toStringAsFixed(1);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(file.name,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500)),
                                      Text('$sizeKB KB',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setDialog(
                                      () => selectedFiles.removeAt(i)),
                                  child: const Icon(Icons.close,
                                      size: 18, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ],
                  ),
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            isUploading ? null : () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blueColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          elevation: 0,
                        ),
                        onPressed: (isUploading || selectedFiles.isEmpty)
                            ? null
                            : () async {
                                setDialog(() => isUploading = true);
                                await _uploadDocuments(selectedFiles);
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                        child: isUploading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SpinKitFadingCircle(
                                      color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  const Text('Uploading...',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                ],
                              )
                            : const Text('Upload',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Same pattern as lease documents (`Add_DocumentRental`): `http.MultipartRequest`.
  Future<void> _uploadDocuments(List<PlatformFile> files) async {
    final sw = Stopwatch()..start();
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? id = prefs.getString('staff_id');
      final mortgageId = mortgageData!['_id'] ?? widget.mortgageData!['_id'];

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${Api_url}/api/mortgage/$mortgageId/documents'),
      );
      request.headers.addAll({
        'authorization': 'CRM $token',
        'id': 'CRM $id',
      });
      // Match web exactly: is_web=true, user_active_recently=true
      request.fields['is_web'] = 'true';
      request.fields['user_active_recently'] = 'true';

      // Web uses field name "files" — must match exactly
      for (final file in files) {
        if (file.path != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'files',
            file.path!,
            filename: file.name,
          ));
        } else if (file.bytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'files',
            file.bytes!,
            filename: file.name,
          ));
        }
      }

      print('── Mortgage upload DIAG (staff) ──');
      print('URL: ${Api_url}/api/mortgage/$mortgageId/documents');
      print('formFields: is_web=true, user_active_recently=true');
      print('auth: token=${token == null ? "MISSING" : "ok"} id=${id == null ? "MISSING" : "ok"}');
      print('multipart: field name "files" | ${request.files.length} file part(s)');
      for (var i = 0; i < files.length; i++) {
        final f = files[i];
        print('  file[$i]: ${f.name} | ${f.size} bytes | ${f.path != null ? "path" : "bytes"}');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      sw.stop();

      print('⏱️ Round-trip: ${sw.elapsedMilliseconds} ms');
      print('HTTP ${response.statusCode} | content-type: ${response.headers['content-type']}');
      print('Body length: ${response.body.length}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(
            '✅ Mortgage documents upload SUCCESS — HTTP ${response.statusCode} | mortgageId=$mortgageId');
        await _loadMortgageData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Documents uploaded successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ));
        }
      } else {
        print(
            '❌ ISSUE: ${_mortgageUploadFailureCauseHint(response.statusCode, response.body)}');
        final msg = _mortgageUploadFailureMessage(response);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: Duration(
                seconds: response.statusCode == 504 ? 10 : 5),
          ));
        }
      }
    } catch (e, st) {
      sw.stop();
      print('❌ UPLOAD EXCEPTION after ${sw.elapsedMilliseconds} ms: $e');
      print('Stack: $st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 5),
        ));
      }
    }
  }

  String _mortgageUploadFailureCauseHint(int code, String body) {
    if (code == 401 || code == 403) {
      return 'Auth (missing/invalid token or id header) — not a file-format issue';
    }
    if (code == 413) {
      return 'Payload too large — try a smaller file or raise server limit';
    }
    if (code == 504 || code == 502 || code == 503) {
      try {
        final m = json.decode(body);
        if (m is Map) {
          if (m['cloudflare_error'] == true) {
            return 'Cloudflare: origin did not answer in time — backend/DevOps (timeouts/slow API)';
          }
          if (m['error_name'] != null) {
            return 'Gateway: ${m['error_name']} — see detail in body above';
          }
        }
      } catch (_) {}
      return 'Gateway timeout — origin/API too slow or proxy timeout (not a Flutter bug)';
    }
    if (code >= 500) {
      return 'Server error — check API logs for this route';
    }
    if (code >= 400) {
      return 'Request rejected by API — read message in body or validate field names (documents vs files)';
    }
    return 'Unexpected status $code';
  }

  String _mortgageUploadFailureMessage(http.Response response) {
    final code = response.statusCode;
    final body = response.body;
    if (code == 504 || code == 502 || code == 503) {
      try {
        final m = json.decode(body);
        if (m is Map) {
          if (m['detail'] != null) return m['detail'].toString();
          if (m['message'] != null) return m['message'].toString();
          if (m['title'] != null) return m['title'].toString();
        }
      } catch (_) {}
      return 'Server gateway timed out (HTTP $code). Staging/Cloudflare did not get a '
          'response from your API in time. Ask your team to increase origin timeouts or '
          'optimize the mortgage upload endpoint; you can try again or use the web app.';
    }
    try {
      final decoded = json.decode(body);
      if (decoded is Map && decoded['message'] != null) {
        return decoded['message'].toString();
      }
    } catch (_) {}
    return 'Failed to upload documents ($code).';
  }

  // ──────────────────────────────────────────────────────────

  Widget _buildPropertiesSection() {
    final properties = mortgageData!['properties'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Properties (${properties.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 12),
          ...properties
              .map((property) => _buildPropertyCard(property))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    final owner = property['owner'] as Map<String, dynamic>? ?? {};

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  property['address'] ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  property['rental_id'] ?? '',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${property['city'] ?? ''}, ${property['state'] ?? ''} ${property['zipcode'] ?? ''}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          if (owner.isNotEmpty) ...[
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text(
              owner['name'] ?? 'N/A',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.phone,
                  size: 12,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  owner['phone'] ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                const FaIcon(
                  FontAwesomeIcons.envelope,
                  size: 12,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    owner['email'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentInfoSection() {
    final paymentHistory =
        mortgageData!['payment_history'] as Map<String, dynamic>? ?? {};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPaymentDateRow(
                  'Last Payment Date',
                  paymentHistory['last_payment_date'] ??
                      mortgageData!['last_payment_date'],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPaymentDateRow(
                  'Next Payment Date',
                  paymentHistory['next_payment_date'] ??
                      mortgageData!['next_payment_date'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPaymentStatCard(
                  'Total Payments Made',
                  '${paymentHistory['total_payments_made'] ?? 0}',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPaymentStatCard(
                  'Missed Payments',
                  '${paymentHistory['missed_payments'] ?? 0}',
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDateRow(String label, String? dateString) {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    String formattedDate = 'N/A';

    if (dateString != null && dateString.isNotEmpty) {
      try {
        final date = DateTime.parse(dateString);
        final apiFormatDate = DateFormat('yyyy-MM-dd').format(date);
        formattedDate = dateProvider.formatCurrentDate(apiFormatDate);
      } catch (e) {
        formattedDate = 'Invalid Date';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formattedDate,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E3A8A),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPayoffHistorySection() {
    final payoffs = mortgageData!['payoffs'] as List<dynamic>? ?? [];
    final dateProvider = Provider.of<DateProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payoff History (${payoffs.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (payoffs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'No payoff history available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                // Table Header
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'Payoff Amount',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'Payoff Date',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Table Rows
                ...payoffs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final payoff = entry.value;
                  final amount = payoff['amount'] ?? 0;
                  final dateString = payoff['date']?.toString() ?? '';
                  String formattedDate = 'N/A';

                  if (dateString.isNotEmpty) {
                    try {
                      final date = DateTime.parse(dateString);
                      final apiFormatDate =
                          DateFormat('yyyy-MM-dd').format(date);
                      formattedDate =
                          dateProvider.formatCurrentDate(apiFormatDate);
                    } catch (e) {
                      formattedDate = 'Invalid Date';
                    }
                  }

                  String addedBy = 'N/A';
                  if (payoff['added_by'] != null) {
                    if (payoff['added_by'] is Map) {
                      final addedByData =
                          payoff['added_by'] as Map<String, dynamic>;
                      final firstName = addedByData['first_name'] ?? '';
                      final lastName = addedByData['last_name'] ?? '';
                      addedBy = '$firstName $lastName'.trim();
                      if (addedBy.isEmpty) addedBy = 'N/A';
                    } else {
                      addedBy = payoff['added_by'].toString();
                    }
                  }

                  final isExpanded = _expandedPayoffIndices.contains(index);

                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedPayoffIndices.remove(index);
                            } else {
                              _expandedPayoffIndices.add(index);
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              left: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                              right: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                              bottom: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    _formatCurrency(amount),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                color: Colors.grey.shade300,
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    formattedDate,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(
                                  isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Expanded section showing "Added By"
                      if (isExpanded)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border(
                              left: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                              right: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                              bottom: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Added By: ',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                addedBy,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ],
            ),
        ],
      ),
    );
  }
}
