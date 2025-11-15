import 'package:flutter/material.dart';
import '../../../widgets/LivePropertyReportFilter.dart';
import '../../../constant/constant.dart';

class LivePropertyReportWithNewFilter extends StatefulWidget {
  const LivePropertyReportWithNewFilter({Key? key}) : super(key: key);

  @override
  State<LivePropertyReportWithNewFilter> createState() =>
      _LivePropertyReportWithNewFilterState();
}

class _LivePropertyReportWithNewFilterState
    extends State<LivePropertyReportWithNewFilter> {
  Map<String, dynamic> currentFilters = {};
  List<Map<String, dynamic>> reportData = [];
  bool isLoading = false;

  // Sample data - replace with your actual data source
  List<Map<String, dynamic>> get sampleData => [
        {
          'property': '1200 Commerce Blvd',
          'city': 'Denver',
          'state': 'CO',
          'taxBillYear': '2024',
          'insuredValue': 250000.00,
          'effectiveDate': '2024-01-01',
        },
        {
          'property': '123 Elm Street',
          'city': 'Austin',
          'state': 'TX',
          'taxBillYear': '2024',
          'insuredValue': 300000.00,
          'effectiveDate': '2024-02-01',
        },
        {
          'property': '123 Sunset Boulevard',
          'city': 'Los Angeles',
          'state': 'CA',
          'taxBillYear': '2024',
          'insuredValue': 400000.00,
          'effectiveDate': '2024-03-01',
        },
        {
          'property': '024 Evergreen Lane',
          'city': 'Portland',
          'state': 'OR',
          'taxBillYear': '2024',
          'insuredValue': 350000.00,
          'effectiveDate': '2024-04-01',
        },
        {
          'property': '456 Oak Avenue',
          'city': 'Seattle',
          'state': 'WA',
          'taxBillYear': '2024',
          'insuredValue': 500000.00,
          'effectiveDate': '2024-05-01',
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
      // Apply search filter
      if (filters['searchQuery'] != null &&
          filters['searchQuery'].toString().isNotEmpty) {
        String searchQuery = filters['searchQuery'].toString().toLowerCase();
        if (!item['property'].toString().toLowerCase().contains(searchQuery) &&
            !item['city'].toString().toLowerCase().contains(searchQuery) &&
            !item['state'].toString().toLowerCase().contains(searchQuery)) {
          return false;
        }
      }

      // Apply tax bill year filter
      if (filters['taxBillYear'] != null) {
        if (item['taxBillYear'] != filters['taxBillYear']) {
          return false;
        }
      }

      // Apply date range filter if specified
      if (filters['fromDate'] != null && filters['toDate'] != null) {
        DateTime itemDate = DateTime.parse(item['effectiveDate']);
        DateTime fromDate = filters['fromDate'];
        DateTime toDate = filters['toDate'];

        if (itemDate.isBefore(fromDate) || itemDate.isAfter(toDate)) {
          return false;
        }
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
          'keybrainstech',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: blueColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // Handle menu press
          },
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications, color: Colors.white),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              // Handle notification press
            },
          ),
          Container(
            margin: EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: () {
                // Handle VK button press
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: blueColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text('VK'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Report Title Bar
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: blueColor,
            ),
            child: Center(
              child: Text(
                'Live Property Report',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Filter Section
          Container(
            padding: EdgeInsets.all(16),
            child: LivePropertyReportFilter(
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
                              Icon(
                                Icons.home_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No property data found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: _buildDataTable(),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Column(
      children: [
        // Table Header
        Container(
          decoration: BoxDecoration(
            color: blueColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Table(
            children: [
              TableRow(
                children: [
                  _buildHeaderCell('Property'),
                  _buildHeaderCell('City'),
                  _buildHeaderCell('State'),
                ],
              ),
            ],
          ),
        ),
        // Table Rows
        ...reportData.map((item) => _buildDataRow(item)).toList(),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildDataRow(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Table(
        children: [
          TableRow(
            children: [
              _buildDataCell(item['property']),
              _buildDataCell(item['city']),
              _buildDataCell(item['state']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 14,
        ),
      ),
    );
  }
}
