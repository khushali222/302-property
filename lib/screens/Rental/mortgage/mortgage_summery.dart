import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/custom_drawer.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../provider/dateProvider.dart';

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
      String? id = prefs.getString('adminId');

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
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.grey.shade50,
      drawer: CustomDrawer(
        currentpage: "Mortgage Summary",
        dropdown: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 8.0),
              child: Padding(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width > 500? 12 : 0,right:  MediaQuery.of(context).size.width > 500? 12 : 0),
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
                  const SizedBox(height: 20),

                  // Properties Section
                  _buildPropertiesSection(),

                  const SizedBox(height: 20),

                  // // Payoff History Section
                  // _buildPayoffHistorySection(),
                  //
                  // const SizedBox(height: 20),

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

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      padding: const EdgeInsets.all(8.0),
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
                            '  Payoff Date',
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
                      final apiFormatDate = DateFormat('yyyy-MM-dd').format(date);
                      formattedDate = dateProvider.formatCurrentDate(apiFormatDate);
                    } catch (e) {
                      formattedDate = 'Invalid Date';
                    }
                  }

                  String addedBy = 'N/A';
                  if (payoff['added_by'] != null) {
                    if (payoff['added_by'] is Map) {
                      final addedByData = payoff['added_by'] as Map<String, dynamic>;
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
                              left: BorderSide(color: Colors.grey.shade300, width: 1),
                              right: BorderSide(color: Colors.grey.shade300, width: 1),
                              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    _formatCurrency(amount),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                              // Container(
                              //   width: 2,
                              //   color: Colors.grey.shade300,
                              // ),
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
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(
                                  isExpanded ? Icons.expand_less : Icons.expand_more,
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
                              left: BorderSide(color: Colors.grey.shade300, width: 1),
                              right: BorderSide(color: Colors.grey.shade300, width: 1),
                              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
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
