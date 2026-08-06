import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:three_zero_two_property/Model/LeaseLedgerModel.dart';
import 'package:three_zero_two_property/Model/tenants.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';
import 'package:three_zero_two_property/repository/tenantDetail_payment/tenant_payment_repo.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────

const _kNavy = Color.fromRGBO(21, 43, 81, 1);
const _kBg = Color(0xFFF0F3F8);
const _kCardBg = Colors.white;
const _kBorder = Color(0xFFDDE3EC);
const _kGray = Color(0xFF8A9BB0);
const _kSectionLabel = Color(0xFF7A8CA0);
const _kEntryBg = Color(0xFFF2F5F8);
const _kGreen = Color(0xFF1E8A4C);
const _kCheckGreen = Color(0xFF3AAF6E);
const _kFailRed = Color(0xFFCC3333);
const _kTenantBadgeBg = Color(0xFFEDE9F8);
const _kTenantBadge = Color(0xFF9B8EC4);
const _kCountBg = Color(0xFFC6E8C4);
const _kCountText = Color(0xFF2A7A2A);
const _kTagBg = Color(0xFFE8EEFB);
const _kTag = Color(0xFF3B6FD4);
const _kIconBg = Color(0xFFEEF2FB);

// ─── Widget ───────────────────────────────────────────────────────────────────

class FinancialTable extends StatefulWidget {
  final String tenantId;
  final String? tenantName;
  final List<TenantLeaseData>? leases;
  /// When set, pre-selects this lease ID instead of defaulting to the active lease.
  final String? initialLeaseId;

  const FinancialTable({
    Key? key,
    required this.tenantId,
    this.tenantName,
    this.leases,
    this.initialLeaseId,
  }) : super(key: key);

  @override
  State<FinancialTable> createState() => _FinancialTableState();
}

class _FinancialTableState extends State<FinancialTable> {
  final _repo = TenantLeaseRepository();

  TenantLeaseData? _selectedLease;
  String _activeTab = 'ledger'; // 'ledger' | 'tenant'

  final _searchCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();

  List<Data> _allLedger = [];
  List<Data> _tenantLedger = [];
  double _totalBalance = 0;
  Set<String> _tenantIds = {};

  bool _loading = false;
  bool _hasFetched = false;
  bool _paymentsOpen = true;

