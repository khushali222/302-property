import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/custom_drawer.dart';
import 'package:three_zero_two_property/StaffModule/widgets/appbar.dart'
    as staff_appbar;
import 'package:three_zero_two_property/StaffModule/widgets/custom_drawer.dart'
    as staff_drawer;

/// One assigned property row: rental_id, display address, allocation method, manual percent (when manual).
class AssignedProperty {
  final String rentalId;
  String fullAddress;
  String allocationMethod; // 'proportional_by_value' | 'manual_percent'
  int manualPercent;

  AssignedProperty({
    required this.rentalId,
    required this.fullAddress,
    this.allocationMethod = 'proportional_by_value',
    this.manualPercent = 0,
  });
}

/// Assign Properties dialog/screen for a mortgage. Loads properties from API,
/// lets user add/remove and set allocation (Proportional or Manual Percent with total 100%).
/// Set [fullScreen] true to open as a full screen (better for mobile) instead of a popup.
/// Set [isStaffModule] true when opened from StaffModule to use Staff app bar and drawer.
class AssignPropertiesDialog extends StatefulWidget {
  final String mortgageId;
  final String mortgageNo;
  final List<dynamic>? initialPropertyIds;
  final List<dynamic>? initialPropertyAssignments;
  final bool fullScreen;
  final bool isStaffModule;

  const AssignPropertiesDialog({
    Key? key,
    required this.mortgageId,
    required this.mortgageNo,
    this.initialPropertyIds,
    this.initialPropertyAssignments,
    this.fullScreen = false,
    this.isStaffModule = false,
  }) : super(key: key);

  @override
  State<AssignPropertiesDialog> createState() => _AssignPropertiesDialogState();
}

class _AssignPropertiesDialogState extends State<AssignPropertiesDialog> {
  List<Map<String, dynamic>> _allProperties = [];
  List<AssignedProperty> _assigned = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _loading = true;
  bool _saving = false;
  String? _loadError;
  bool _showAddList = false;
  bool _showSelectedOnly = false;
  String _globalAllocation = 'proportional_by_value'; // or 'manual_percent'

  @override
  void initState() {
    super.initState();
    _loadProperties();
    _applyInitialAssignments();
  }

  void _applyInitialAssignments() {
    final ids = widget.initialPropertyIds ?? [];
    final assignments = widget.initialPropertyAssignments ?? [];
    final map = <String, Map<String, dynamic>>{};
    for (final a in assignments) {
      if (a is Map && a['rental_id'] != null) {
        map[a['rental_id'].toString()] = Map<String, dynamic>.from(a);
      }
    }
    for (final id in ids) {
      final rid = id.toString();
      final assignment = map[rid];
      final method =
          (assignment?['allocation_method'] ?? 'proportional_by_value')
              .toString();
      final pct = assignment?['manual_percent'];
      final percent = pct is int
          ? pct
          : (pct != null ? int.tryParse(pct.toString()) ?? 0 : 0);
      _assigned.add(AssignedProperty(
        rentalId: rid,
        fullAddress: '',
        allocationMethod: method,
        manualPercent: percent,
      ));
    }
    if (_assigned.isNotEmpty) {
      _globalAllocation = _assigned.first.allocationMethod;
    }
  }

