import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:three_zero_two_property/constant/constant.dart';

/// Web-parity read-only view of the Application tab (applicant_details
/// new schema). Renders the same sections as the web ApplicationTab:
/// Personal Information, Move In Date, Additional Residents, Address
/// History, Employment, References, Vehicle Information, Emergency
/// Contact, Pets and Additional Information.
///
/// Documents / Declaration / Signature are intentionally NOT rendered
/// here (handled in a later phase). Shared by Admin and Staff modules.
class ApplicationDetailsView extends StatelessWidget {
  final Map<String, dynamic> raw;
  final VoidCallback? onEdit;
  final String dateFormat;

  const ApplicationDetailsView({
    Key? key,
    required this.raw,
    this.onEdit,
    this.dateFormat = 'MM/dd/yyyy',
  }) : super(key: key);

  static const Color _borderColor = Color(0xFFDBE0E5);
  static const Color _innerBorderColor = Color(0xFFE9EBF2);
  static const Color _valueColor = Color(0xFF626262);
  static const Color _mutedColor = Color(0xFF8A95A8);

  // ---------------------------------------------------------------- helpers

  String _str(dynamic v) {
    final s = (v ?? '').toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return 'N/A';
    return s;
  }

  /// Web-parity fallback for the two renamed emergency-contact fields:
  /// prefer the new key, fall back to the legacy key when the new one is
  /// empty. Mirrors ApplicantSummary.js (`relation || relationship`,
  /// `phoneNumber || phone_number`) so records stored under either schema
  /// display correctly.
  dynamic _emOrLegacy(dynamic primary, dynamic legacy) {
    final p = (primary ?? '').toString().trim();
    return (p.isEmpty || p.toLowerCase() == 'null') ? legacy : primary;
  }

  String _rawStr(String key) => _str(raw[key]);

  String _fullName() {
    final name =
        '${(raw['applicant_firstName'] ?? '').toString().trim()} ${(raw['applicant_lastName'] ?? '').toString().trim()}'
            .trim();
    return name.isEmpty ? 'N/A' : name;
  }

  /// Joins non-empty address parts with ", " (street, city, state, zip...).
  String _joinAddress(List<dynamic> parts) {
    final filled = parts
        .map((p) => (p ?? '').toString().trim())
        .where((p) => p.isNotEmpty && p.toLowerCase() != 'null')
        .toList();
    return filled.isEmpty ? 'N/A' : filled.join(', ');
  }

  /// "$ 50,000" -> "$50,000", "1450" -> "$1450", "" -> "N/A".
  String _money(dynamic v) {
    final s =
        (v ?? '').toString().replaceAll('\$', '').replaceAll(' ', '').trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return 'N/A';
    return '\$$s';
  }

  /// Formats API dates (yyyy-MM-dd, yyyy-MMM-dd, ...) to the app's
  /// configured date format; falls back to the original string.
  String _date(dynamic v) {
    final s = (v ?? '').toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return 'N/A';
    const inputFormats = [
      'yyyy-MM-dd',
      'yyyy-MMM-dd',
      'yyyy-M-d',
      'MM/dd/yyyy',
      'M/d/yyyy',
      'dd-MM-yyyy',
    ];
    for (final f in inputFormats) {
      try {
        final parsed = DateFormat(f).parseStrict(s);
        return DateFormat(dateFormat).format(parsed);
      } catch (_) {}
    }
    final parsed = DateTime.tryParse(s);
    if (parsed != null) return DateFormat(dateFormat).format(parsed);
    return s;
  }

  bool _isTrue(dynamic v) {
    final s = (v ?? '').toString().toLowerCase().trim();
    return v == true || s == 'true' || s == 'yes' || s == '1';
  }

  bool _hasAnyValue(Map e) => e.entries.any((kv) =>
      kv.key != '_id' &&
      kv.key != 'child_id' &&
      kv.key != 'is_current_address' &&
      kv.key != 'is_current_employment' &&
      (kv.value ?? '').toString().trim().isNotEmpty);

  /// Entries of a list field, keeping only the ones that actually carry
  /// data (the API frequently returns one fully blank placeholder entry).
  List<Map<String, dynamic>> _list(String key) {
    final v = raw[key];
    if (v is! List) return [];
    return v
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .where(_hasAnyValue)
        .toList();
  }

