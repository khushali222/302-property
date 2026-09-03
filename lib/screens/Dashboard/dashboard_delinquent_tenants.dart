import 'package:flutter/material.dart';

import '../../constant/constant.dart';
import '../../repository/DelinquentTenantsService.dart';
import '../../widgets/CustomTableShimmer.dart';
import '../../widgets/dashboard_pagination_footer.dart';
import '../Reports/ReportScreens/DelinquentTenants.dart';

/// Web parity: `Client/src/views/DelinquentTenantsWidget.jsx` (CRM-4501),
/// mounted on the Admin dashboard only — the Staff dashboard does not carry it.
///
/// The endpoint returns one entry per LEASE with a nested tenant list; web
/// flattens that to one row per TENANT before counting or paging, so the count
/// badge is a tenant count, not a lease count. Mirrored here.
///
/// The server also sends `balance_source` / `balance_diff` per tenant, which web
/// renders as a small "legacy" / "ledger" chip (LedgerSourceBadge). That chip is
/// deliberately NOT shown here: it is a ledger-migration diagnostic — web itself
/// hides it behind the VITE_SHOW_LEDGER_BADGE flag — not information a property
/// manager acts on. The fields are still parsed on the model if it is ever wanted.
///
/// Visual style is taken from the sibling dashboard cards (cronjob_payment_table,
/// dashbordpolices_table, dashboard_leaseExpiring), which all share one shape:
/// a bare heading above the list, then ONE OWN CARD per row — radius 18, white,
/// black12 shadow, no border, no dividers, no outer container. Those three files
/// also each define a `_buildHeaders()` that paints the old blue banner, but it
/// has no call sites in any of them; that dead banner is the "old table" look
/// and must not be copied here.
class DashboardDelinquentTenants extends StatefulWidget {
  const DashboardDelinquentTenants({super.key});

  @override
  State<DashboardDelinquentTenants> createState() =>
      _DashboardDelinquentTenantsState();
}

/// One flattened tenant row — the shape web builds in its `flat` array.
class _DelinquentRow {
  final String tenantName;
  final String rentalAddress;
  final num total;
  final String? balanceSource;
  final num? balanceDiff;

  _DelinquentRow({
    required this.tenantName,
    required this.rentalAddress,
    required this.total,
    this.balanceSource,
    this.balanceDiff,
  });
}