  Future<void> _loadProperties() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final id = prefs.getString('adminId');
      final response = await http.get(
        Uri.parse('$Api_url/api/mortgage/properties/list'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'CRM $token',
          'id': 'CRM $id',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data['data'] as List?;
        if (list != null) {
          final props = List<Map<String, dynamic>>.from(
            list.map((e) => Map<String, dynamic>.from(e as Map)),
          );
          setState(() {
            _allProperties = props;
            _loading = false;
            _fillAssignedAddresses();
          });
          return;
        }
      }
      setState(() {
        _loadError = 'Failed to load properties';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loadError = e.toString();
        _loading = false;
      });
    }
  }

  void _fillAssignedAddresses() {
    final byId = {for (var p in _allProperties) p['rental_id'].toString(): p};
    for (final a in _assigned) {
      final p = byId[a.rentalId];
      if (p != null) {
        a.fullAddress = p['full_address']?.toString() ?? a.fullAddress;
      }
    }
  }

  List<Map<String, dynamic>> get _filteredProperties {
    if (_searchQuery.trim().isEmpty) return _allProperties;
    final q = _searchQuery.trim().toLowerCase();
    return _allProperties.where((p) {
      final addr = (p['full_address'] ?? '').toString().toLowerCase();
      final address = (p['address'] ?? '').toString().toLowerCase();
      final city = (p['city'] ?? '').toString().toLowerCase();
      final state = (p['state'] ?? '').toString().toLowerCase();
      final zip = (p['zipcode'] ?? '').toString().toLowerCase();
      return addr.contains(q) ||
          address.contains(q) ||
          city.contains(q) ||
          state.contains(q) ||
          zip.contains(q);
    }).toList();
  }

  List<Map<String, dynamic>> get _propertiesListForView {
    final list = _filteredProperties;
    if (_showSelectedOnly) {
      return list.where((p) => _isSelected(p['rental_id'].toString())).toList();
    }
    return list;
  }

  void _toggleProperty(Map<String, dynamic> property) {
    final rid = property['rental_id'].toString();
    final idx = _assigned.indexWhere((a) => a.rentalId == rid);
    if (idx >= 0) {
      setState(() {
        _assigned.removeAt(idx);
      });
    } else {
      setState(() {
        _assigned.add(AssignedProperty(
          rentalId: rid,
          fullAddress: property['full_address']?.toString() ?? '',
          allocationMethod: _globalAllocation,
          manualPercent: _assigned.isEmpty ? 100 : 0,
        ));
      });
    }
  }

  bool _isSelected(String rentalId) {
    return _assigned.any((a) => a.rentalId == rentalId);
  }

  void _removeAssigned(String rentalId) {
    setState(() {
      _assigned.removeWhere((a) => a.rentalId == rentalId);
    });
  }

  void _setGlobalAllocation(String method) {
    setState(() {
      _globalAllocation = method;
      for (final a in _assigned) {
        a.allocationMethod = method;
        if (method == 'manual_percent' && a.manualPercent == 0) {
          final n = _assigned.length;
          a.manualPercent = n > 0 ? (100 ~/ n) : 0;
        }
      }
      _redistributeManualPercents();
    });
  }

  void _redistributeManualPercents() {
    if (_assigned.isEmpty || _globalAllocation != 'manual_percent') return;
    final n = _assigned.length;
    final each = 100 ~/ n;
    var remainder = 100 - each * n;
    for (final a in _assigned) {
      a.manualPercent = each + (remainder > 0 ? 1 : 0);
      if (remainder > 0) remainder--;
    }
  }

  void _setManualPercent(AssignedProperty item, int value) {
    setState(() {
      item.manualPercent = value.clamp(0, 100);
    });
  }

  int get _totalManualPercent =>
      _assigned.fold(0, (sum, a) => sum + a.manualPercent);

  bool get _isManualPercentValid =>
      _globalAllocation != 'manual_percent' || _totalManualPercent == 100;

  Future<void> _save() async {
    if (_assigned.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one property.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (!_isManualPercentValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Total manual percent must equal 100%. Current total is $_totalManualPercent%.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final id = prefs.getString('adminId');

      final properties = _assigned.map((a) => a.rentalId).toList();
      final propertyAssignments = _assigned.map((a) {
        final map = <String, dynamic>{
          'rental_id': a.rentalId,
          'allocation_method': a.allocationMethod,
        };
        if (a.allocationMethod == 'manual_percent') {
          map['manual_percent'] = a.manualPercent;
        }
        return map;
      }).toList();

      final body = {
        'properties': properties,
        'property_assignments': propertyAssignments,
        'is_web': true,
      };

      final response = await http
          .put(
            Uri.parse('$Api_url/api/mortgage/${widget.mortgageId}'),
            headers: {
              'Content-Type': 'application/json',
              'authorization': 'CRM $token',
              'id': 'CRM $id',
            },
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (mounted) {
        setState(() => _saving = false);
        if (response.statusCode == 200 || response.statusCode == 201) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Property assignments saved successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          final err = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err['message']?.toString() ?? 'Failed to save'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fullScreen) {
      final leading = IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(false),
      );

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: widget.isStaffModule
            ? staff_appbar.widget_302_Staff.App_Bar(
                context: context,
                leading: leading,
              )
            : widget_302.App_Bar(
                context: context,
                leading: leading,
              ),
        drawer: widget.isStaffModule
            ? staff_drawer.CustomDrawerStaff(
                currentpage: "Mortgage", dropdown: true)
            : CustomDrawer(currentpage: "Mortgage", dropdown: true),
        body: Column(
          children: [
            // const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 14),
              child: Row(
                children: [
                   Material(
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                      ),
                    ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                    child: Text(
                      'Assign Properties',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: blueColor),
                    ),
                  ),
                
              ]),
            ),
           
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopSection(),
                    const SizedBox(height: 16),
                    _buildAssignedSection(),
                    const SizedBox(height: 24),
                    _buildInlineActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAddSection(),
                    const SizedBox(height: 16),
                    _buildAssignedSection(),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFDBE0E5)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<bool>(
                    value: _showSelectedOnly,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: blueColor),
                    items: const [
                      DropdownMenuItem(
                          value: false, child: Text('All properties')),
                      DropdownMenuItem(
                          value: true, child: Text('Selected only')),
                    ],
                    onChanged: (v) =>
                        setState(() => _showSelectedOnly = v ?? false),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: blueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: blueColor),
              ),
              child: Text(
                'Selected: ${_assigned.length}',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: blueColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Add property',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: blueColor,
          ),
        ),
        const SizedBox(height: 8),
        // Search bar commented out as per request
        // TextField(
        //   controller: _searchController,
        //   onChanged: (v) => setState(() => _searchQuery = v),
        //   decoration: InputDecoration(
        //     hintText: 'Search by address or zip code',
        //     hintStyle: const TextStyle(color: Color(0xFF8A95A8)),
        //     prefixIcon:
        //         const Icon(Icons.search, color: Color(0xFF8A95A8), size: 22),
        //     isDense: true,
        //     contentPadding:
        //         const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        //     filled: true,
        //     fillColor: Colors.grey.shade50,
        //   ),
        // ),
        // const SizedBox(height: 8),
        if (_loadError != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(_loadError!, style: const TextStyle(color: Colors.red)),
          )
        else
          DropdownButtonHideUnderline(
            child: DropdownButton2<Map<String, dynamic>>(
              isExpanded: true,
              hint: Text(
                _loading ? 'Loading properties...' : 'Select properties',
                style: TextStyle(
                  fontSize: 14,
                  color: _loading ? Colors.grey : Colors.black87,
                ),
              ),
              value: null,
              items: _loading
                  ? []
                  : _propertiesListForView
                      .map((p) => DropdownMenuItem<Map<String, dynamic>>(
                            value: p,
                            child: Builder(
                              builder: (context) {
                                final rid = p['rental_id'].toString();
                                final selected = _isSelected(rid);
                                final label =
                                    p['full_address']?.toString() ?? rid;
                                return Material(
                                  color: selected
                                      ? const Color(0xFFE8F0FE)
                                      : Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: selected,
                                          onChanged: null,
                                          activeColor: blueColor,
                                        ),
                                        Expanded(
                                          child: Text(
                                            label,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ))
                      .toList(),
              onChanged: (Map<String, dynamic>? p) {
                if (p != null) {
                  _toggleProperty(p);
                  setState(() {});
                }
              },
              buttonStyleData: ButtonStyleData(
                height: 48,
                padding: const EdgeInsets.only(left: 14, right: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF8A95A8)),
                  color: Colors.white,
                ),
                elevation: 0,
              ),
              iconStyleData: IconStyleData(
                icon: Icon(Icons.arrow_drop_down, color: blueColor),
                iconSize: 24,
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFDBE0E5)),
                ),
                scrollbarTheme: ScrollbarThemeData(
                  radius: const Radius.circular(6),
                  thickness: MaterialStateProperty.all(6),
                  thumbVisibility: MaterialStateProperty.all(true),
                ),
              ),
              menuItemStyleData: const MenuItemStyleData(
                height: 48,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInlineActions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed:
                    _saving ? null : () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade400),
                  backgroundColor: Colors.white,
                ),
                child: const Text('Cancel'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueColor,
                  foregroundColor: Colors.white,
                ),
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Assign Properties — ${widget.mortgageNo}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: blueColor,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(false),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _showAddList = !_showAddList),
          child: Text(
            'Add properties',
            style: TextStyle(
              color: blueColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        if (_showAddList) ...[
          const SizedBox(height: 8),
          Text('Selected: ${_assigned.length}',
              style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: const InputDecoration(
              hintText: 'Search by address, city, state, zip...',
              hintStyle: TextStyle(color: Color(0xFF8A95A8)),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          if (_loading)
            const Center(
                child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ))
          else if (_loadError != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child:
                  Text(_loadError!, style: const TextStyle(color: Colors.red)),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredProperties.length,
                itemBuilder: (_, i) {
                  final p = _filteredProperties[i];
                  final rid = p['rental_id'].toString();
                  final selected = _isSelected(rid);
                  return Material(
                    color:
                        selected ? const Color(0xFFE8F0FE) : Colors.transparent,
                    child: CheckboxListTile(
                      value: selected,
                      onChanged: (_) => _toggleProperty(p),
                      title: Text(
                        p['full_address']?.toString() ?? rid,
                        style: const TextStyle(fontSize: 13),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                    ),
                  );
                },
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildAssignedSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDBE0E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CURRENTLY ASSIGNED',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: blueColor,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use one allocation method for all properties: either Proportional or Manual Percent. If Manual Percent, every property must have a percent and the total must equal 100%.',
            style: TextStyle(fontSize: 12, color: Color(0xFF1E3A8A)),
          ),
          if (!_isManualPercentValid) ...[
            const SizedBox(height: 6),
            Text(
              'Total manual percent must equal 100%. Current percent is $_totalManualPercent%.',
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
          const SizedBox(height: 16),
          if (_assigned.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No properties assigned.',
                  style: TextStyle(color: Colors.grey)),
            )
          else
            ..._assigned.map((a) => _buildAssignedCard(a)),
        ],
      ),
    );
  }

  Widget _buildAssignedCard(AssignedProperty a) {
    final isManual = _globalAllocation == 'manual_percent';
    final address = a.fullAddress.isEmpty ? a.rentalId : a.fullAddress;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDBE0E5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    address,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A8A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      size: 22, color: Colors.red.shade400),
                  onPressed: () => _removeAssigned(a.rentalId),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Method',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFDBE0E5)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: DropdownButton<String>(
                          value: a.allocationMethod,
                          isExpanded: true,
                          isDense: true,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                                value: 'proportional_by_value',
                                child: Text('Proportional')),
                            DropdownMenuItem(
                                value: 'manual_percent',
                                child: Text('Manual Percent')),
                          ],
                          onChanged: (v) {
                            if (v != null) _setGlobalAllocation(v);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Allocation (%)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      isManual
                          ? TextFormField(
                              key: ValueKey(
                                  'pct_${a.rentalId}_${a.manualPercent}'),
                              initialValue: '${a.manualPercent}',
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(),
                                suffixText: '%',
                              ),
                              onChanged: (v) {
                                _setManualPercent(a, int.tryParse(v) ?? 0);
                              },
                            )
                          : Container(
                              height: 40,
                              alignment: Alignment.centerLeft,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xFFDBE0E5)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('—',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14)),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: blueColor,
              foregroundColor: Colors.white,
            ),
            child: _saving
                ? const SpinKitFadingCircle(
                    color: Colors.white,
                    size: 25.0,
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );
  }
}