  /// Resolves employment `resident_id` -> applicant / additional resident name.
  /// Web stores additional residents as "resident_<index>".
  String _residentName(dynamic residentId) {
    final id = (residentId ?? '').toString().trim();
    if (id.isEmpty) return 'N/A';
    if (id.toLowerCase() == 'primary') {
      final name = _fullName();
      return name == 'N/A' ? 'Primary Applicant' : name;
    }
    final rawResidents = raw['additional_residents'];
    if (id.toLowerCase().startsWith('resident_')) {
      final idx = int.tryParse(id.substring('resident_'.length));
      if (idx != null &&
          rawResidents is List &&
          idx >= 0 &&
          idx < rawResidents.length &&
          rawResidents[idx] is Map) {
        final n = (rawResidents[idx]['name'] ?? '').toString().trim();
        if (n.isNotEmpty) return n;
      }
    }
    if (rawResidents is List) {
      for (final r in rawResidents) {
        if (r is Map &&
            ((r['child_id']?.toString() ?? '') == id ||
                (r['_id']?.toString() ?? '') == id)) {
          final n = (r['name'] ?? '').toString().trim();
          if (n.isNotEmpty) return n;
        }
      }
    }
    return id;
  }

  /// Web merge rule: the stored `emergency_contacts` array can be partial
  /// (only name+email) while the singular `emergency_contact` holds the full
  /// record (relationship/phone_number). Merge the singular into the first
  /// entry so those fields aren't shown as N/A — mirroring ApplicationEditForm's
  /// load merge and the web view. Section hidden when neither has values.
  List<Map<String, dynamic>> _emergencyEntries() {
    final single = raw['emergency_contact'] is Map
        ? Map<String, dynamic>.from(raw['emergency_contact'] as Map)
        : <String, dynamic>{};
    final array = _list('emergency_contacts');
    if (array.isEmpty) {
      return _hasAnyValue(single) ? [single] : [];
    }
    if (_hasAnyValue(single)) {
      // new + legacy key spellings so either schema survives the merge
      const keys = [
        'name', 'relationship', 'relation',
        'email', 'phone_number', 'phoneNumber',
      ];
      for (final k in keys) {
        final cur = (array[0][k] ?? '').toString().trim();
        if (cur.isEmpty && (single[k] ?? '').toString().trim().isNotEmpty) {
          array[0][k] = single[k];
        }
      }
    }
    return array;
  }

  // ------------------------------------------------------------ UI building