  @override
  void initState() {
    super.initState();
    final leases = widget.leases;
    if (leases != null && leases.isNotEmpty) {
      final preferredId = widget.initialLeaseId;
      if (preferredId != null && preferredId.isNotEmpty) {
        _selectedLease = leases.firstWhere(
          (l) => l.leaseId == preferredId,
          orElse: () => leases.firstWhere(
            (l) => _isActive(l.startDate, l.endDate),
            orElse: () => leases.first,
          ),
        );
      } else {
        _selectedLease = leases.firstWhere(
          (l) => _isActive(l.startDate, l.endDate),
          orElse: () => leases.first,
        );
      }
    }
    // Real-time search filter
    _searchCtrl.addListener(() => setState(() {}));
    // Auto-load on first open
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchPayments());
  }

  @override
  void didUpdateWidget(covariant FinancialTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tenantId != oldWidget.tenantId) {
      _allLedger = [];
      _tenantLedger = [];
      _hasFetched = false;
      _selectedLease = null;
    }
    final leases = widget.leases;
    if (leases == null || leases.isEmpty) return;

    // If the parent changed the preferred lease ID, switch to it immediately.
    final preferredId = widget.initialLeaseId;
    if (preferredId != null &&
        preferredId.isNotEmpty &&
        preferredId != oldWidget.initialLeaseId) {
      final match = leases.where((l) => l.leaseId == preferredId).toList();
      if (match.isNotEmpty && _selectedLease?.leaseId != preferredId) {
        setState(() {
          _selectedLease = match.first;
          _hasFetched = false;
          _allLedger = [];
          _tenantLedger = [];
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _fetchPayments());
        return;
      }
    }

    final stillValid = _selectedLease != null &&
        leases.any((l) => l.leaseId == _selectedLease!.leaseId);
    if (stillValid && _hasFetched) return;

    final next = leases.firstWhere(
      (l) => _isActive(l.startDate, l.endDate),
      orElse: () => leases.first,
    );
    if ((next.leaseId ?? '').isEmpty) return;

    if (_selectedLease?.leaseId != next.leaseId || !_hasFetched) {
      setState(() => _selectedLease = next);
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchPayments());
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  // ─── Client-side search filter ──────────────────────────────────────────────

  /// Parsed payment date for filtering / grouping (uses [Data.createdAt]).
  DateTime? _paymentDateOnly(Data p) {
    try {
      final raw = p.createdAt;
      if (raw == null || raw.isEmpty) return null;
      final s = raw.contains(' ') ? raw.split(' ')[0] : raw;
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  /// When only start or only end is set, the API often returns the full list.
  /// Apply inclusive calendar-day bounds on the client so web matches mobile.
  List<Data> _filterByPaymentDate(List<Data> source) {
    final startApi = _apiDateOrNull(_startCtrl.text);
    final endApi = _apiDateOrNull(_endCtrl.text);
    if (startApi == null && endApi == null) return source;

    DateTime? startDay;
    DateTime? endDay;
    if (startApi != null) {
      final d = DateTime.tryParse(startApi);
      if (d != null) startDay = DateTime(d.year, d.month, d.day);
    }
    if (endApi != null) {
      final d = DateTime.tryParse(endApi);
      if (d != null) endDay = DateTime(d.year, d.month, d.day);
    }

    return source.where((p) {
      final pd = _paymentDateOnly(p);
      if (pd == null) return false;
      final day = DateTime(pd.year, pd.month, pd.day);
      if (startDay != null && day.isBefore(startDay)) return false;
      if (endDay != null && day.isAfter(endDay)) return false;
      return true;
    }).toList();
  }

  String get _dateRangeSummary {
    final hasStart = _startCtrl.text.isNotEmpty;
    final hasEnd = _endCtrl.text.isNotEmpty;
    if (hasStart && hasEnd) {
      return '${_startCtrl.text} – ${_endCtrl.text}';
    }
    if (hasStart) return 'From ${_startCtrl.text}';
    if (hasEnd) return 'Through ${_endCtrl.text}';
    return 'All payments shown';
  }

  List<Data> _filterData(List<Data> source) {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return source;
    return source.where((p) {
      if (_paymentLabel(p).toLowerCase().contains(q)) return true;
      if (_formatDisplayDate(p.createdAt).toLowerCase().contains(q)) return true;
      if ((p.totalAmount ?? 0).toStringAsFixed(2).contains(q)) return true;
      if ((p.type ?? '').toLowerCase().contains(q)) return true;
      if ((p.paymenttype ?? '').toLowerCase().contains(q)) return true;
      if ((p.transactionid ?? '').toLowerCase().contains(q)) return true;
      if ((p.reference ?? '').toLowerCase().contains(q)) return true;
      if ((p.check_number ?? '').toLowerCase().contains(q)) return true;
      if ((p.response ?? '').toLowerCase().contains(q)) return true;
      if ((p.createdAt ?? '').toLowerCase().contains(q)) return true;
      return p.entry?.any((e) =>
            (e.account ?? '').toLowerCase().contains(q) ||
            (e.memo ?? '').toLowerCase().contains(q)) ??
          false;
    }).toList();
  }

  bool _isActive(String? s, String? e) {
    if (s == null || e == null || s.isEmpty || e.isEmpty) return false;
    try {
      final now = DateTime.now();
      final start = _parseDate(s);
      final end = _parseDate(e);
      return !now.isBefore(start) && !now.isAfter(end);
    } catch (_) {
      return false;
    }
  }

  DateTime _parseDate(String d) {
    for (final f in ['yyyy-MM-dd', 'dd-MM-yyyy', 'MM/dd/yyyy', 'M/d/yyyy']) {
      try {
        return DateFormat(f).parse(d);
      } catch (_) {}
    }
    return DateTime.parse(d);
  }

  String? _apiDateOrNull(String displayOrEmpty) {
    if (displayOrEmpty.isEmpty) return null;
    final api = reverseFormatDate(displayOrEmpty);
    return api.isEmpty ? null : api;
  }

  Future<void> _fetchPayments() async {
    final lease = _selectedLease;
    if (lease == null || (lease.leaseId ?? '').isEmpty) return;

    final fromDate = _apiDateOrNull(_startCtrl.text);
    final toDate = _apiDateOrNull(_endCtrl.text);
    final searchQ = _searchCtrl.text.trim();
    final searchParam = searchQ.isEmpty ? null : searchQ;

    setState(() => _loading = true);
    try {
      final LeaseLedger? allRes = await _repo.fetchAllLedger(
        leaseId: lease.leaseId!,
        fromDate: fromDate,
        toDate: toDate,
        search: searchParam,
      );
      final LeaseLedger? tenantRes = await _repo.fetchLedgerWithTenant(
        leaseId: lease.leaseId!,
        tenantId: widget.tenantId,
        fromDate: fromDate,
        toDate: toDate,
        search: searchParam,
      );

      setState(() {
        _allLedger = allRes?.data ?? <Data>[];
        _tenantLedger = tenantRes?.tenantPayments ?? <Data>[];
        _totalBalance = tenantRes?.totalBalance ?? allRes?.totalBalance ?? 0;
        _tenantIds = _tenantLedger.map((p) => p.sId ?? '').toSet();
        _hasFetched = true;
      });
    } catch (_) {
      setState(() => _hasFetched = true);
    } finally {
      setState(() => _loading = false);
    }
  }

  // ─── Payment label ──────────────────────────────────────────────────────────

  String _paymentLabel(Data p) {
    final tid = p.transactionid ?? '';
    final checkNum = p.check_number ?? '';
    switch ((p.paymenttype ?? '').toLowerCase()) {
      case 'check':
        return checkNum.isNotEmpty ? 'Check # $checkNum' : 'Check Payment';
      case 'cash':
        return 'Cash Payment';
      case 'card':
        return tid.isNotEmpty ? 'Card Payment #$tid' : 'Card Payment';
      case 'ach':
        final ref = p.reference ?? '';
        return ref.isNotEmpty
            ? 'ACH Payment #$ref'
            : tid.isNotEmpty
                ? 'ACH Payment #$tid'
                : 'ACH Payment';
      default:
        return tid.isNotEmpty ? 'Payment #$tid' : 'Payment';
    }
  }

  DateProvider? _dateProviderOrNull() {
    try {
      return Provider.of<DateProvider>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  String _formatDisplayDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final d = DateTime.parse(raw.contains(' ') ? raw.split(' ')[0] : raw);
      final standard = DateFormat('yyyy-MM-dd').format(d);
      final dp = _dateProviderOrNull();
      if (dp != null) return dp.formatCurrentDate(standard);
      return DateFormat('MM/dd/yyyy').format(d);
    } catch (_) {
      return raw;
    }
  }

  String _formatAmount(double? amt) =>
      formatMoney((amt?.abs() ?? 0));

  /// Empty-field hint: format pattern only (not a real date — avoids looking “prefilled”).
  String _datePlaceholderHint(BuildContext context) {
    try {
      final dp = Provider.of<DateProvider>(context, listen: true);
      return dp.fixDateFormat(dp.dateFormat).toUpperCase();
    } catch (_) {
      return 'MM/DD/YYYY';
    }
  }

  // ─── Date picker helper ─────────────────────────────────────────────────────

  Future<void> _pickDate(TextEditingController ctrl) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: _kNavy,
            onPrimary: Colors.white,
            onSurface: _kNavy,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: _kNavy,
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final apiFormat = DateFormat('yyyy-MM-dd').format(picked);
      final dp = _dateProviderOrNull();
      ctrl.text = dp != null
          ? dp.formatCurrentDate(apiFormat)
          : DateFormat('MM/dd/yyyy').format(picked);
      _fetchPayments();
    }
  }

  // ─── Group payments by date ─────────────────────────────────────────────────

  List<MapEntry<String, List<Data>>> _groupByDate(List<Data> payments) {
    final map = <String, List<Data>>{};
    for (final p in payments) {
      final key = _formatDisplayDate(p.createdAt);
      map.putIfAbsent(key, () => []).add(p);
    }
    return map.entries.toList();
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final leases = widget.leases ?? [];
    final filteredAllLedger = _filterByPaymentDate(_allLedger);
    final filteredTenantLedger = _filterByPaymentDate(_tenantLedger);
    final rawData =
        _activeTab == 'ledger' ? filteredAllLedger : filteredTenantLedger;
    final displayData = _filterData(rawData);
    final groups = _groupByDate(displayData);

    return Container(
      color: _kBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Payments collapsible card ───────────────────────────────────────
          _SectionCard(
            title: 'Payments',
            isOpen: _paymentsOpen,
            onToggle: () => setState(() => _paymentsOpen = !_paymentsOpen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Lease dropdown
                if (leases.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _LeaseDropdown(
                      leases: leases,
                      selected: _selectedLease,
                      isActive: _isActive,
                      onChanged: (l) {
                        setState(() {
                          _selectedLease = l;
                          _hasFetched = false;
                          _allLedger = [];
                          _tenantLedger = [];
                        });
                        _fetchPayments();
                      },
                    ),
                  ),

                const SizedBox(height: 10),

                // Divider below dropdown
                const Divider(color: _kBorder, height: 1, thickness: 1),

                const SizedBox(height: 10),

                // Search
                _OutlinedField(
                  controller: _searchCtrl,
                  hint: 'Search here...',
                  icon: Icons.search,
                  onSearch: _fetchPayments,
                ),

                const SizedBox(height: 10),

                // Date row — placeholder follows DateProvider format
                Row(
                  children: [
                    Expanded(
                      child: _DateField(
                        label: 'Start Date',
                        controller: _startCtrl,
                        placeholder: _datePlaceholderHint(context),
                        onTap: () => _pickDate(_startCtrl),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DateField(
                        label: 'End Date',
                        controller: _endCtrl,
                        placeholder: _datePlaceholderHint(context),
                        onTap: () => _pickDate(_endCtrl),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Tab switcher
                _TabBar(
                  active: _activeTab,
                  onSelect: (t) => setState(() => _activeTab = t),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Content ─────────────────────────────────────────────────────────
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: SpinKitFadingCircle(color: _kNavy, size: 40),
              ),
            )
          else if (!_hasFetched)
            _EmptyState(
              icon: Icons.hourglass_empty_rounded,
              message: 'Loading payments…',
            )
          else if (displayData.isEmpty)
            _EmptyState(
              icon: Icons.receipt_long_outlined,
              message: 'No payments found',
            )
          else ...[
            // Breakdown header
            _BreakdownHeader(
              tenantName: widget.tenantName ?? '',
              leaseName: _selectedLease != null
                  ? '${_selectedLease!.rentalAdress ?? ''}'
                      '${(_selectedLease!.rentalUnit ?? '').isNotEmpty ? ' - ${_selectedLease!.rentalUnit}' : ''}'
                  : '',
              dateRange: _dateRangeSummary,
              tenantCount: filteredTenantLedger.length,
              totalCount: filteredAllLedger.length,
              ledgerMode: _activeTab == 'ledger',
            ),

            const SizedBox(height: 8),

            // Section label — shown once above all groups
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 12, bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: _kSectionLabel),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _activeTab == 'ledger'
                        ? 'ALL LEDGER PAYMENTS'
                        : 'THIS TENANT ONLY',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _kSectionLabel,
                        letterSpacing: 0.8),
                  ),
                ],
              ),
            ),

            // Payment groups
            ...groups.map((g) => _PaymentGroup(
                  date: g.key,
                  payments: g.value,
                  tenantIds: _tenantIds,
                  mode: _activeTab,
                  paymentLabel: _paymentLabel,
                  formatAmount: _formatAmount,
                )),

            // Tenant total — tenant tab only
            if (_activeTab == 'tenant')
              _TotalRow(
                label: 'TENANT TOTAL',
                amount: _formatAmount(_totalBalance),
              ),

            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final bool isOpen;
  final VoidCallback onToggle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.isOpen,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x0A1a2744), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            onTap: onToggle,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _kNavy)),
                  Icon(
                    isOpen ? Icons.expand_less : Icons.expand_more,
                    color: _kGray,
                  ),
                ],
              ),
            ),
          ),
          if (isOpen)
            Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: [
                  const Divider(color: _kBorder, height: 1),
                  const SizedBox(height: 12),
                  child,
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LeaseDropdown extends StatelessWidget {
  final List<TenantLeaseData> leases;
  final TenantLeaseData? selected;
  final bool Function(String?, String?) isActive;
  final ValueChanged<TenantLeaseData> onChanged;

  const _LeaseDropdown({
    required this.leases,
    required this.selected,
    required this.isActive,
    required this.onChanged,
  });

  String _address(TenantLeaseData l) {
    final addr = l.rentalAdress ?? '';
    final unit = (l.rentalUnit ?? '').isNotEmpty ? ' – ${l.rentalUnit}' : '';
    return '$addr$unit';
  }

  @override
  Widget build(BuildContext context) {
    // Active leases first, then inactive
    final sortedLeases = [...leases]..sort((a, b) {
        final aA = isActive(a.startDate, a.endDate) ? 0 : 1;
        final bA = isActive(b.startDate, b.endDate) ? 0 : 1;
        return aA.compareTo(bA);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SELECT LEASE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _kSectionLabel,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButton2<TenantLeaseData>(
          isExpanded: true,
          value: selected,
          hint: const Text(
            'Choose a lease…',
            style: TextStyle(color: _kGray, fontSize: 14),
          ),
          items: sortedLeases.map((l) {
            final active = isActive(l.startDate, l.endDate);
            return DropdownMenuItem<TenantLeaseData>(
              value: l,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? const Color(0xFF1E8A4C)
                          : const Color(0xFFBBBBBB),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _address(l),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _kNavy,
                          ),
                        ),
                        if (active)
                          const Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF1E8A4C),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          buttonStyleData: ButtonStyleData(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kNavy.withOpacity(0.25), width: 1.2),
              color: Colors.white,
            ),
            padding: const EdgeInsets.only(left: 12, right: 8),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              border: Border.all(color: _kBorder),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x181A2744),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(4),
              thumbColor: WidgetStateProperty.all(_kGray.withOpacity(0.4)),
              thickness: WidgetStateProperty.all(4),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 52,
            padding: EdgeInsets.symmetric(horizontal: 12),
          ),
          iconStyleData: const IconStyleData(
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: _kNavy, size: 22),
          ),
          // Remove default Flutter dropdown underline
          underline: const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _OutlinedField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final VoidCallback? onSearch;

  const _OutlinedField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder),
        color: const Color(0xFFFAFBFC),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSearch,
            child: Icon(
              Icons.search,
              color: onSearch != null ? _kNavy : _kGray,
              size: 18,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSearch?.call(),
              style: const TextStyle(fontSize: 14, color: _kNavy),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: _kGray, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          // Clear button
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, val, __) => val.text.isEmpty
                ? const SizedBox.shrink()
                : GestureDetector(
                    onTap: () {
                      controller.clear();
                      onSearch?.call();
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.close, size: 16, color: _kGray),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  /// Shown when empty — should match [DateProvider.dateFormat] (sample date).
  final String placeholder;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.controller,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _kSectionLabel,
                letterSpacing: 0.4)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kBorder),
              color: const Color(0xFFFAFBFC),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (_, val, __) => Text(
                      val.text.isEmpty ? placeholder : val.text,
                      style: TextStyle(
                        fontSize: 13,
                        color: val.text.isEmpty ? _kGray : _kNavy,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today, size: 15, color: _kGray),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class _TabBar extends StatelessWidget {
  final String active;
  final ValueChanged<String> onSelect;

  const _TabBar({required this.active, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Row(
          children: [
            _Tab(
              label: 'Ledger Payment',
              isActive: active == 'ledger',
              onTap: () => onSelect('ledger'),
            ),
            _Tab(
              label: 'Tenant Payment',
              isActive: active == 'tenant',
              onTap: () => onSelect('tenant'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Tab(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: isActive ? _kNavy : const Color(0xFFF5F7FA),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : _kGray,
            ),
          ),
        ),
      ),
    );
  }
}

class _BreakdownHeader extends StatelessWidget {
  final String tenantName;
  final String leaseName;
  final String dateRange;
  final int tenantCount;
  final int totalCount;
  /// True = all lease ledger view; false = this tenant only tab.
  final bool ledgerMode;

  const _BreakdownHeader({
    required this.tenantName,
    required this.leaseName,
    required this.dateRange,
    required this.tenantCount,
    required this.totalCount,
    required this.ledgerMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$tenantName – Payment Breakdown',
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _kNavy,
                letterSpacing: -0.2),
          ),
          const SizedBox(height: 3),
          Text(
            '${leaseName.isNotEmpty ? leaseName : '—'} • $dateRange',
            style: const TextStyle(fontSize: 12, color: _kGray),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: _kTenantBadgeBg,
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: _kTenantBadge),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      ledgerMode ? 'All lease payments' : 'This tenant only',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _kTenantBadge),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: _kCountBg,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  ledgerMode
                      ? '$tenantCount of $totalCount payments from this tenant'
                      : '$tenantCount payment${tenantCount == 1 ? '' : 's'} shown',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _kCountText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentGroup extends StatelessWidget {
  final String date;
  final List<Data> payments;
  final Set<String> tenantIds;
  final String mode;
  final String Function(Data) paymentLabel;
  final String Function(double?) formatAmount;

  const _PaymentGroup({
    required this.date,
    required this.payments,
    required this.tenantIds,
    required this.mode,
    required this.paymentLabel,
    required this.formatAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Text(date,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _kNavy)),
          ),
          // Payment cards
          ...payments.map((p) => mode == 'ledger'
              ? _LedgerPaymentCard(
                  payment: p,
                  isTenant: tenantIds.contains(p.sId),
                  label: paymentLabel(p),
                  formatAmount: formatAmount,
                )
              : _TenantPaymentCard(
                  payment: p,
                  label: paymentLabel(p),
                  date: date,
                  formatAmount: formatAmount,
                )),
        ],
      ),
    );
  }
}

