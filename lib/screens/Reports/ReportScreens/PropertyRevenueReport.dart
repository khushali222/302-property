import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/PropertyRevenueReportModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';
import 'package:three_zero_two_property/repository/PropertyRevenueReportService.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import 'package:three_zero_two_property/widgets/report_header.dart';
import '../../../widgets/custom_drawer.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as syncXlsx;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:three_zero_two_property/repository/GetAdminAddressPdf.dart';
import 'package:three_zero_two_property/Model/profile.dart';
import 'package:flutter/services.dart' show rootBundle;

class PropertyRevenueReport extends StatefulWidget {
  @override
  State<PropertyRevenueReport> createState() => _PropertyRevenueReportState();
}

class _PropertyRevenueReportState extends State<PropertyRevenueReport> {
  late Future<PropertyRevenueReportModel> _futurePropertyRevenueReport =
      Future.value(PropertyRevenueReportModel());
  PropertyRevenueReportModel? propertyRevenueReportModel;
  bool isLoading = true;
  String? errorMessage;
  ConnectivityResult? _connectivityResult;

  // Track which property is expanded
  int? expandedPropertyIndex;

  // Date controllers
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  // Date range dropdown
  String? dateRange;
  bool customDateRange = false;

  // API date formats (yyyy-MM-dd)
  String _currentStartDate = '';
  String _currentEndDate = '';
  String _previousStartDate = '';
  String _previousEndDate = '';

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectivityResult = result;
      });
    });
    checkInternet();
    _initializeDates();
    // Fetch data after dates are initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _futurePropertyRevenueReport = fetchPropertyRevenueReportData();
    });
  }

  void _initializeDates() {
    final now = DateTime.now();
    final dateProvider = Provider.of<DateProvider>(context, listen: false);

    // Set default to "This Month"
    dateRange = 'This Month';
    customDateRange = false;

    final currentStart = DateTime(now.year, now.month, 1);
    final currentEnd = DateTime(now.year, now.month + 1, 0);

    _currentStartDate = DateFormat('yyyy-MM-dd').format(currentStart);
    _currentEndDate = DateFormat('yyyy-MM-dd').format(currentEnd);

    // Calculate previous period (same period last year)
    _calculatePreviousPeriod();

    setState(() {
      fromDateController.text =
          dateProvider.formatCurrentDate(_currentStartDate);
      toDateController.text = dateProvider.formatCurrentDate(_currentEndDate);
    });
  }

  void _calculatePreviousPeriod() {
    if (_currentStartDate.isNotEmpty && _currentEndDate.isNotEmpty) {
      try {
        final currentStart = DateTime.parse(_currentStartDate);
        final currentEnd = DateTime.parse(_currentEndDate);

        // Calculate same period last year
        final previousStart = DateTime(
          currentStart.year - 1,
          currentStart.month,
          currentStart.day,
        );
        final previousEnd = DateTime(
          currentEnd.year - 1,
          currentEnd.month,
          currentEnd.day,
        );

        _previousStartDate = DateFormat('yyyy-MM-dd').format(previousStart);
        _previousEndDate = DateFormat('yyyy-MM-dd').format(previousEnd);
      } catch (e) {
        print('Error calculating previous period: $e');
      }
    }
  }

  void _handleDateRangeChange(String? value) {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    final now = DateTime.now();

    setState(() {
      dateRange = value;
      if (value == 'This Month') {
        customDateRange = false;
        DateTime monthStart = DateTime(now.year, now.month, 1);
        DateTime monthEnd = DateTime(now.year, now.month + 1, 0);
        String monthStartApiFormat =
            DateFormat('yyyy-MM-dd').format(monthStart);
        String monthEndApiFormat = DateFormat('yyyy-MM-dd').format(monthEnd);
        fromDateController.text =
            dateProvider.formatCurrentDate(monthStartApiFormat);
        toDateController.text =
            dateProvider.formatCurrentDate(monthEndApiFormat);
        _currentStartDate = monthStartApiFormat;
        _currentEndDate = monthEndApiFormat;
        _calculatePreviousPeriod();
      } else if (value == 'This Quarter') {
        customDateRange = false;
        int currentQuarter = (now.month - 1) ~/ 3 + 1;
        DateTime quarterStart =
            DateTime(now.year, (currentQuarter - 1) * 3 + 1, 1);
        DateTime quarterEnd = DateTime(now.year, currentQuarter * 3 + 1, 0);
        String quarterStartApiFormat =
            DateFormat('yyyy-MM-dd').format(quarterStart);
        String quarterEndApiFormat =
            DateFormat('yyyy-MM-dd').format(quarterEnd);
        fromDateController.text =
            dateProvider.formatCurrentDate(quarterStartApiFormat);
        toDateController.text =
            dateProvider.formatCurrentDate(quarterEndApiFormat);
        _currentStartDate = quarterStartApiFormat;
        _currentEndDate = quarterEndApiFormat;
        _calculatePreviousPeriod();
      } else if (value == 'Year to Date') {
        customDateRange = false;
        DateTime yearStart = DateTime(now.year, 1, 1);
        String yearStartApiFormat = DateFormat('yyyy-MM-dd').format(yearStart);
        String yearEndApiFormat = DateFormat('yyyy-MM-dd').format(now);
        fromDateController.text =
            dateProvider.formatCurrentDate(yearStartApiFormat);
        toDateController.text =
            dateProvider.formatCurrentDate(yearEndApiFormat);
        _currentStartDate = yearStartApiFormat;
        _currentEndDate = yearEndApiFormat;
        _calculatePreviousPeriod();
      } else if (value == 'Each Calendar Year for the Last 10 Years') {
        customDateRange = false;
        // Set to current year (most recent)
        DateTime yearStart = DateTime(now.year, 1, 1);
        DateTime yearEnd = DateTime(now.year, 12, 31);
        String yearStartApiFormat = DateFormat('yyyy-MM-dd').format(yearStart);
        String yearEndApiFormat = DateFormat('yyyy-MM-dd').format(yearEnd);
        fromDateController.text =
            dateProvider.formatCurrentDate(yearStartApiFormat);
        toDateController.text =
            dateProvider.formatCurrentDate(yearEndApiFormat);
        _currentStartDate = yearStartApiFormat;
        _currentEndDate = yearEndApiFormat;
        _calculatePreviousPeriod();
      } else if (value == 'Custom Date Range') {
        customDateRange = true;
      }
    });
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  Future<PropertyRevenueReportModel> fetchPropertyRevenueReportData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? adminId = prefs.getString("adminId");

      if (adminId == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'Admin ID not found. Please login again.';
        });
        return PropertyRevenueReportModel(
          statusCode: 401,
          message: 'Admin ID not found. Please login again.',
        );
      }

      PropertyRevenueReportModel data =
          await PropertyRevenueReportService().fetchPropertyRevenueReport(
        adminId: adminId,
        currentStartDate: _currentStartDate,
        currentEndDate: _currentEndDate,
        previousStartDate: _previousStartDate,
        previousEndDate: _previousEndDate,
      );

      setState(() {
        propertyRevenueReportModel = data;
        isLoading = false;
        errorMessage = data.statusCode != 200 ? data.message : null;
      });
      return data;
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage =
            'Failed to load property revenue report. Please try again later.';
      });
      return PropertyRevenueReportModel(
        statusCode: 0,
        message:
            'Failed to load property revenue report. Please try again later.',
      );
    }
  }

  void _refreshData() {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    _futurePropertyRevenueReport = fetchPropertyRevenueReportData();
  }

  Future<void> _pickFromDate(BuildContext context) async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentStartDate.isNotEmpty
          ? DateTime.parse(_currentStartDate)
          : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: blueColor,
            colorScheme: ColorScheme.light(
              primary: blueColor,
            ),
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      String apiFormatDate = DateFormat('yyyy-MM-dd').format(picked);
      String displayDate = dateProvider.formatCurrentDate(apiFormatDate);
      setState(() {
        fromDateController.text = displayDate;
        _currentStartDate = apiFormatDate;
        _calculatePreviousPeriod();
      });
    }
  }

  Future<void> _pickToDate(BuildContext context) async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentEndDate.isNotEmpty
          ? DateTime.parse(_currentEndDate)
          : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: blueColor,
            colorScheme: ColorScheme.light(
              primary: blueColor,
            ),
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      String apiFormatDate = DateFormat('yyyy-MM-dd').format(picked);
      String displayDate = dateProvider.formatCurrentDate(apiFormatDate);
      setState(() {
        toDateController.text = displayDate;
        _currentEndDate = apiFormatDate;
        _calculatePreviousPeriod();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Reports",
        dropdown: false,
      ),
      appBar: widget_302.App_Bar(context: context),
      body: _connectivityResult == ConnectivityResult.none
          ? Column(
              children: [
                ReportHeader(title: "Property Revenue Report"),
                Expanded(child: _buildNoInternetWidget()),
              ],
            )
          : Column(
              children: [
                ReportHeader(title: "Property Revenue Report"),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Filters Section
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: _buildFiltersSection(),
                        ),
                        _buildReportContent(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNoInternetWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/no_internet.json',
            width: 200,
            height: 200,
          ),
          Text(
            'No Internet Connection',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Please check your internet connection and try again',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              checkInternet();
              _refreshData();
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    return FutureBuilder<PropertyRevenueReportModel>(
      future: _futurePropertyRevenueReport,
      builder: (context, snapshot) {
        if (isLoading && !snapshot.hasData) {
          return _buildLoadingWidget();
        }

        if (errorMessage != null) {
          return _buildErrorWidget();
        }

        if (propertyRevenueReportModel?.data == null ||
            propertyRevenueReportModel!.data!.properties == null ||
            propertyRevenueReportModel!.data!.properties!.isEmpty) {
          return _buildNoDataWidget();
        }

        return _buildDataTable();
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCircle(
            color: blueColor,
            size: 50.0,
          ),
          SizedBox(height: 20),
          Text(
            'Loading Property Revenue Report...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          SizedBox(height: 16),
          Text(
            'Error Loading Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            errorMessage ?? 'An unknown error occurred',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _refreshData,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No Property Revenue Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'There is no property revenue data to display for the selected periods',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Range Dropdown
          Text(
            'Date Range',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: dateRange,
                isExpanded: true,
                padding: EdgeInsets.symmetric(horizontal: 16),
                hint: Text(
                  'Date Range',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'This Month',
                    child: Text('This Month'),
                  ),
                  DropdownMenuItem(
                    value: 'This Quarter',
                    child: Text('This Quarter'),
                  ),
                  DropdownMenuItem(
                    value: 'Year to Date',
                    child: Text('Year to Date'),
                  ),
                  DropdownMenuItem(
                    value: 'Each Calendar Year for the Last 10 Years',
                    child: Text('Each Calendar Year for the Last 10 Years'),
                  ),
                  DropdownMenuItem(
                    value: 'Custom Date Range',
                    child: Text('Custom Date Range'),
                  ),
                ],
                onChanged: _handleDateRangeChange,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          // From Date (always visible)
          SizedBox(height: 10),
          _buildDateField(
            controller: fromDateController,
            label: 'From',
            onTap: customDateRange ? () => _pickFromDate(context) : null,
            enabled: customDateRange,
          ),
          // To Date (always visible)
          SizedBox(height: 10),
          _buildDateField(
            controller: toDateController,
            label: 'To',
            onTap: customDateRange ? () => _pickToDate(context) : null,
            enabled: customDateRange,
          ),
          SizedBox(height: 20),
          // Run and Export Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    _futurePropertyRevenueReport =
                        fetchPropertyRevenueReportData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blueColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Run',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blueColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: PopupMenuButton<String>(
                    onSelected: (value) async {
                      final properties =
                          propertyRevenueReportModel?.data?.properties ?? [];
                      if (properties.isEmpty) {
                        Fluttertoast.showToast(
                          msg: 'No data to export',
                          toastLength: Toast.LENGTH_SHORT,
                        );
                        return;
                      }
                      if (value == 'PDF') {
                        await _generatePdf(properties);
                      } else if (value == 'XLSX') {
                        await _generateExcel(properties);
                      } else if (value == 'CSV') {
                        await _generateCsv(properties);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'PDF',
                        child: Text('PDF'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'XLSX',
                        child: Text('XLSX'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'CSV',
                        child: Text('CSV'),
                      ),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Export',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 5),
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: enabled ? Colors.white : Colors.grey[100],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? label : controller.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: controller.text.isEmpty
                          ? Colors.grey[500]
                          : (enabled ? Colors.black : Colors.grey[700]),
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: enabled ? Colors.grey[600] : Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    final properties = propertyRevenueReportModel!.data!.properties ?? [];
    final summary = propertyRevenueReportModel!.data!.summary;

    return Column(
      children: [
        //   SizedBox(height: 20),
        // Summary Cards
        // if (summary != null) _buildSummaryCards(summary),
        // SizedBox(height: 20),
        // Expandable Property Cards
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Color(0xFFF7F9FC),
            border: Border(
              top: BorderSide(color: Colors.grey[300]!),
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Property',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: blueColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: properties.asMap().entries.map((entry) {
              int index = entry.key;
              PropertyRevenue property = entry.value;
              return _buildExpandablePropertyCard(property, index);
            }).toList(),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSummaryCards(PropertyRevenueSummary summary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Current Revenue',
              '\$${NumberFormat('#,##0.00').format(summary.totalCurrentRevenue ?? 0)}',
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _buildSummaryCard(
              'Total Previous Revenue',
              '\$${NumberFormat('#,##0.00').format(summary.totalPreviousRevenue ?? 0)}',
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _buildSummaryCard(
              'Change',
              '\$${NumberFormat('#,##0.00').format(summary.totalRevenueChangeAmount ?? 0)}\n(${NumberFormat('#,##0.00').format(summary.totalRevenueChangePercentage ?? 0)}%)',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: blueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandablePropertyCard(PropertyRevenue property, int index) {
    final isExpanded = expandedPropertyIndex == index;
    final dateProvider = Provider.of<DateProvider>(context, listen: false);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Collapsed Header
          InkWell(
            onTap: () {
              setState(() {
                expandedPropertyIndex = isExpanded ? null : index;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      property.rentalAddress ?? 'N/A',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: blueColor,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          // Expanded Content
          if (isExpanded)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  // Current Period Revenue
                  _buildRevenueSection(
                    title: 'Current Period Revenue',
                    period: property.currentPeriod,
                    dateProvider: dateProvider,
                  ),
                  SizedBox(height: 16),
                  // Previous Period Revenue
                  _buildRevenueSection(
                    title: 'Previous Period Revenue',
                    period: property.previousPeriod,
                    dateProvider: dateProvider,
                  ),
                  // SizedBox(height: 16),
                  // // Change Amount and Percentage
                  // if (property.revenueChangeAmount != null ||
                  //     property.revenueChangePercentage != null)
                  //   _buildChangeSection(property),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRevenueSection({
    required String title,
    required PeriodData? period,
    required DateProvider dateProvider,
  }) {
    final revenue = period?.revenue ?? 0;
    final startDate = period?.startDate ?? '';
    final endDate = period?.endDate ?? '';

    String formattedStartDate = '';
    String formattedEndDate = '';
    if (startDate.isNotEmpty && endDate.isNotEmpty) {
      try {
        formattedStartDate = dateProvider.formatCurrentDate(startDate);
        formattedEndDate = dateProvider.formatCurrentDate(endDate);
      } catch (e) {
        formattedStartDate = startDate;
        formattedEndDate = endDate;
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              if (formattedStartDate.isNotEmpty &&
                  formattedEndDate.isNotEmpty) ...[
                SizedBox(height: 4),
                Text(
                  '$formattedStartDate - $formattedEndDate',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        Text(
          '\$${NumberFormat('#,##0.00').format(revenue)}',
          style: TextStyle(
            fontSize: 14,
            //   fontWeight: FontWeight.bold,
            color: blueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildChangeSection(PropertyRevenue property) {
    final changeAmount = property.revenueChangeAmount ?? 0;
    final changePercentage = property.revenueChangePercentage ?? 0;
    Color changeColor = changeAmount >= 0 ? Colors.green : Colors.red;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: changeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Revenue Change',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${NumberFormat('#,##0.00').format(changeAmount.abs())}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: changeColor,
                ),
              ),
              Text(
                '(${NumberFormat('#,##0.00').format(changePercentage)}%)',
                style: TextStyle(
                  fontSize: 12,
                  color: changeColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Export Methods
  Future<void> _generatePdf(List<PropertyRevenue> properties) async {
    try {
      GetAddressAdminPdfService service = GetAddressAdminPdfService();
      profile? profileData;

      try {
        profileData = await service.fetchAdminAddress();
      } catch (e) {
        print("Error fetching profile data: $e");
        Fluttertoast.showToast(
          msg: 'Error fetching profile data',
          toastLength: Toast.LENGTH_SHORT,
        );
        return;
      }

      // Load logo
      final image = pw.MemoryImage(
        (await rootBundle.load('assets/images/applogo.png'))
            .buffer
            .asUint8List(),
      );

      // Format date and time for footer
      final DateTime now = DateTime.now();
      final String formattedDateTime =
          DateFormat('dd/MMM/yyyy hh:mm:ss a').format(now);

      // Format date ranges for header
      final dateProvider = Provider.of<DateProvider>(context, listen: false);
      String formattedCurrentStartDate = '';
      String formattedCurrentEndDate = '';
      String formattedPreviousStartDate = '';
      String formattedPreviousEndDate = '';

      if (_currentStartDate.isNotEmpty && _currentEndDate.isNotEmpty) {
        try {
          formattedCurrentStartDate =
              dateProvider.formatCurrentDate(_currentStartDate);
          formattedCurrentEndDate =
              dateProvider.formatCurrentDate(_currentEndDate);
        } catch (e) {
          formattedCurrentStartDate = _currentStartDate;
          formattedCurrentEndDate = _currentEndDate;
        }
      }

      if (_previousStartDate.isNotEmpty && _previousEndDate.isNotEmpty) {
        try {
          formattedPreviousStartDate =
              dateProvider.formatCurrentDate(_previousStartDate);
          formattedPreviousEndDate =
              dateProvider.formatCurrentDate(_previousEndDate);
        } catch (e) {
          formattedPreviousStartDate = _previousStartDate;
          formattedPreviousEndDate = _previousEndDate;
        }
      }

      final pdf = pw.Document();
      final summary = propertyRevenueReportModel!.data!.summary;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (pw.Context context) {
            if (context.pageNumber == 1) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 20),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Logo in top-left
                    pw.Image(image, width: 40, height: 40),
                    // Title and Date range in center
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Text(
                            'Property Revenue Report',
                            style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'Date - $formattedCurrentStartDate to $formattedCurrentEndDate',
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.black,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    // Company name and page number in top-right
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text(
                          profileData?.companyName?.isNotEmpty == true
                              ? profileData!.companyName!
                              : 'N/A',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '${context.pageNumber}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return pw.SizedBox.shrink();
          },
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 20),
              child: pw.Text(
                'Generated on: $formattedDateTime',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.black,
                ),
              ),
            );
          },
          build: (pw.Context context) {
            // Build table header row (will repeat on every page)
            final tableHeaderRow = pw.TableRow(
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex("#5A86D5"),
              ),
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(10),
                  child: pw.Text(
                    'Property',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.only(
                      top: 10, bottom: 4, left: 10, right: 10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(
                        'Current Period Revenue',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                          fontSize: 12,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '$formattedCurrentStartDate - $formattedCurrentEndDate',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.only(
                      top: 10, bottom: 4, left: 10, right: 10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(
                        'Previous Period Revenue',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                          fontSize: 12,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '$formattedPreviousStartDate - $formattedPreviousEndDate',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            // Build table data (only 3 columns: Property, Current, Previous)
            final List<List<dynamic>> tableData = [];

            for (var property in properties) {
              final currentRev = property.currentPeriod?.revenue ?? 0;
              final previousRev = property.previousPeriod?.revenue ?? 0;

              tableData.add([
                property.rentalAddress ?? 'N/A',
                '\$${NumberFormat('#,##0.00').format(currentRev)}',
                '\$${NumberFormat('#,##0.00').format(previousRev)}',
              ]);
            }

            // Total Revenue row (only on last page)
            final totalRow = pw.TableRow(
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Total Revenue',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                      color: PdfColors.black,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    '\$${NumberFormat('#,##0.00').format(summary?.totalCurrentRevenue ?? 0)}',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                      color: PdfColors.black,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    '\$${NumberFormat('#,##0.00').format(summary?.totalPreviousRevenue ?? 0)}',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ],
            );

            return [
              // Table with header row that repeats on every page
              pw.Table(
                border: pw.TableBorder(
                  horizontalInside: pw.BorderSide(
                    color: PdfColors.grey300,
                    width: 0.5,
                  ),
                  bottom: pw.BorderSide(
                    color: PdfColors.grey300,
                    width: 0.5,
                  ),
                ),
                columnWidths: {
                  0: pw.FlexColumnWidth(2), // Property
                  1: pw.FlexColumnWidth(1), // Current Revenue
                  2: pw.FlexColumnWidth(1), // Previous Revenue
                },
                children: [
                  // Header row with date ranges (will repeat on every page)
                  tableHeaderRow,
                  // Data rows
                  ...tableData.map((row) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            row[0].toString(),
                            style: pw.TextStyle(
                              fontSize: 11,
                              color: PdfColors.black,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            row[1].toString(),
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              fontSize: 11,
                              color: PdfColors.black,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            row[2].toString(),
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              fontSize: 11,
                              color: PdfColors.black,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  // Total Revenue row (only appears at the end)
                  totalRow,
                ],
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        format: PdfPageFormat.a4,
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      print('Error generating PDF: $e');
      Fluttertoast.showToast(
        msg: 'Error generating PDF',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> _generateExcel(List<PropertyRevenue> properties) async {
    try {
      final syncXlsx.Workbook workbook = syncXlsx.Workbook();
      final syncXlsx.Worksheet sheet = workbook.worksheets[0];

      // Headers
      sheet.getRangeByIndex(1, 1).setText('Property');
      sheet.getRangeByIndex(1, 2).setText('Current Revenue');
      sheet.getRangeByIndex(1, 3).setText('Previous Revenue');
      sheet.getRangeByIndex(1, 4).setText('Change Amount');
      sheet.getRangeByIndex(1, 5).setText('Change Percentage');

      // Style headers
      final syncXlsx.Style headerStyle = workbook.styles.add('headerStyle');
      headerStyle.backColor = '#5A86D5';
      headerStyle.fontColor = '#FFFFFF';
      headerStyle.bold = true;
      sheet.getRangeByIndex(1, 1, 1, 5).cellStyle = headerStyle;

      int rowIndex = 2;
      final summary = propertyRevenueReportModel!.data!.summary;

      for (var property in properties) {
        sheet
            .getRangeByIndex(rowIndex, 1)
            .setText(property.rentalAddress ?? 'N/A');
        sheet
            .getRangeByIndex(rowIndex, 2)
            .setNumber(property.currentPeriod?.revenue ?? 0);
        sheet
            .getRangeByIndex(rowIndex, 3)
            .setNumber(property.previousPeriod?.revenue ?? 0);
        sheet
            .getRangeByIndex(rowIndex, 4)
            .setNumber(property.revenueChangeAmount ?? 0);
        sheet
            .getRangeByIndex(rowIndex, 5)
            .setNumber(property.revenueChangePercentage ?? 0);
        rowIndex++;
      }

      // Grand Total
      sheet.getRangeByIndex(rowIndex, 1).setText('Grand Total');
      sheet.getRangeByIndex(rowIndex, 1).cellStyle.bold = true;
      sheet
          .getRangeByIndex(rowIndex, 2)
          .setNumber(summary?.totalCurrentRevenue ?? 0);
      sheet.getRangeByIndex(rowIndex, 2).cellStyle.bold = true;
      sheet
          .getRangeByIndex(rowIndex, 3)
          .setNumber(summary?.totalPreviousRevenue ?? 0);
      sheet.getRangeByIndex(rowIndex, 3).cellStyle.bold = true;
      sheet
          .getRangeByIndex(rowIndex, 4)
          .setNumber(summary?.totalRevenueChangeAmount ?? 0);
      sheet.getRangeByIndex(rowIndex, 4).cellStyle.bold = true;
      sheet
          .getRangeByIndex(rowIndex, 5)
          .setNumber(summary?.totalRevenueChangePercentage ?? 0);
      sheet.getRangeByIndex(rowIndex, 5).cellStyle.bold = true;

      // Auto-fit columns
      for (int i = 1; i <= 5; i++) {
        sheet.autoFitColumn(i);
      }

      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final DateTime now = DateTime.now();
      final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
      final String fileName = 'PropertyRevenueReport_$formattedDate.xlsx';

      final Directory directory = Platform.isIOS
          ? await getApplicationDocumentsDirectory()
          : Directory('/storage/emulated/0/Download');

      final path = '${directory.path}/$fileName';

      if (!await directory.exists() && !Platform.isIOS) {
        await directory.create(recursive: true);
      }

      final File file = File(path);
      await file.writeAsBytes(bytes, flush: true);
      Share.shareXFiles([XFile(path)]);
      Fluttertoast.showToast(
        msg: 'Excel file saved to $path',
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      print('Error generating Excel: $e');
      Fluttertoast.showToast(
        msg: 'Error generating Excel',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> _generateCsv(List<PropertyRevenue> properties) async {
    try {
      final List<String> headers = [
        'Property',
        'Current Revenue',
        'Previous Revenue',
        'Change Amount',
        'Change Percentage',
      ];

      final StringBuffer csvBuffer = StringBuffer();
      csvBuffer.writeln(headers.join(','));

      final summary = propertyRevenueReportModel!.data!.summary;

      for (var property in properties) {
        final String sanitizedAddress =
            (property.rentalAddress ?? 'N/A').replaceAll(',', ' ');

        csvBuffer.writeln([
          sanitizedAddress,
          NumberFormat('#,##0.00').format(property.currentPeriod?.revenue ?? 0),
          NumberFormat('#,##0.00')
              .format(property.previousPeriod?.revenue ?? 0),
          NumberFormat('#,##0.00').format(property.revenueChangeAmount ?? 0),
          NumberFormat('#,##0.00')
              .format(property.revenueChangePercentage ?? 0),
        ].join(','));
      }

      // Add grand total
      csvBuffer.writeln([
        'Grand Total',
        NumberFormat('#,##0.00').format(summary?.totalCurrentRevenue ?? 0),
        NumberFormat('#,##0.00').format(summary?.totalPreviousRevenue ?? 0),
        NumberFormat('#,##0.00').format(summary?.totalRevenueChangeAmount ?? 0),
        NumberFormat('#,##0.00')
            .format(summary?.totalRevenueChangePercentage ?? 0),
      ].join(','));

      final DateTime now = DateTime.now();
      final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
      final String fileName = 'PropertyRevenueReport_$formattedDate.csv';

      final Directory directory = Platform.isIOS
          ? await getApplicationDocumentsDirectory()
          : Directory('/storage/emulated/0/Download');

      final path = '${directory.path}/$fileName';

      if (!await directory.exists() && !Platform.isIOS) {
        await directory.create(recursive: true);
      }

      final File file = File(path);
      await file.writeAsString(csvBuffer.toString(), flush: true);
      Share.shareXFiles([XFile(path)]);
      Fluttertoast.showToast(
        msg: 'CSV file saved to $path',
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      print('Error generating CSV: $e');
      Fluttertoast.showToast(
        msg: 'Error generating CSV',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }
}
