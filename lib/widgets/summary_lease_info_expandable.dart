import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Model/unit.dart';

/// Expandable lease cards for the property Summary tab (matches summary table UX).
class SummaryLeaseInfoExpandable extends StatefulWidget {
  final List<unit_lease> leases;
  final Color blueColor;
  final DateTime now;

  const SummaryLeaseInfoExpandable({
    super.key,
    required this.leases,
    required this.blueColor,
    required this.now,
  });

  @override
  State<SummaryLeaseInfoExpandable> createState() =>
      _SummaryLeaseInfoExpandableState();
}

class _SummaryLeaseInfoExpandableState
    extends State<SummaryLeaseInfoExpandable> {
  static const int _pageSize = 10;
  int _currentPage = 0;

  /// Keys are indices in the full [leases] list; default first row expanded.
  late Set<int> _expandedIndices;

  @override
  void initState() {
    super.initState();
    _expandedIndices = widget.leases.isEmpty ? {} : {0};
  }

  @override
  void didUpdateWidget(SummaryLeaseInfoExpandable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.leases.length != widget.leases.length) {
      _currentPage = 0;
      _expandedIndices = widget.leases.isEmpty ? {} : {0};
    }
  }

  String _fmtDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    final fmts = ['yyyy-MM-dd', 'MM/dd/yyyy', 'dd/MM/yyyy', 'yyyy/MM/dd'];
    for (final f in fmts) {
      try {
        final d = DateFormat(f).parse(raw.trim());
        return DateFormat('MM/dd/yyyy').format(d);
      } catch (_) {}
    }
    return raw;
  }

  int _calcDays(String? endDate, int? remainingDays) {
    if (remainingDays != null) return remainingDays;
    if (endDate == null || endDate.isEmpty) return 0;
    DateTime? d = DateTime.tryParse(endDate);
    if (d != null) return d.difference(widget.now).inDays;
    final fmts = ['yyyy-MM-dd', 'MM/dd/yyyy', 'dd/MM/yyyy', 'yyyy/MM/dd'];
    for (final f in fmts) {
      try {
        final parsed = DateFormat(f).parse(endDate.trim());
        return parsed.difference(widget.now).inDays;
      } catch (_) {}
    }
    return 0;
  }

  void _toggleExpanded(int globalIndex) {
    setState(() {
      if (_expandedIndices.contains(globalIndex)) {
        _expandedIndices.remove(globalIndex);
      } else {
        _expandedIndices.add(globalIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFDBE0E5);
    const labelHeader = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 13,
      color: Color(0xFF1A3C6E),
    );
    const primaryValueStyle = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 15,
      color: Color(0xFF111111),
    );
    const fieldLabelStyle = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 13,
      color: Color(0xFF1A3C6E),
    );
    const fieldValueStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Color(0xFF6B7280),
    );

    final totalPages = (widget.leases.length / _pageSize).ceil();
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, widget.leases.length);
    final pageLeases = widget.leases.sublist(start, end);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...pageLeases.asMap().entries.map((entry) {
          final pageIdx = entry.key;
          final globalIndex = start + pageIdx;
          final l = entry.value;
          final isExpanded = _expandedIndices.contains(globalIndex);
          final name = (l.tenantNames?.isNotEmpty == true)
              ? l.tenantNames!
              : '${l.tenantFirstName ?? ''} ${l.tenantLastName ?? ''}'.trim();
          final displayName = name.isEmpty ? 'N/A' : name;
          final days = _calcDays(l.endDate, l.remainingDays);
          final amt = l.amount != null
              ? '\$${l.amount!.toDouble().toStringAsFixed(2)}'
              : 'N/A';

          return Padding(
            padding: EdgeInsets.only(bottom: pageIdx < pageLeases.length - 1 ? 12 : 0),
            child: Material(
              color: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InkWell(
                      onTap: () => _toggleExpanded(globalIndex),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: borderColor, width: 1),
                          ),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text('Tenant Name', style: labelHeader),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Lease End', style: labelHeader),
                                const SizedBox(width: 6),
                                Icon(
                                  isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: const Color(0xFF1A3C6E),
                                  size: 22,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    displayName,
                                    style: primaryValueStyle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    _fmtDate(l.endDate),
                                    textAlign: TextAlign.right,
                                    style: primaryValueStyle,
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(
                                height: 1,
                                thickness: 1,
                                color: Color(0xFFE8EBEF),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Rent Cycle',
                                        style: fieldLabelStyle,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l.rentCycle ?? 'N/A',
                                        style: fieldValueStyle,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Rent Amount',
                                        style: fieldLabelStyle,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        amt,
                                        textAlign: TextAlign.right,
                                        style: fieldValueStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Remaining Days',
                                  style: fieldLabelStyle,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$days Days',
                                  style: fieldValueStyle,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
        if (widget.leases.length > _pageSize)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${start + 1}–$end of ${widget.leases.length}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Row(
                  children: [
                    _LeasePaginationButton(
                      icon: Icons.chevron_left,
                      enabled: _currentPage > 0,
                      blueColor: widget.blueColor,
                      onTap: () => setState(() => _currentPage--),
                    ),
                    const SizedBox(width: 4),
                    ...List.generate(totalPages, (i) {
                      final isActive = i == _currentPage;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: GestureDetector(
                          onTap: () => setState(() => _currentPage = i),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? widget.blueColor
                                  : const Color(0xFFF4F8FF),
                              border: Border.all(
                                color: isActive
                                    ? widget.blueColor
                                    : const Color(0xFFDBE0E5),
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isActive
                                      ? Colors.white
                                      : widget.blueColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 4),
                    _LeasePaginationButton(
                      icon: Icons.chevron_right,
                      enabled: _currentPage < totalPages - 1,
                      blueColor: widget.blueColor,
                      onTap: () => setState(() => _currentPage++),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _LeasePaginationButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final Color blueColor;
  final VoidCallback onTap;

  const _LeasePaginationButton({
    required this.icon,
    required this.enabled,
    required this.blueColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF4F8FF) : const Color(0xFFF0F0F0),
          border: Border.all(
            color: enabled ? const Color(0xFFDBE0E5) : const Color(0xFFE8E8E8),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? blueColor : Colors.grey[400],
        ),
      ),
    );
  }
}
