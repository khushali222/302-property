import 'package:flutter/material.dart';
import '../../../widgets/PropertyInsuranceFilter.dart';
import '../../../constant/constant.dart';

class PropertyInsuranceReportWithFilter extends StatefulWidget {
  const PropertyInsuranceReportWithFilter({Key? key}) : super(key: key);

  @override
  State<PropertyInsuranceReportWithFilter> createState() =>
      _PropertyInsuranceReportWithFilterState();
}

class _PropertyInsuranceReportWithFilterState
    extends State<PropertyInsuranceReportWithFilter> {
  Map<String, dynamic> currentFilters = {};
  List<Map<String, dynamic>> reportData = [];
  bool isLoading = false;

  // Sample data - replace with your actual data source
  List<Map<String, dynamic>> get sampleData => [
        {
          'company': 'ABC Insurance Co.',
          'policyNumber': 'POL-001-2024',
          'propertyAddress': '123 Main St, City, State',
          'coverageAmount': 250000.00,
          'premium': 1200.00,
          'effectiveDate': '2024-01-01',
          'expirationDate': '2024-12-31',
        },
        {
          'company': 'XYZ Insurance Group',
          'policyNumber': 'POL-002-2024',
          'propertyAddress': '456 Oak Ave, City, State',
          'coverageAmount': 300000.00,
          'premium': 1500.00,
          'effectiveDate': '2024-02-01',
          'expirationDate': '2025-01-31',
        },
        {
          'company': 'DEF Insurance Ltd.',
          'policyNumber': 'POL-003-2024',
          'propertyAddress': '789 Pine St, City, State',
          'coverageAmount': 400000.00,
          'premium': 2000.00,
          'effectiveDate': '2024-03-01',
          'expirationDate': '2025-02-28',
        },
      ];

  @override
  void initState() {
    super.initState();
    reportData = sampleData;
  }

  void _onFilterChanged(Map<String, dynamic> filters) {
    setState(() {
      currentFilters = filters;
    });
    print('Filters updated: $filters');
  }

  void _onRunPressed() {
    setState(() {
      isLoading = true;
    });

    // Simulate API call or data processing
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
        // Apply filters to data (in real implementation, this would be done server-side)
        reportData = _applyFilters(sampleData, currentFilters);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report generated with ${reportData.length} records'),
          backgroundColor: blueColor,
        ),
      );
    });
  }

  void _onExportPressed() {
    // Show export options
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Export Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: blueColor,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: blueColor),
              title: Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                _exportAsPDF();
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart, color: blueColor),
              title: Text('Export as Excel'),
              onTap: () {
                Navigator.pop(context);
                _exportAsExcel();
              },
            ),
            ListTile(
              leading: Icon(Icons.description, color: blueColor),
              title: Text('Export as CSV'),
              onTap: () {
                Navigator.pop(context);
                _exportAsCSV();
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _applyFilters(
      List<Map<String, dynamic>> data, Map<String, dynamic> filters) {
    // In a real implementation, this would be done server-side
    // This is just a simple client-side filter example
    return data.where((item) {
      // Apply date range filter if specified
      if (filters['fromDate'] != null && filters['toDate'] != null) {
        DateTime itemDate = DateTime.parse(item['effectiveDate']);
        DateTime fromDate = filters['fromDate'];
        DateTime toDate = filters['toDate'];

        if (itemDate.isBefore(fromDate) || itemDate.isAfter(toDate)) {
          return false;
        }
      }

      // Apply year filters if specified
      if (filters['taxBillYear'] != null) {
        // Add your tax bill year logic here
      }

      if (filters['insuredValueYear'] != null) {
        // Add your insured value year logic here
      }

      return true;
    }).toList();
  }

  void _exportAsPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting as PDF...')),
    );
  }

  void _exportAsExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting as Excel...')),
    );
  }

  void _exportAsCSV() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting as CSV...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Property Insurance Report',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: blueColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: EdgeInsets.all(16),
            child: PropertyInsuranceFilter(
              onFilterChanged: _onFilterChanged,
              onRunPressed: _onRunPressed,
              onExportPressed: _onExportPressed,
            ),
          ),

          // Report Content
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: blueColor),
                          SizedBox(height: 16),
                          Text(
                            'Generating report...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : reportData.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              
                              SizedBox(height: 16),
                              Text(
                                'No insurance data found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Insurance Policies (${reportData.length} records)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: blueColor,
                                ),
                              ),
                              SizedBox(height: 16),
                              ...reportData
                                  .map((item) => _buildPolicyCard(item))
                                  .toList(),
                            ],
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard(Map<String, dynamic> policy) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                policy['company'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: blueColor,
                ),
              ),
              Text(
                'Policy: ${policy['policyNumber']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            policy['propertyAddress'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Coverage',
                  '\$${policy['coverageAmount'].toStringAsFixed(0)}',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Premium',
                  '\$${policy['premium'].toStringAsFixed(0)}',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Effective',
                  policy['effectiveDate'],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
