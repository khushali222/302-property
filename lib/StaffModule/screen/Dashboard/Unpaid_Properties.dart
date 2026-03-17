import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';
import 'package:three_zero_two_property/StaffModule/widgets/appbar.dart';
import 'package:three_zero_two_property/StaffModule/widgets/custom_drawer.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

/// Preview late letter row from GET /api/leases/preview-late-letters/{adminId}
class PreviewLateLetter {
  final String tenantId;
  final String leaseId;
  final String tenantName;
  final String rentalAddress;
  final String rentalCity;
  final String rentalState;
  final String rentalZip;
  final String rentalUnit;
  final String ownerName;
  final String ownerCompany;
  final String totalAmount;

  PreviewLateLetter({
    required this.tenantId,
    required this.leaseId,
    required this.tenantName,
    required this.rentalAddress,
    required this.rentalCity,
    required this.rentalState,
    required this.rentalZip,
    required this.rentalUnit,
    required this.ownerName,
    required this.ownerCompany,
    required this.totalAmount,
  });

  factory PreviewLateLetter.fromJson(Map<String, dynamic> json) {
    return PreviewLateLetter(
      tenantId: json['tenant_id']?.toString() ?? '',
      leaseId: json['lease_id']?.toString() ?? '',
      tenantName: json['tenant_name']?.toString() ?? '',
      rentalAddress: json['rental_address']?.toString() ?? '',
      rentalCity: json['rental_city']?.toString() ?? '',
      rentalState: json['rental_state']?.toString() ?? '',
      rentalZip: json['rental_zip']?.toString() ?? '',
      rentalUnit: json['rental_unit']?.toString() ?? '',
      ownerName: json['owner_name']?.toString() ?? '',
      ownerCompany: json['owner_company']?.toString() ?? '',
      totalAmount: json['total_amount']?.toString() ?? '0',
    );
  }

  String get fullAddress {
    final parts = [
      rentalAddress,
      rentalCity,
      rentalState,
      rentalZip,
      if (rentalUnit.isNotEmpty) rentalUnit,
    ].where((e) => e.isNotEmpty);
    return parts.join(', ');
  }
}

/// Rental owner from GET /api/rentals/rental-owners/{adminId}
class RentalOwnerItem {
  final String id;
  final String rentalownerId;
  final String name;
  final String companyName;

  RentalOwnerItem({
    required this.id,
    required this.rentalownerId,
    required this.name,
    required this.companyName,
  });

  factory RentalOwnerItem.fromJson(Map<String, dynamic> json) {
    return RentalOwnerItem(
      id: json['_id']?.toString() ?? '',
      rentalownerId: json['rentalowner_id']?.toString() ?? '',
      name: json['rentalOwner_name']?.toString() ?? '',
      companyName: json['rentalOwner_companyName']?.toString() ?? '',
    );
  }

  String get displayName =>
      companyName.isNotEmpty ? '$name ($companyName)' : name;
}

/// Fee row from GET /api/leases/lease/unpaid-fees/{leaseId}
class UnpaidFeeItem {
  final String date;
  final String type;
  final num amount;
  final num dueAmount;

  UnpaidFeeItem({
    required this.date,
    required this.type,
    required this.amount,
    required this.dueAmount,
  });

  factory UnpaidFeeItem.fromJson(Map<String, dynamic> json) {
    return UnpaidFeeItem(
      date: json['date']?.toString() ?? json['fee_date']?.toString() ?? '',
      type: json['type']?.toString() ?? json['charge_type']?.toString() ?? '',
      amount: (json['amount'] is num)
          ? (json['amount'] as num)
          : double.tryParse(json['amount']?.toString() ?? '') ?? 0,
      dueAmount: (json['due_amount'] is num)
          ? (json['due_amount'] as num)
          : (json['fee'] is num)
              ? (json['fee'] as num)
              : double.tryParse(json['due_amount']?.toString() ?? '') ?? 0,
    );
  }
}

class Unpaid_Properties extends StatefulWidget {
  const Unpaid_Properties({super.key});