  /// Section card — same anatomy as the Summary tab cards.
  Widget _card({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(2, 0, 2, 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: blueColor,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _cell(_F f) {
    final isNA = f.value == 'N/A';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          f.label,
          style: TextStyle(
            color: blueColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          f.value,
          style: TextStyle(
            color: isNA ? _mutedColor : _valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Lays fields out two per row; `wide` fields take the full row.
  Widget _grid(List<_F> fields) {
    final rows = <Widget>[];
    int i = 0;
    while (i < fields.length) {
      if (fields[i].wide) {
        rows.add(_cell(fields[i]));
        i++;
      } else if (i + 1 < fields.length && !fields[i + 1].wide) {
        rows.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _cell(fields[i])),
            const SizedBox(width: 14),
            Expanded(child: _cell(fields[i + 1])),
          ],
        ));
        i += 2;
      } else {
        rows.add(_cell(fields[i]));
        i++;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int r = 0; r < rows.length; r++)
          Padding(
            padding:
                EdgeInsets.only(bottom: r == rows.length - 1 ? 0 : 14),
            child: rows[r],
          ),
      ],
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _innerBorderColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: blueColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// Inner bordered box per repeating entry — same language as the
  /// Summary tab checklist item boxes.
  Widget _entryBox({
    String? title,
    String? chip,
    required Widget child,
    bool isLast = false,
  }) {
    final showHeader = title != null || chip != null;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _innerBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            Row(
              children: [
                if (title != null)
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: blueColor,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                if (chip != null) _chip(chip),
              ],
            ),
            const SizedBox(height: 11),
          ],
          child,
        ],
      ),
    );
  }

  Widget _groupTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          color: blueColor,
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _groupDivider() {
    return Container(
      height: 1,
      color: _innerBorderColor,
      margin: const EdgeInsets.symmetric(vertical: 14),
    );
  }

  /// Repeating-entry section body; when there is no data the fields are
  /// still rendered with N/A values (web-style).
  List<Widget> _entries(
    List<Map<String, dynamic>> items,
    String entryLabel,
    List<_F> Function(Map<String, dynamic> item) entryFields, {
    String? Function(Map<String, dynamic> item, int index)? entryChip,
  }) {
    // A section with no data still renders one placeholder entry of N/A fields.
    // That placeholder must never carry a chip: an index-based chip (see the
    // Address History call site) would otherwise mark the empty placeholder
    // "Current", which is worse than the flag-based chip it replaced — an
    // absent flag simply produced no chip.
    final bool hasData = items.isNotEmpty;
    if (items.isEmpty) items = [<String, dynamic>{}];
    final children = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      final chip = hasData ? entryChip?.call(items[i], i) : null;
      children.add(_entryBox(
        title: items.length > 1 || chip != null
            ? '$entryLabel ${items.length > 1 ? i + 1 : 1}'
            : null,
        chip: chip,
        isLast: i == items.length - 1,
        child: _grid(entryFields(items[i])),
      ));
    }
    return children;
  }

  // ---------------------------------------------------------------- sections

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Applicant Details',
              style: TextStyle(
                color: blueColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (onEdit != null)
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: blueColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.edit_outlined, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Edit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _personalInfoCard() {
    return _card(
      title: 'Personal Information',
      children: [
        _grid([
          _F('Name', _fullName()),
          _F('Birth Date', _date(raw['applicant_birthDate'])),
          _F(
            'Current Address',
            _joinAddress([
              raw['applicant_streetAddress'],
              raw['applicant_city'],
              raw['applicant_state'],
              raw['applicant_country'],
              raw['applicant_postalCode'],
            ]),
            wide: true,
          ),
          _F('Email', _rawStr('applicant_email'), wide: true),
          _F('Cell Phone Number', _rawStr('applicant_phoneNumber')),
          _F("Driver's License State", _rawStr('state')),
          _F("Driver's License Number", _rawStr('driver_license')),
        ]),
      ],
    );
  }

  Widget _moveInCard() {
    final value = _date(raw['move_in_date']);
    return _card(
      title: 'Move In Date',
      children: [
        Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              color: _mutedColor,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              value,
              style: TextStyle(
                color: value == 'N/A' ? _mutedColor : _valueColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _residentsCard() {
    return _card(
      title: 'Additional Residents',
      children: _entries(
        _list('additional_residents'),
        'Resident',
        (r) => [
          _F('Name', _str(r['name'])),
          _F('Relationship', _str(r['relation'])),
          _F('Birth Date', _date(r['dob'])),
          _F('Phone Number', _str(r['phoneNumber'])),
          _F('Email', _str(r['email']), wide: true),
        ],
      ),
    );
  }

  Widget _addressHistoryCard() {
    return _card(
      title: 'Address History',
      children: _entries(
        _list('address_history'),
        'Address',
        (a) => [
          _F(
            'Address',
            _joinAddress([a['street'], a['city'], a['state'], a['zip']]),
            wide: true,
          ),
          _F('From Date', _date(a['from_date'])),
          _F('To Date', _date(a['to_date'])),
          _F('Monthly Rent', _money(a['monthly_payment'])),
          _F('Landlord', _str(a['landlord'])),
          _F('Landlord Phone', _str(a['landlord_phone'])),
        ],
        // Web parity: the FIRST address entry is always the current one, and
        // web ignores `is_current_address` entirely when deciding this
        // (ApplicationTab.jsx, both the desktop grid and the mobile accordion,
        // each carry the comment "First address (index 0) is always current"
        // above an `index === 0` test). Reading the flag instead was wrong
        // because the server schema defaults it to false, so any record where
        // the backend never set it showed no current-address marker at all.
        //
        // Employment below is deliberately NOT changed to match: web really
        // does read `is_current_employment` there. The two sections differ.
        entryChip: (a, index) => index == 0 ? 'Current' : null,
      ),
    );
  }

  Widget _employmentCard() {
    return _card(
      title: 'Employment',
      children: _entries(
        _list('employment_history'),
        'Employment',
        (e) => [
          _F('Resident', _residentName(e['resident_id'])),
          _F('Employer', _str(e['employer'])),
          _F('From Date', _date(e['from_date'])),
          _F('To Date', _date(e['to_date'])),
          _F('HR Contact', _str(e['hr_contact'])),
          _F('Salary', _money(e['salary'])),
          _F('Salary Frequency', _str(e['salary_frequency'])),
        ],
        entryChip: (e, _) =>
            _isTrue(e['is_current_employment']) ? 'Current' : null,
      ),
    );
  }

  Widget _referencesCard() {
    return _card(
      title: 'References',
      children: _entries(
        _list('personal_references'),
        'Reference',
        (r) => [
          _F('Name', _str(r['name'])),
          _F('Phone Number', _str(r['phone'])),
          _F('Years Acquainted', _str(r['years_acquainted'])),
          _F(
            'Address',
            _joinAddress([r['address'], r['city'], r['state'], r['zip']]),
            wide: true,
          ),
        ],
      ),
    );
  }

  Widget _vehiclesCard() {
    return _card(
      title: 'Vehicle Information',
      children: _entries(
        _list('vehicles'),
        'Vehicle',
        (v) => [
          _F('Make & Model', _str(v['make_model'])),
          _F('Year', _str(v['year'])),
          _F('License Plate', _str(v['license_plate'])),
          _F('State', _str(v['state'])),
        ],
      ),
    );
  }

  Widget _emergencyCard() {
    return _card(
      title: 'Emergency Contact',
      children: _entries(
        _emergencyEntries(),
        'Contact',
        (e) => [
          _F('Name', _str(e['name'])),
          _F('Relationship', _str(_emOrLegacy(e['relationship'], e['relation']))),
          _F('Phone Number',
              _str(_emOrLegacy(e['phone_number'], e['phoneNumber']))),
          _F('Email', _str(e['email'])),
        ],
      ),
    );
  }

  Widget _petsCard() {
    return _card(
      title: 'Pets',
      children: _entries(
        _list('pets'),
        'Pet',
        (p) => [
          _F('Type', _str(p['type'])),
          _F('Breed', _str(p['breed'])),
          _F('Color', _str(p['color'])),
          _F('Weight', _str(p['weight'])),
          _F('Age', _str(p['age'])),
          _F('Sex', _str(p['sex'])),
          _F('Neutered', _str(p['neutered'])),
          _F('Declawed', _str(p['declawed'])),
        ],
      ),
    );
  }

  Widget _additionalInfoCard() {
    final hasBankruptcy = _isTrue(raw['has_bankruptcy']);
    final hasInsurance = _isTrue(raw['has_renters_insurance']);
    return _card(
      title: 'Additional Information',
      children: [
        _groupTitle('Bankruptcy'),
        _grid([
          _F('Filed Bankruptcy?', _rawStr('has_bankruptcy')),
          if (hasBankruptcy)
            _F('Bankruptcy Date', _date(raw['bankruptcy_date'])),
        ]),
        _groupDivider(),
        _groupTitle('Rental History'),
        _grid([
          _F('Ever been evicted?', _rawStr('has_eviction')),
          _F('Ever refused to pay rent?', _rawStr('has_refused_rent')),
        ]),
        _groupDivider(),
        _groupTitle("Renter's Insurance"),
        _grid([
          _F("Has Renter's Insurance?", _rawStr('has_renters_insurance')),
          if (hasInsurance)
            _F('Insurance Company', _rawStr('renters_insurance_company')),
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(),
          _personalInfoCard(),
          _moveInCard(),
          _residentsCard(),
          _addressHistoryCard(),
          _employmentCard(),
          _referencesCard(),
          _vehiclesCard(),
          // Web parity: Emergency Contact is hidden entirely when there is
          // no contact data (every other section still shows N/A).
          if (_emergencyEntries().isNotEmpty) _emergencyCard(),
          _petsCard(),
          _additionalInfoCard(),
        ],
      ),
    );
  }
}

class _F {
  final String label;
  final String value;
  final bool wide;
  const _F(this.label, this.value, {this.wide = false});
}
