import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../Model/Dashbord_table/lease_expiring_table.dart';
import '../../../constant/constant.dart';
import '../../../provider/dateProvider.dart';
import '../../repository/lease_expiry_service.dart';
import '../../repository/tenants.dart';
import '../Rental/Tenants/Tenant_summary.dart';

class Dashboard_leaseExpiringStaff extends StatefulWidget {
  @override
  _Dashboard_leaseExpiringStaffState createState() =>
      _Dashboard_leaseExpiringStaffState();
}

class _Dashboard_leaseExpiringStaffState extends State<Dashboard_leaseExpiringStaff> {
  final LeaseExpiryService _service = LeaseExpiryService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LeaseExpiryTable(
          title: "Leases Expiring In The Next 30 Days",
          isExpired: false,
          service: _service,
        ),
        SizedBox(height: 20),
        LeaseExpiryTable(
          title: "Leases Expired In The Previous 30 Days",
          isExpired: true,
          service: _service,
        ),
      ],
    );
  }
}

class LeaseExpiryTable extends StatefulWidget {
  final String title;
  final bool isExpired;
  final LeaseExpiryService service;

  const LeaseExpiryTable({
    required this.title,
    required this.isExpired,
    required this.service,
  });

  @override
  _LeaseExpiryTableState createState() => _LeaseExpiryTableState();
}

class _LeaseExpiryTableState extends State<LeaseExpiryTable> {
  int currentPage = 1;
  int limit = 5;
  int totalRecords = 0;
  bool isLoading = true;
  List<LeaseDataExpiring> data = [];
  Set<int> expandedIndices = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    final response = widget.isExpired
        ? await widget.service.fetchExpiredLeases(page: currentPage, limit: limit)
        : await widget.service.fetchExpiringLeases(page: currentPage, limit: limit);

    if (mounted) {
      setState(() {
        if (response != null) {
          data = response.data ?? [];
          totalRecords = response.metadata?.total ?? 0;
        }
        isLoading = false;
      });
    }
  }

  void _onExpandTap(int index) {
    setState(() {
      if (expandedIndices.contains(index)) {
        expandedIndices.remove(index);
      } else {
        expandedIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    int totalPages = (totalRecords / limit).ceil();
    if (totalPages == 0) totalPages = 1;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only( bottom: 2.0,top: 2),
            child: Text(
              widget.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: blueColor,
                fontSize: 16,
              ),
            ),
          ),
          if (isLoading)
            Center(child: SpinKitFadingCircle(color: blueColor, size: 20))
          else if (data.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Color(0xFFDBE0E5))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/Nodata.png',
                      height: 20,
                      width: 20,
                      color: Color(0xFF101828),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Center(
                      child: Text(
                        "No data available",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF101828),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                ...data.asMap().entries.map((entry) {
                  int index = entry.key;
                  LeaseDataExpiring lease = entry.value;
                  bool isExpanded = expandedIndices.contains(index);
                  return _buildLeaseCard(lease, isExpanded, () => _onExpandTap(index), dateProvider);
                }).toList(),
                if (totalRecords > 5) _buildPaginationControls(totalPages),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLeaseCard(
    LeaseDataExpiring lease,
    bool isExpanded,
    VoidCallback onExpandTap,
    DateProvider dateProvider,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onExpandTap,
                child: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: blueColor,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final id = lease.tenantId;
                    if (id == null || id.isEmpty) return;
                    final tenantData =
                        await TenantsRepository().fetchTenantsummery(id) ?? [];
                    if (!mounted || tenantData.isEmpty) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResponsiveTenantSummary(
                          tenants: tenantData.first,
                          tenantId: id,
                          initialSummaryTabIndex: 1,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    lease.rentalAddress ?? 'N/A',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: blueColor,
                      decoration: (lease.tenantId != null &&
                              lease.tenantId!.isNotEmpty)
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Divider(thickness: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tenant :',
                        style: TextStyle(
                          color: blueColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        lease.tenantName ?? "-",
                        style: TextStyle(fontSize: 13, color: Colors.grey[700],fontWeight: FontWeight.bold,),
                        
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Expiration Date :',
                        style: TextStyle(
                          color: blueColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        dateProvider.formatCurrentDate(lease.endDate ?? "-"),
                        style: TextStyle(fontSize: 13, color: Colors.grey[700],fontWeight: FontWeight.bold,),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Material(
            elevation: 3,
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: limit,
                  items: [5, 10, 25, 50].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: totalRecords > 5
                      ? (newValue) {
                          if (newValue != null) {
                            setState(() {
                              limit = newValue;
                              currentPage = 1;
                            });
                            _fetchData();
                          }
                        }
                      : null,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.circleChevronLeft,
              size: 24,
              color: currentPage == 1 ? Colors.grey : blueColor,
            ),
            onPressed: currentPage == 1
                ? null
                : () {
                    setState(() {
                      currentPage--;
                    });
                    _fetchData();
                  },
          ),
          Text(
            'Page $currentPage of $totalPages',
            style: TextStyle(fontSize: 14),
          ),
          IconButton(
            icon: FaIcon(
              size: 24,
              FontAwesomeIcons.circleChevronRight,
              color: currentPage >= totalPages ? Colors.grey : blueColor,
            ),
            onPressed: currentPage >= totalPages
                ? null
                : () {
                    setState(() {
                      currentPage++;
                    });
                    _fetchData();
                  },
          ),
        ],
      ),
    );
  }
}
