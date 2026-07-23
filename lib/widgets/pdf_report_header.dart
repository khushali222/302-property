/// Helpers for building report PDF headers so every report matches the web
/// (Client/src/views/.../functions.js). The web builds the company/contact
/// block by dropping empty fields — it never prints "N/A" — and collapses
/// City / State / Country into a single comma-joined line:
///
///   [company_name, company_address,
///    [city, state, country].filter(Boolean).join(", "),
///    postal_code].filter(Boolean).join("\n")
///
/// Use [buildPdfCompanyLines] to get the non-empty lines in that same order,
/// then render each as a pw.Text with the screen's own style.
library;

List<String> buildPdfCompanyLines({
  String? companyName,
  String? companyAddress,
  String? companyCity,
  String? companyState,
  String? companyCountry,
  String? companyPostalCode,
}) {
  String clean(String? s) => (s ?? '').trim();

  final String cityStateCountry = [companyCity, companyState, companyCountry]
      .map(clean)
      .where((s) => s.isNotEmpty)
      .join(', ');

  return [
    clean(companyName),
    clean(companyAddress),
    cityStateCountry,
    clean(companyPostalCode),
  ].where((s) => s.isNotEmpty).toList();
}