  @override
  State<Unpaid_Properties> createState() => _Unpaid_PropertiesState();
}

class _Unpaid_PropertiesState extends State<Unpaid_Properties> {
  String? _adminId;
  String? _token;
  String? _staffId;

  List<RentalOwnerItem> _rentalOwners = [];
  List<PreviewLateLetter> _lateLetters = [];
  double _totalPastDueAmount = 0;
  bool _loadingLetters = true;

  String? _selectedOwnerId; // null = All Owners
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expandedLeaseIds = {};
  final Set<String> _chargeViewMoreExpanded = {}; // when >10 fees, show all
  final Map<String, List<UnpaidFeeItem>> _feesCache = {};
  final Map<String, bool> _loadingFees = {};

  static const List<int> _itemsPerPageOptions = [10, 25, 50, 100];
  int _itemsPerPage = 10;
  int _currentPage = 0;

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _loadPrefsAndData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefsAndData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _adminId = prefs.getString('adminId');
      _token = prefs.getString('token');
      _staffId = prefs.getString('staff_id');
    });
    if (_adminId == null) return;
    await Future.wait([_fetchRentalOwners(), _fetchPreviewLateLetters()]);
  }

  Future<void> _fetchRentalOwners() async {
    if (_adminId == null || _token == null) return;
    try {
      final res = await http.get(
        Uri.parse('$Api_url/api/rentals/rental-owners/$_adminId'),
        headers: {
          'authorization': 'CRM $_token',
          'id': 'CRM ${_staffId ?? _adminId}',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200 && mounted) {
        final body = json.decode(res.body);
        final list = body is List ? body : (body['data'] as List? ?? []);
        final items = list
            .map((e) => RentalOwnerItem.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() => _rentalOwners = items);
      }
    } catch (_) {}
  }

  Future<void> _fetchPreviewLateLetters() async {
    if (_adminId == null || _token == null) return;
    setState(() => _loadingLetters = true);
    try {
      final res = await http.get(
        Uri.parse('$Api_url/api/leases/preview-late-letters/$_adminId'),
        headers: {
          'authorization': 'CRM $_token',
          'id': 'CRM ${_staffId ?? _adminId}',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final data = body['data'] as List? ?? [];
        final total = body['total_past_due_amount'];
        final amount = (total is num)
            ? total.toDouble()
            : double.tryParse(total?.toString() ?? '') ?? 0.0;
        final letters = data
            .map((e) =>
                PreviewLateLetter.fromJson(e as Map<String, dynamic>))
            .toList();
        if (mounted) setState(() {
          _lateLetters = letters;
          _totalPastDueAmount = amount;
          _loadingLetters = false;
        });
      } else {
        if (mounted) setState(() => _loadingLetters = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingLetters = false);
    }
  }

  Future<void> _fetchUnpaidFees(String leaseId) async {
    if (_token == null || _feesCache.containsKey(leaseId)) return;
    setState(() => _loadingFees[leaseId] = true);
    try {
      final res = await http.get(
        Uri.parse('$Api_url/api/leases/lease/unpaid-fees/$leaseId'),
        headers: {
          'authorization': 'CRM $_token',
          'id': 'CRM ${_staffId ?? _adminId}',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200 && mounted) {
        final body = json.decode(res.body);
        final data = body['data'];
        final feesList = data?['fees'] as List? ?? [];
        final fees = feesList
            .map((e) =>
                UnpaidFeeItem.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() {
          _feesCache[leaseId] = fees;
          _loadingFees[leaseId] = false;
        });
      } else {
        if (mounted) setState(() => _loadingFees[leaseId] = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingFees[leaseId] = false);
    }
  }

  List<PreviewLateLetter> get _filteredLetters {
    var list = _lateLetters;
    if (_selectedOwnerId != null) {
      RentalOwnerItem? selected;
      for (final o in _rentalOwners) {
        if (o.rentalownerId == _selectedOwnerId) {
          selected = o;
          break;
        }
      }
      if (selected != null && selected.name.isNotEmpty) {
        list = list.where((e) => e.ownerName == selected!.name).toList();
      }
    }
    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((e) {
        return e.tenantName.toLowerCase().contains(q) ||
            e.fullAddress.toLowerCase().contains(q) ||
            e.ownerName.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  List<PreviewLateLetter> get _pagedData {
    final filtered = _filteredLetters;
    final start = _currentPage * _itemsPerPage;
    if (start >= filtered.length) return [];
    final end = (start + _itemsPerPage).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  int get _totalPages {
    if (_filteredLetters.isEmpty) return 1;
    return (_filteredLetters.length / _itemsPerPage).ceil();
  }

  String _formatCurrency(dynamic value) {
    if (value is num) return _currencyFormat.format(value);
    final s = value?.toString() ?? '0';
    final n = double.tryParse(s);
    return n != null ? _currencyFormat.format(n) : _currencyFormat.format(0);
  }

  String _formatDate(BuildContext context, String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final dateProvider = Provider.of<DateProvider>(context, listen: false);
      return dateProvider.formatCurrentDate(dateStr);
    } catch (_) {
      final parts = dateStr.split('-');
      if (parts.length >= 3) return '${parts[1]}/${parts[2]}/${parts[0]}';
      return dateStr;
    }
  }

  List<UnpaidFeeItem> _visibleFeesForLease(
      String leaseId, List<UnpaidFeeItem> fees) {
    if (fees.length <= 10) return fees;
    if (_chargeViewMoreExpanded.contains(leaseId)) return fees;
    return fees.take(10).toList();
  }

  Widget _buildTableHeader() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDBE0E5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 30),
          Expanded(
            child: Text(
              'Tenant Details',
              style: TextStyle(
                color: blueColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              'Balance',
              style: TextStyle(
                color: blueColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _itemsPerPage,
              isExpanded: false,
              items: _itemsPerPageOptions.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _itemsPerPage = newValue;
                    _currentPage = 0;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.circleChevronLeft,
            size: 24,
            color: _currentPage == 0 ? Colors.grey : blueColor,
          ),
          onPressed: _currentPage == 0
              ? null
              : () {
                  setState(() => _currentPage--);
                },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Page ${_currentPage + 1} of $_totalPages',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.circleChevronRight,
            size: 24,
            color: _currentPage >= _totalPages - 1 ? Colors.grey : blueColor,
          ),
          onPressed: _currentPage >= _totalPages - 1
              ? null
              : () {
                  setState(() => _currentPage++);
                },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302_Staff.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawerStaff(
        currentpage: "Unpaid Properties",
        dropdown: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            titleBar(title: 'Late Rent', width: MediaQuery.of(context).size.width * 0.9),
            const SizedBox(height: 18),
            Text(
              'Total Past Due Amount : ${_formatCurrency(_totalPastDueAmount)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) {
                        setState(() => _currentPage = 0);
                      },
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search here...',
                        hintStyle: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600),
                        prefixIcon: const Icon(Icons.search,
                            color: Colors.grey, size: 22),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFFDBE0E5), width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFFDBE0E5), width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFFDBE0E5), width: 1),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String?>(
                      value: _selectedOwnerId,
                      isExpanded: true,
                    dropdownStyleData: DropdownStyleData(
                     maxHeight: 350,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFDBE0E5)),
                        color: Colors.white,
                      ),
                    ),
                    buttonStyleData: ButtonStyleData(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFDBE0E5), width: 1),
                        color: Colors.white,
                      ),
                      height: 45,
                    ),
                    iconStyleData: IconStyleData(
                      icon: const Icon(Icons.keyboard_arrow_down),
                      iconSize: 24,
                      iconEnabledColor: Colors.grey.shade700,
                      iconDisabledColor: Colors.grey,
                    ),
                    hint: const Text('All Owners',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF101828))),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All Owners',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: blueColor,
                                fontSize: 14)),
                      ),
                      ..._rentalOwners.map((o) {
                        return DropdownMenuItem<String?>(
                          value: o.rentalownerId,
                          child: Text(
                            o.displayName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: blueColor,
                                fontSize: 13),
                          ),
                        );
                      }),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _selectedOwnerId = v;
                        _currentPage = 0;
                      });
                    },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTableHeader(),
            const SizedBox(height: 8),
            if (_loadingLetters)
               Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: SpinKitFadingCircle(
                  color: blueColor,
                  size: 40,
                )),
              )
            else if (_filteredLetters.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                alignment: Alignment.center,
                child: const Text(
                  'No result found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              ..._pagedData.asMap().entries.map((entry) {
                final index = entry.key;
                final letter = entry.value;
                return _buildTenantCard(letter, index);
              }),
            if (!_loadingLetters && _filteredLetters.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildPagination(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTenantCard(PreviewLateLetter letter, int index) {
    final isExpanded = _expandedLeaseIds.contains(letter.leaseId);
    final fees = _feesCache[letter.leaseId];
    final loadingFees = _loadingFees[letter.leaseId] == true;
    final rowColor = index % 2 != 0
        ? const Color(0xFFF4F8FF)
        : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 8,top: 4),
      decoration: BoxDecoration(
        color: rowColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDBE0E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedLeaseIds.remove(letter.leaseId);
                } else {
                  _expandedLeaseIds.clear();
                  _expandedLeaseIds.add(letter.leaseId);
                  _fetchUnpaidFees(letter.leaseId);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isExpanded ? Icons.remove : Icons.add,
                    size: 22,
                    color: blueColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          letter.tenantName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF101828),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          letter.fullAddress,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Owner : ${letter.ownerName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 100,
                    child: Text(
                      _formatCurrency(letter.totalAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF101828),
                      ),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade400),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 4),
                      Text(
                        'Charge Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: blueColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  if (loadingFees)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                          child: SpinKitFadingCircle(
                              color: blueColor, size: 40)),
                    )
                  else if (fees != null && fees.isNotEmpty) ...[
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1.8),
                        1: FlexColumnWidth(1.2),
                        2: FlexColumnWidth(1.2),
                        3: FixedColumnWidth(95),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            // color: const Color(0xFFF4F8FF),
                            border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey.shade400, width: 1),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 6),
                              child: Text('DUE DATE',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.black)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 6),
                              child: Text('TYPE',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.black)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 6),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text('AMOUNT',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.black)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 6),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text('AMOUNT DUE',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.black)),
                              ),
                            ),
                          ],
                        ),
                        ..._visibleFeesForLease(letter.leaseId, fees)
                            .map((f) => TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 6),
                                      child: Text(
                                          _formatDate(context, f.date),
                                          style:  TextStyle(fontSize: 12,color: Colors.grey,fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 6),
                                      child: Text(f.type,
                                          style:  TextStyle(fontSize: 12,color: Colors.grey,fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 6),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(_formatCurrency(f.amount),
                                            style:  TextStyle(fontSize: 12,color: Colors.grey,fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 6),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(_formatCurrency(f.dueAmount),
                                            style:  TextStyle(fontSize: 12,color: blueColor,fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                )),
                      ],
                    ),
                    if (fees.length > 10)
                      Padding(
                        padding: const EdgeInsets.only(top: 8,left: 6),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (_chargeViewMoreExpanded
                                  .contains(letter.leaseId)) {
                                _chargeViewMoreExpanded.remove(letter.leaseId);
                              } else {
                                _chargeViewMoreExpanded.add(letter.leaseId);
                              }
                            });
                          },
                          child: Text(
                            _chargeViewMoreExpanded.contains(letter.leaseId)
                                ? 'View less'
                                : 'View more (${fees.length - 10} more)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: blueColor,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Divider(height: 1, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Balance : ${_formatCurrency(letter.totalAmount)}',
                        style:  TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: blueColor,
                        ),
                      ),
                    ),
                  ] else if (fees != null && fees.isEmpty)
                    const Text('No charge details.',
                        style: TextStyle(
                            color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