class _DashboardDelinquentTenantsState
    extends State<DashboardDelinquentTenants> {
  final DelinquentTenantsSerivce _service = DelinquentTenantsSerivce();

  // House type ramp from cronjob_payment_table.dart, with the name and amount
  // in blueColor to match the agreed design for this card.
  final TextStyle cardTextStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: blueColor);
  final TextStyle subTextStyle = const TextStyle(fontSize: 14);

  List<_DelinquentRow> _rows = [];
  bool _loading = true;
  bool _failed = false;

  /// Web pages this widget client-side at 5/10/25 with 5 selected, and keeps
  /// the View All link alongside it — the footer walks the preview, the link
  /// jumps to the full report. Same here.
  int _currentPage = 0;
  int _rowsPerPage = 5;
  static const List<int> _rowsPerPageOptions = <int>[5, 10, 25];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final leases = await _service.fetchDelinquentTenants();
      final flat = <_DelinquentRow>[];
      for (final lease in leases) {
        for (final tenant in (lease.tenants ?? const [])) {
          final pdf = tenant.pdfDelinquentTenantsData;
          flat.add(_DelinquentRow(
            // Web falls back to an em dash for either missing field.
            tenantName: (tenant.tenantName ?? '').trim().isEmpty
                ? '—'
                : tenant.tenantName!.trim(),
            rentalAddress: (lease.rentalAddress ?? '').trim().isEmpty
                ? '—'
                : lease.rentalAddress!.trim(),
            // totalDaysAmount is a String on the model and can arrive as the
            // literal "null", so parse defensively rather than trusting it.
            total: asNumN(pdf?.totalDaysAmount) ?? 0,
            balanceSource: pdf?.balanceSource,
            balanceDiff: pdf?.balanceDiff,
          ));
        }
      }
      if (!mounted) return;
      setState(() {
        _rows = flat;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  void _openReport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DelinquentTenants()),
    );
  }

  /// Count badge. The red is the same 0xFFD92D20 the sibling payments card uses
  /// for a failed value, so the dashboard keeps one red rather than two.
  Widget _countBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        // Web counts the flattened tenant rows, not the leases.
        '${_rows.length}',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFFD92D20),
        ),
      ),
    );
  }

  Widget _viewAllLink() {
    return GestureDetector(
      onTap: _openReport,
      behavior: HitTestBehavior.opaque,
      child: Text(
        'View All',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: blueColor,
        ),
      ),
    );
  }

  /// The title previously truncated to "Delinquent Te..." because the header was
  /// `Flexible(title) + badge + Spacer() + link`. `Spacer` IS `Expanded(flex: 1)`,
  /// so it and the Flexible title split the free space 50/50 — the title was
  /// capped at half the row however much space there actually was.
  ///
  /// Fixed two ways: the title is now the ONLY flexible child (so it takes all
  /// the slack), and it wraps instead of ellipsing (so a tight fit can never
  /// lose characters). Count and "View All" stay inline at their natural width.
  Widget _header(bool isMobile) {
    final title = Text(
      'Delinquent Tenants',
      softWrap: true,
      style: TextStyle(
        fontSize: isMobile ? 15 : 16,
        fontWeight: FontWeight.bold,
        color: blueColor,
      ),
    );

    // Title + count sit together on the left; "View All" is pushed out to the
    // far right so it reads as its own action rather than as part of the count.
    //
    // Only the LEFT group is flexible. A Spacer here would be a second flexible
    // child and would split the free space with the title — that is exactly what
    // truncated it to "Delinquent Te..." before. Giving the group Expanded and
    // ending it with its own Spacer keeps the title greedy and the link pinned.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(child: title),
              const SizedBox(width: 10),
              _countBadge(),
              const Spacer(),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _viewAllLink(),
      ],
    );
  }

  /// One row = its own card. Decoration matches the sibling dashboard cards
  /// exactly: no border, no divider, separation comes from the shadow and the
  /// card's own vertical margin.
  Widget _delinquentCard(_DelinquentRow row) {
    return GestureDetector(
      // Web parity: tapping a row opens the full report, same as View All.
      onTap: _openReport,
      behavior: HitTestBehavior.opaque,
      child: Container(
        // Tighter than the sibling cards' vertical-8 / all-16: this row stacks
        // two text lines where they show one, so both the gap between cards and
        // the padding inside them are pulled in to keep the height comparable.
        // Two levers, pulled in opposite directions on purpose: the padding is
        // tight so each row stays short, while the margin is generous so the
        // cards read as clearly separate rather than one continuous block.
        margin: const EdgeInsets.symmetric(vertical: 7),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        // Name over address on the left, amount centred against them on the
        // right. Expanded on the left block so a long name or address shrinks
        // rather than pushing the amount off-screen.
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.tenantName,
                    style: cardTextStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 16, color: greyColor.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          row.rentalAddress,
                          style: subTextStyle.copyWith(
                            color: greyColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(formatMoney(row.total), style: cardTextStyle),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The same shimmer every sibling dashboard card shows while loading.
    if (_loading) return ColabShimmerLoadingWidget();

    // Silent on failure, and nothing to show when no tenant is delinquent —
    // both match the web widget rather than parking an empty box on a dashboard
    // that is already full of cards.
    if (_failed || _rows.isEmpty) return const SizedBox.shrink();

    final int totalPages = (_rows.length / _rowsPerPage).ceil();
    final int start = _currentPage * _rowsPerPage;
    final preview = _rows.skip(start).take(_rowsPerPage).toList();

    // Zero horizontal padding, like the sibling cards: every side gutter comes
    // from the dashboard screen, which also supplies the trailing SizedBox.
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _header(isMobile),
            const SizedBox(height: 10),
            // Cards space themselves via their own vertical margin.
            ...preview.map(_delinquentCard),
            if (_rows.length > _rowsPerPageOptions.first)
              DashboardPaginationFooter(
                currentPage: _currentPage + 1,
                totalPages: totalPages,
                rowsPerPage: _rowsPerPage,
                rowsPerPageOptions: _rowsPerPageOptions,
                onRowsPerPageChanged: (v) => setState(() {
                  _rowsPerPage = v;
                  _currentPage = 0;
                }),
                onPrev: _currentPage == 0
                    ? null
                    : () => setState(() => _currentPage--),
                onNext: _currentPage < totalPages - 1
                    ? () => setState(() => _currentPage++)
                    : null,
              ),
          ],
        );
      },
    );
  }
}
