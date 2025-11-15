import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constant/constant.dart';

class PropertyInsuranceFilter extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;
  final Function() onRunPressed;
  final Function() onExportPressed;
  final String? initialTaxBillYear;
  final String? initialInsuredValueYear;
  final DateTime? initialFromDate;
  final DateTime? initialToDate;

  const PropertyInsuranceFilter({
    Key? key,
    required this.onFilterChanged,
    required this.onRunPressed,
    required this.onExportPressed,
    this.initialTaxBillYear,
    this.initialInsuredValueYear,
    this.initialFromDate,
    this.initialToDate,
  }) : super(key: key);

  @override
  State<PropertyInsuranceFilter> createState() =>
      _PropertyInsuranceFilterState();
}

class _PropertyInsuranceFilterState extends State<PropertyInsuranceFilter> {
  String? selectedTaxBillYear;
  String? selectedInsuredValueYear;
  DateTime? fromDate;
  DateTime? toDate;

  // Generate year options (current year ± 10 years)
  List<String> get yearOptions {
    int currentYear = DateTime.now().year;
    List<String> years = [];
    for (int i = currentYear - 10; i <= currentYear + 10; i++) {
      years.add(i.toString());
    }
    return years;
  }

  @override
  void initState() {
    super.initState();
    selectedTaxBillYear = widget.initialTaxBillYear;
    selectedInsuredValueYear = widget.initialInsuredValueYear;
    fromDate = widget.initialFromDate;
    toDate = widget.initialToDate;
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: blueColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != fromDate) {
      setState(() {
        fromDate = picked;
      });
      _notifyFilterChanged();
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? DateTime.now(),
      firstDate: fromDate ?? DateTime(2000),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: blueColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != toDate) {
      setState(() {
        toDate = picked;
      });
      _notifyFilterChanged();
    }
  }

  void _notifyFilterChanged() {
    widget.onFilterChanged({
      'taxBillYear': selectedTaxBillYear,
      'insuredValueYear': selectedInsuredValueYear,
      'fromDate': fromDate,
      'toDate': toDate,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          // Dark blue header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: blueColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              'Property Insurance Filter',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Filter controls
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Filter row
                Row(
                  children: [
                    // Tax Bill Year
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tax Bill Year',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: selectedTaxBillYear,
                              decoration: InputDecoration(
                                hintText: 'Select year',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('Select year'),
                                ),
                                ...yearOptions.map((year) {
                                  return DropdownMenuItem<String>(
                                    value: year,
                                    child: Text(year),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedTaxBillYear = value;
                                });
                                _notifyFilterChanged();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    // Insured Value Year
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Insured Value Year',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: selectedInsuredValueYear,
                              decoration: InputDecoration(
                                hintText: 'Select year',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('Select year'),
                                ),
                                ...yearOptions.map((year) {
                                  return DropdownMenuItem<String>(
                                    value: year,
                                    child: Text(year),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedInsuredValueYear = value;
                                });
                                _notifyFilterChanged();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    // From Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'From',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _selectFromDate(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      fromDate != null
                                          ? DateFormat('yyyy-MMM-dd')
                                              .format(fromDate!)
                                          : '2025-Oct-01',
                                      style: TextStyle(
                                        color: fromDate != null
                                            ? Colors.black
                                            : Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey[500],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    // To Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'To',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _selectToDate(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      toDate != null
                                          ? DateFormat('yyyy-MMM-dd')
                                              .format(toDate!)
                                          : '2025-Oct-31',
                                      style: TextStyle(
                                        color: toDate != null
                                            ? Colors.black
                                            : Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey[500],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Action buttons
                Row(
                  children: [
                    // Run Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onRunPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blueColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          'Run',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    // Export Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onExportPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blueColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Export',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
