import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constant/constant.dart';

class LivePropertyReportFilter extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;
  final Function() onRunPressed;
  final Function() onExportPressed;
  final String? initialSearchQuery;
  final String? initialTaxBillYear;
  final String? initialInsuredValueYear;
  final DateTime? initialFromDate;
  final DateTime? initialToDate;

  const LivePropertyReportFilter({
    Key? key,
    required this.onFilterChanged,
    required this.onRunPressed,
    required this.onExportPressed,
    this.initialSearchQuery,
    this.initialTaxBillYear,
    this.initialInsuredValueYear,
    this.initialFromDate,
    this.initialToDate,
  }) : super(key: key);

  @override
  State<LivePropertyReportFilter> createState() =>
      _LivePropertyReportFilterState();
}

class _LivePropertyReportFilterState extends State<LivePropertyReportFilter> {
  late TextEditingController _searchController;
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
    _searchController =
        TextEditingController(text: widget.initialSearchQuery ?? '');
    selectedTaxBillYear = widget.initialTaxBillYear;
    selectedInsuredValueYear = widget.initialInsuredValueYear;
    fromDate = widget.initialFromDate;
    toDate = widget.initialToDate;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      'searchQuery': _searchController.text,
      'taxBillYear': selectedTaxBillYear,
      'insuredValueYear': selectedInsuredValueYear,
      'fromDate': fromDate,
      'toDate': toDate,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (value) {
              _notifyFilterChanged();
            },
            decoration: InputDecoration(
              hintText: 'Search by property address, city, or owner...',
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: blueColor),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),

          SizedBox(height: 16),

          // Filter Row
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
                        borderRadius: BorderRadius.circular(8),
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
                        borderRadius: BorderRadius.circular(8),
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
                          borderRadius: BorderRadius.circular(8),
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
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                toDate != null
                                    ? DateFormat('yyyy-MMM-dd').format(toDate!)
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

              SizedBox(width: 16),

              // Run Button
              ElevatedButton(
                onPressed: widget.onRunPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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

              SizedBox(width: 12),

              // Export Button
              ElevatedButton(
                onPressed: widget.onExportPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
            ],
          ),
        ],
      ),
    );
  }
}