class _LedgerPaymentCard extends StatelessWidget {
  final Data payment;
  final bool isTenant;
  final String label;
  final String Function(double?) formatAmount;

  const _LedgerPaymentCard({
    required this.payment,
    required this.isTenant,
    required this.label,
    required this.formatAmount,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = (payment.response ?? '').toUpperCase() == 'SUCCESS';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          // Payment header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _kNavy),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isTenant) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _kTagBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'This tenant',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: _kTag,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 4),
                      Icon(
                        isSuccess ? Icons.check : Icons.close,
                        size: 15,
                        color: isSuccess ? _kCheckGreen : _kFailRed,
                      ),
                    ],
                  ),
                ),
                Text(
                  formatAmount(payment.totalAmount),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSuccess ? _kNavy : _kFailRed),
                ),
              ],
            ),
          ),
          // Entries (tenant scope is shown once on the header, not every line)
          if (payment.entry != null)
            ...payment.entry!.map((e) => _EntryRow(
                  account: e.account ?? '',
                  amount: formatAmount(e.amount),
                )),
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final String account;
  final String amount;

  const _EntryRow({required this.account, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: _kEntryBg,
        border: Border(top: BorderSide(color: _kBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              account,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          Text(amount,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kGreen)),
        ],
      ),
    );
  }
}

class _TenantPaymentCard extends StatelessWidget {
  final Data payment;
  final String label;
  final String date;
  final String Function(double?) formatAmount;

  const _TenantPaymentCard({
    required this.payment,
    required this.label,
    required this.date,
    required this.formatAmount,
  });

  @override
  Widget build(BuildContext context) {
    final entries = payment.entry ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: entries.asMap().entries.map((e) {
          final idx = e.key;
          final entry = e.value;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: idx > 0
                  ? const Border(
                      top: BorderSide(color: _kBorder, width: 0.5))
                  : null,
            ),
            child: Row(
              children: [
                // $ icon
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: _kIconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text('\$',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _kTag)),
                ),
                // Account + meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.account ?? '',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _kNavy)),
                      const SizedBox(height: 2),
                      Text(
                        '$date • $label',
                        style: const TextStyle(
                            fontSize: 11, color: _kGray),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Amount
                Text(
                  formatAmount(entry.amount),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: (entry.amount ?? 0) == 0
                          ? _kGray
                          : _kGreen),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String amount;

  const _TotalRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _kNavy,
                  letterSpacing: 0.4)),
          Text(amount,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _kGreen)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(fontSize: 14, color: _kGray)),
        ],
      ),
    );
  }
}
