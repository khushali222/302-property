import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:three_zero_two_property/Model/SavedReportModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';
import 'package:three_zero_two_property/repository/CustomReportService.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_drawer.dart';
import '../../../widgets/report_header.dart';
import 'CustomReportConstants.dart';

class CreateCustomReportScreen extends StatefulWidget {
  final String adminId;
  final SavedReport? existingReport;

  const CreateCustomReportScreen({
    super.key,
    required this.adminId,
    this.existingReport,
  });

  @override
  State<CreateCustomReportScreen> createState() =>
      _CreateCustomReportScreenState();
}

class _CreateCustomReportScreenState extends State<CreateCustomReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _columnsKey = GlobalKey();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  String? _dateRange;
  bool _customDateRange = false;
  bool _includeHistory = false;
  List<String> _selectedColumns = [];
  String _startDateApi = '';
  String _endDateApi = '';
  String? _columnError;

  @override
  void initState() {
    super.initState();
    if (widget.existingReport != null) {
      final r = widget.existingReport!;
      _nameController.text = r.name;
      _descriptionController.text = r.description;
      _dateRange = r.dateRange.isEmpty ? null : r.dateRange;
      _includeHistory = r.includeHistory;
      _selectedColumns = List.from(r.selectedColumns);
      _startDateApi = r.selectedStartDate ?? '';
      _endDateApi = r.selectedEndDate ?? '';
      final dateProvider = Provider.of<DateProvider>(context, listen: false);
      if (_startDateApi.isNotEmpty) {
        _fromDateController.text =
            dateProvider.formatCurrentDate(_startDateApi);
      }
      if (_endDateApi.isNotEmpty) {
        _toDateController.text = dateProvider.formatCurrentDate(_endDateApi);
      }
    } else {
      _dateRange = 'This Month';
      _applyDateRangePreset('This Month');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  void _applyDateRangePreset(String? value) {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    final now = DateTime.now();

    setState(() {
      _dateRange = value;
      _customDateRange = value == 'Custom Date Range';

      if (value == null || value == 'None') {
        _fromDateController.clear();
        _toDateController.clear();
        _startDateApi = '';
        _endDateApi = '';
        return;
      }
      if (value == 'Today') {
        final s = DateFormat('yyyy-MM-dd').format(now);
        _fromDateController.text = dateProvider.formatCurrentDate(s);
        _toDateController.text = dateProvider.formatCurrentDate(s);
        _startDateApi = s;
        _endDateApi = s;
        return;
      }
      if (value == 'Yesterday') {
        final y = now.subtract(const Duration(days: 1));
        final s = DateFormat('yyyy-MM-dd').format(y);
        _fromDateController.text = dateProvider.formatCurrentDate(s);
        _toDateController.text = dateProvider.formatCurrentDate(s);
        _startDateApi = s;
        _endDateApi = s;
        return;
      }
      if (value == 'Last 7 Days') {
        final start = now.subtract(const Duration(days: 6));
        _startDateApi = DateFormat('yyyy-MM-dd').format(start);
        _endDateApi = DateFormat('yyyy-MM-dd').format(now);
        _fromDateController.text =
            dateProvider.formatCurrentDate(_startDateApi);
        _toDateController.text = dateProvider.formatCurrentDate(_endDateApi);
        return;
      }
      if (value == 'Last 14 Days') {
        final start = now.subtract(const Duration(days: 13));
        _startDateApi = DateFormat('yyyy-MM-dd').format(start);
        _endDateApi = DateFormat('yyyy-MM-dd').format(now);
        _fromDateController.text =
            dateProvider.formatCurrentDate(_startDateApi);
        _toDateController.text = dateProvider.formatCurrentDate(_endDateApi);
        return;
      }
      if (value == 'Last 30 Days') {
        final start = now.subtract(const Duration(days: 29));
        _startDateApi = DateFormat('yyyy-MM-dd').format(start);
        _endDateApi = DateFormat('yyyy-MM-dd').format(now);
        _fromDateController.text =
            dateProvider.formatCurrentDate(_startDateApi);
        _toDateController.text = dateProvider.formatCurrentDate(_endDateApi);
        return;
      }
      if (value == 'This Week') {
        final weekday = now.weekday;
        final weekStart = now.subtract(Duration(days: weekday - 1));
        _startDateApi = DateFormat('yyyy-MM-dd').format(weekStart);
        _endDateApi = DateFormat('yyyy-MM-dd').format(now);
        _fromDateController.text =
            dateProvider.formatCurrentDate(_startDateApi);
        _toDateController.text = dateProvider.formatCurrentDate(_endDateApi);
        return;
      }
      if (value == 'Last Week') {
        final weekday = now.weekday;
        final weekStart = now.subtract(Duration(days: weekday + 6));
        final weekEnd = now.subtract(Duration(days: weekday));
        _startDateApi = DateFormat('yyyy-MM-dd').format(weekStart);
        _endDateApi = DateFormat('yyyy-MM-dd').format(weekEnd);
        _fromDateController.text =
            dateProvider.formatCurrentDate(_startDateApi);
        _toDateController.text = dateProvider.formatCurrentDate(_endDateApi);
        return;
      }
      if (value == 'This Month') {
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 0);
        _startDateApi = DateFormat('yyyy-MM-dd').format(monthStart);
        _endDateApi = DateFormat('yyyy-MM-dd').format(monthEnd);
        _fromDateController.text =
            dateProvider.formatCurrentDate(_startDateApi);
        _toDateController.text = dateProvider.formatCurrentDate(_endDateApi);
        return;
      }
      if (value == 'Last Month') {
        final lastMonthStart = DateTime(now.year, now.month - 1, 1);
        final lastMonthEnd = DateTime(now.year, now.month, 0);
        _startDateApi = DateFormat('yyyy-MM-dd').format(lastMonthStart);
        _endDateApi = DateFormat('yyyy-MM-dd').format(lastMonthEnd);
        _fromDateController.text =
            dateProvider.formatCurrentDate(_startDateApi);
        _toDateController.text = dateProvider.formatCurrentDate(_endDateApi);
        return;
      }
      if (value == 'This Quarter') {
        final q = (now.month - 1) ~/ 3 + 1;
        final quarterStart = DateTime(now.year, (q - 1) * 3 + 1, 1);
        final quarterEnd = DateTime(now.year, q * 3 + 1, 0);
        _startDateApi = DateFormat('yyyy-MM-dd').format(quarterStart);
        _endDateApi = DateFormat('yyyy-MM-dd').format(quarterEnd);
        _fromDateController.text =
            dateProvider.formatCurrentDate(_startDateApi);
        _toDateController.text = dateProvider.formatCurrentDate(_endDateApi);
        return;
      }
      if (value == 'Last Quarter') {
        final q = (now.month - 1) ~/ 3 + 1;
        final lastQ = q == 1 ? 4 : q - 1;
        final lastQYear = q == 1 ? now.year - 1 : now.year;
        final quarterStart = DateTime(lastQYear, (lastQ - 1) * 3 + 1, 1);
        final quarterEnd = DateTime(lastQYear, lastQ * 3 + 1, 0);
        _startDateApi = DateFormat('yyyy-MM-dd').format(quarterStart);
        _endDateApi = DateFormat('yyyy-MM-dd').format(quarterEnd);
        _fromDateController.text =
            dateProvider.formatCurrentDate(_startDateApi);
        _toDateController.text = dateProvider.formatCurrentDate(_endDateApi);
        return;
      }
      if (value == 'Year to Date (YTD)') {
        final yearStart = DateTime(now.year, 1, 1);
        _startDateApi = DateFormat('yyyy-MM-dd').format(yearStart);
        _endDateApi = DateFormat('yyyy-MM-dd').format(now);
        _fromDateController.text =
            dateProvider.formatCurrentDate(_startDateApi);
        _toDateController.text = dateProvider.formatCurrentDate(_endDateApi);
        return;
      }
      if (value == 'Last Year') {
        final lastYearStart = DateTime(now.year - 1, 1, 1);
        final lastYearEnd = DateTime(now.year - 1, 12, 31);
        _startDateApi = DateFormat('yyyy-MM-dd').format(lastYearStart);
        _endDateApi = DateFormat('yyyy-MM-dd').format(lastYearEnd);
        _fromDateController.text =
            dateProvider.formatCurrentDate(_startDateApi);
        _toDateController.text = dateProvider.formatCurrentDate(_endDateApi);
        return;
      }
      if (value == 'Each Calendar Year for the Last 10 Years') {
        final yearStart = DateTime(now.year, 1, 1);
        final yearEnd = DateTime(now.year, 12, 31);
        _startDateApi = DateFormat('yyyy-MM-dd').format(yearStart);
        _endDateApi = DateFormat('yyyy-MM-dd').format(yearEnd);
        _fromDateController.text =
            dateProvider.formatCurrentDate(_startDateApi);
        _toDateController.text = dateProvider.formatCurrentDate(_endDateApi);
        return;
      }
    });
  }

  Future<void> _pickFromDate() async {
    final now = DateTime.now();
    final theme = Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(primary: blueColor),
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDateApi.isNotEmpty
          ? DateTime.tryParse(_startDateApi) ?? now
          : now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1),
      builder: (context, child) => Theme(data: theme, child: child!),
    );
    if (picked != null) {
      final dateProvider = Provider.of<DateProvider>(context, listen: false);
      _startDateApi = DateFormat('yyyy-MM-dd').format(picked);
      _fromDateController.text = dateProvider.formatCurrentDate(_startDateApi);
      setState(() {});
    }
  }

  Future<void> _pickToDate() async {
    final now = DateTime.now();
    final theme = Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(primary: blueColor),
    );
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _endDateApi.isNotEmpty ? DateTime.tryParse(_endDateApi) ?? now : now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1),
      builder: (context, child) => Theme(data: theme, child: child!),
    );
    if (picked != null) {
      final dateProvider = Provider.of<DateProvider>(context, listen: false);
      _endDateApi = DateFormat('yyyy-MM-dd').format(picked);
      _toDateController.text = dateProvider.formatCurrentDate(_endDateApi);
      setState(() {});
    }
  }

  bool _saving = false;

  Future<void> _saveReport() async {
    setState(() {
      _columnError =
          _selectedColumns.isEmpty ? 'Please select at least one column' : null;
    });
    if (!_formKey.currentState!.validate()) return;
    if (_selectedColumns.isEmpty) return;
    setState(() => _saving = true);
    final service = CustomReportService();
    final isEdit = widget.existingReport != null &&
        widget.existingReport!.reportId.isNotEmpty;
    final SaveReportResponse result = isEdit
        ? await service.updateReport(
            adminId: widget.adminId,
            reportId: widget.existingReport!.reportId,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            selectedColumns: _selectedColumns,
            dateRange: _dateRange ?? 'None',
            selectedStartDate: _startDateApi,
            selectedEndDate: _endDateApi,
            includeHistory: _includeHistory,
          )
        : await service.saveReport(
            adminId: widget.adminId,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            selectedColumns: _selectedColumns,
            dateRange: _dateRange ?? 'None',
            selectedStartDate: _startDateApi,
            selectedEndDate: _endDateApi,
            includeHistory: _includeHistory,
            reportId: null,
          );
    setState(() => _saving = false);
    if (!mounted) return;
    if (result.statusCode == 200) {
      Fluttertoast.showToast(
        msg: result.message ??
            (isEdit
                ? 'Report updated successfully.'
                : 'Report saved successfully.'),
        toastLength: Toast.LENGTH_SHORT,
      );
      final popValue = isEdit ? true : (result.data ?? true);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pop(context, popValue);
      });
    } else {
      Fluttertoast.showToast(
        msg: result.message ??
            (isEdit ? 'Failed to update report' : 'Failed to save report'),
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  bool get _isFormValid =>
      _nameController.text.trim().isNotEmpty && _selectedColumns.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(primary: blueColor),
    );
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: widget_302.App_Bar(context: context),
        drawer: CustomDrawer(
          currentpage: "Reports",
          dropdown: false,
        ),
        body: Column(
          children: [
            const ReportHeader(title: "Create Custom Report"),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: blueColor.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Report Name *'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Enter report name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: blueColor),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Report name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('Description'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            hintText: 'Enter description',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: blueColor),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('Date Range'),
                        const SizedBox(height: 8),
                        Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                                  primary: Colors.black87,
                                  onSurface: Colors.black87,
                                ),
                          ),
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    'Select Date Range',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF8A95A8),
                                    ),
                                  ),
                                ),
                                items: customReportDateRangeOptions
                                    .map((e) => DropdownMenuItem<String>(
                                          value: e,
                                          child: Text(
                                            e,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                value: _dateRange,
                                onChanged: (value) =>
                                    _applyDateRangePreset(value),
                                buttonStyleData: const ButtonStyleData(
                                  height: 42,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 300,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateField(
                                label: 'From',
                                controller: _fromDateController,
                                onTap: _customDateRange ? _pickFromDate : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDateField(
                                label: 'To',
                                controller: _toDateController,
                                onTap: _customDateRange ? _pickToDate : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('Columns *'),
                        const SizedBox(height: 8),
                        _buildColumnsDropdown(context),
                        if (_columnError != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _columnError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _buildLabel('Include Historic Values'),
                            const SizedBox(width: 12),
                            SizedBox(
                              height: 28,
                              child: Switch(
                                value: _includeHistory,
                                onChanged: (v) =>
                                    setState(() => _includeHistory = v),
                                activeColor: blueColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _includeHistory ? 'Yes' : 'No',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _saving ? null : _saveReport,
                            icon: _saving
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: SpinKitFadingCircle(
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  )
                                : const Icon(Icons.save, size: 20),
                            label: Text(_saving ? 'Saving...' : 'Save Report'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isFormValid
                                  ? blueColor
                                  : (Colors.grey[400] ?? Colors.grey),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: blueColor,
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: blueColor,
          ),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
              color: onTap != null ? Colors.white : Colors.grey.shade100,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? 'YYYY-MM-DD' : controller.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: controller.text.isEmpty
                          ? Colors.grey[500]
                          : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: onTap != null ? Colors.grey[600]! : Colors.grey[400]!,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showColumnsPicker() {
    setState(() => _columnError = null);
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    void removeOverlay() {
      entry.remove();
    }

    entry = OverlayEntry(
      builder: (ctx) => _ColumnsDropdownOverlay(
        columnsKey: _columnsKey,
        initialSelected: List.from(_selectedColumns),
        onApply: (selected) {
          setState(() {
            _selectedColumns = selected;
            _columnError = null;
          });
        },
        onDismiss: removeOverlay,
      ),
    );
    overlay.insert(entry);
  }

  Widget _buildColumnsDropdown(BuildContext context) {
    return GestureDetector(
      key: _columnsKey,
      onTap: _showColumnsPicker,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: _columnError != null ? Colors.red : Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedColumns.isEmpty
                    ? 'Select columns'
                    : '${_selectedColumns.length} column(s) selected',
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedColumns.isEmpty
                      ? const Color(0xFF8A95A8)
                      : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 24, color: blueColor),
          ],
        ),
      ),
    );
  }
}

class _ColumnsDropdownOverlay extends StatefulWidget {
  final GlobalKey columnsKey;
  final List<String> initialSelected;
  final void Function(List<String>) onApply;
  final VoidCallback onDismiss;

  const _ColumnsDropdownOverlay({
    required this.columnsKey,
    required this.initialSelected,
    required this.onApply,
    required this.onDismiss,
  });

  @override
  State<_ColumnsDropdownOverlay> createState() =>
      _ColumnsDropdownOverlayState();
}

class _ColumnsDropdownOverlayState extends State<_ColumnsDropdownOverlay> {
  late List<String> _selected;
  Offset? _position;
  double? _width;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initialSelected);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box =
          widget.columnsKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && mounted) {
        final pos = box.localToGlobal(Offset.zero);
        setState(() {
          _position = pos;
          _width = box.size.width;
        });
      }
    });
  }

  void _toggle(String key) {
    setState(() {
      if (_selected.contains(key)) {
        _selected.remove(key);
      } else {
        _selected.add(key);
      }
    });
    widget.onApply(List.from(_selected));
  }

  void _selectAll(bool value) {
    setState(() {
      if (value) {
        _selected = List.from(customReportColumnKeys);
      } else {
        _selected = [];
      }
    });
    widget.onApply(List.from(_selected));
  }

  @override
  Widget build(BuildContext context) {
    if (_position == null || _width == null) {
      return const SizedBox.shrink();
    }
    final screenHeight = MediaQuery.of(context).size.height;
    final top = _position!.dy + 44;
    final maxH = (screenHeight - top - 12).clamp(220.0, 400.0);
    final keys = customReportColumnKeys;

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onDismiss,
          child: const SizedBox.expand(),
        ),
        Positioned(
          left: _position!.dx,
          top: top,
          width: _width,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: BoxConstraints(maxHeight: maxH),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      'Select columns',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: blueColor,
                      ),
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding:
                          const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          InkWell(
                            onTap: () => _selectAll(_selected.length !=
                                customReportColumnKeys.length),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _selected.length ==
                                        customReportColumnKeys.length,
                                    tristate: true,
                                    onChanged: (v) => _selectAll(v == true),
                                    activeColor: blueColor,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  const Text('Select All',
                                      style: TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                          ...keys.map((key) => _buildColumnChip(key)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColumnChip(String key) {
    final selected = _selected.contains(key);
    final label = customReportColumnLabels[key] ?? key;
    return InkWell(
      onTap: () => _toggle(key),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: selected,
              onChanged: (_) => _toggle(key),
              activeColor: blueColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
