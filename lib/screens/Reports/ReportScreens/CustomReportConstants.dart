/// Date range options - same as used in other reports (PropertyRevenueReport, etc.)
const List<String> customReportDateRangeOptions = [
  'None',
  'Today',
  'Yesterday',
  'Last 7 Days',
  'Last 14 Days',
  'Last 30 Days',
  'This Week',
  'Last Week',
  'This Month',
  'Last Month',
  'This Quarter',
  'Last Quarter',
  'Year to Date (YTD)',
  'Last Year',
  'Each Calendar Year for the Last 10 Years',
  'Custom Date Range',
];

/// API column key -> display label for Custom Report Builder
const Map<String, String> customReportColumnLabels = {
  'rental_adress': 'Property',
  'rental_unit': 'Unit',
  'tenant': 'Tenant',
  'lease': 'Lease',
  'start_date': 'Lease Start',
  'end_date': 'Lease End',
  'lease_amount': 'Monthly Rent',
  'lease_type': 'Lease Type',
  'balance': 'Balance',
  'rentDueAmount': 'Rent Due',
  'rental_adress_street': 'Street',
  'rental_city': 'City',
  'rental_state': 'State',
  'rental_postcode': 'Zip',
  'subdivision': 'Subdivision',
  'parcel_number': 'Parcel #',
  'purchase_date': 'Purchased',
  'purchase_price': 'Purchase Price',
  'insured_value': 'Insured Value',
  'insurance_premium': 'Insurance Cost',
  'tax_amount': 'Tax Bills',
  'zillow_value': 'Zillow',
  'mortgaged': 'Mortgaged',
  'bank_name': 'Mortgage Bank',
  'mortgage_no': 'Mortgage Number',
  'mortgage_update_date': 'Mortgage Update Date',
  'remaining_balance': 'Mortgage Balance',
  'mortgage_start_date': 'Mortgage Date',
  'mortgage_end_date': 'Maturity Date',
  'monthly_payment': 'Payment',
  'interest_rate': 'Interest %',
};

List<String> get customReportColumnKeys =>
    customReportColumnLabels.keys.toList();

/// Columns that require lease type selection (dialog then confirm → checkbox)
const String customReportLeaseTypeColumnKey = 'lease';

/// Columns that require date range (from/to) - show Enter Date dialog
const List<String> customReportDateRangeColumnKeys = ['start_date', 'end_date'];

/// Columns that require single date - show Enter Date dialog
const List<String> customReportSingleDateColumnKeys = ['lease_amount'];

/// Columns that require year(s) selection - show Select Years dialog
const List<String> customReportYearsColumnKeys = [
  'insured_value',
  'insurance_premium',
  'tax_amount',
  'zillow_value',
];

/// Lease type options for the Lease column
const List<String> customReportLeaseTypeOptions = [
  'All',
  'Active',
  'Expired',
  'Future',
];
