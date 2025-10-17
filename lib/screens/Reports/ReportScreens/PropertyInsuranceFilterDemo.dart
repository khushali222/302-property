import 'package:flutter/material.dart';
import '../../../widgets/PropertyInsuranceFilter.dart';
import '../../../constant/constant.dart';

class PropertyInsuranceFilterDemo extends StatefulWidget {
  const PropertyInsuranceFilterDemo({Key? key}) : super(key: key);

  @override
  State<PropertyInsuranceFilterDemo> createState() =>
      _PropertyInsuranceFilterDemoState();
}

class _PropertyInsuranceFilterDemoState
    extends State<PropertyInsuranceFilterDemo> {
  Map<String, dynamic> filterData = {};

  void _onFilterChanged(Map<String, dynamic> data) {
    setState(() {
      filterData = data;
    });
    print('Filter changed: $data');
  }

  void _onRunPressed() {
    print('Run button pressed with data: $filterData');
    // Add your run logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Running report with filters: $filterData'),
        backgroundColor: blueColor,
      ),
    );
  }

  void _onExportPressed() {
    print('Export button pressed with data: $filterData');
    // Add your export logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting report with filters: $filterData'),
        backgroundColor: blueColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Property Insurance Filter Demo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: blueColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Widget
            PropertyInsuranceFilter(
              onFilterChanged: _onFilterChanged,
              onRunPressed: _onRunPressed,
              onExportPressed: _onExportPressed,
            ),

            SizedBox(height: 24),

            // Current filter data display
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Filter Data:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  if (filterData.isEmpty)
                    Text(
                      'No filters applied',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    ...filterData.entries.map((entry) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                '${entry.key}:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value?.toString() ?? 'Not selected',
                                style: TextStyle(
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Usage instructions
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Usage Instructions:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '1. Select Tax Bill Year from the dropdown\n'
                    '2. Select Insured Value Year from the dropdown\n'
                    '3. Choose From and To dates using the date pickers\n'
                    '4. Click "Run" to apply filters and generate report\n'
                    '5. Click "Export" to export the filtered data',
                    style: TextStyle(
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
