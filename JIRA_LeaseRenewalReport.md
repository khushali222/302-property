# JIRA Ticket: Lease Renewal Report Feature

## Title
**Implement Lease Renewal Report with PDF and Excel Export Functionality**

## Type
Feature

## Priority
High

## Description

### Overview
Implement a comprehensive Lease Renewal Report feature that displays leases ending and month-to-month (MTM) leases with detailed renewal information. The report should include search functionality, date range filtering, expandable lease details, and export capabilities (PDF and Excel).

### User Story
As a property manager/admin, I want to view a detailed lease renewal report so that I can track leases that are ending and month-to-month leases, review financial details, tenant history, and export the data for record-keeping and analysis.

### Requirements

#### 1. Data Display
- Display two separate sections:
  - **Leases Ending**: Leases that are scheduled to end
  - **MTM Leases**: Month-to-month leases
- Each lease entry should show:
  - Property address
  - Tenant name
  - Expandable details with financial and status information

#### 2. Filtering and Search
- Search functionality to filter by property address or tenant name
- Date range dropdown with predefined options:
  - Last Year
  - This Year
  - This Month
  - Last Month
  - Custom (with From/To date pickers)
- "Run Report" button to fetch data based on selected filters

#### 3. Expandable Lease Details
When a lease entry is expanded, display:
- **Financial Details**:
  - Previous year rents (2023, 2024, 2025 for MTM)
  - Deposits
  - New rent amount
  - Rent increase amount
- **Status Details**:
  - Times late count
  - Court filings count
- **Notes Section**: Display all notes associated with the lease (if available)
- **Action Buttons** (optional for future):
  - Approve Renewal
  - Contact Tenant

#### 4. Export Functionality
- **PDF Export**:
  - Generate PDF with proper header (logo, title, date range, company info)
  - Two separate tables: "LEASES ENDING" and "MTM LEASES"
  - All columns with proper formatting
  - Currency formatting for monetary values
  - Landscape orientation for better table display
  - Page numbers in footer
  
- **Excel Export**:
  - Generate Excel file with two separate sheets:
    - "Leases Ending" sheet
    - "MTM Leases" sheet
  - Include title and date range information
  - Formatted headers with blue background
  - Proper data formatting (currency, numbers, dates)
  - Auto-save and share functionality

#### 5. UI/UX Requirements
- Clean, modern design matching existing report screens
- Responsive layout
- Loading states with shimmer effect
- Error handling with user-friendly messages
- Empty state handling ("No data available")
- Expand/collapse icons (up/down arrows) for lease entries

### Technical Implementation

#### API Endpoint
```
GET /api/leases/lease-renewal-report/{adminId}?start_date={startDate}&end_date={endDate}
```

#### Response Structure
```json
{
  "statusCode": 200,
  "data": {
    "leases_ending": [...],
    "mtm_leases": [...],
    "summary": {...}
  },
  "message": "Lease renewal report retrieved successfully"
}
```

#### Files Created/Modified
1. **Model**: `lib/Model/lease_renewal_report.dart`
   - `LeaseRenewalReport` class
   - `LeaseEnding` class
   - `MonthToMonthLease` class
   - Supporting classes: `Tenant`, `RentData`, `Deposits`, `Metrics`, `Note`, `Summary`

2. **Repository**: `lib/repository/lease_renewal_report_repo.dart`
   - `LeaseRenewalReportRepository` class
   - `fetchLeaseRenewalReport()` method

3. **Screen**: `lib/screens/Reports/ReportScreens/LeaseRenewalReport.dart`
   - Main report screen with all UI components
   - PDF generation method
   - Excel generation method
   - Search and filter functionality

4. **Navigation**: `lib/screens/Reports/ReportsMainScreen.dart`
   - Added "Lease Renewal" report card

### Acceptance Criteria

- [ ] Report displays leases ending section with correct data
- [ ] Report displays MTM leases section with correct data
- [ ] Search functionality filters results by property or tenant name
- [ ] Date range dropdown works with all predefined options
- [ ] Custom date range shows From/To date pickers
- [ ] "Run Report" button fetches data based on selected date range
- [ ] Lease entries can be expanded/collapsed
- [ ] Expanded view shows all financial details correctly
- [ ] Expanded view shows status details (times late, court filings)
- [ ] Notes section displays all notes when available
- [ ] PDF export generates correctly with all data
- [ ] Excel export generates correctly with two sheets
- [ ] Export files are properly formatted and shareable
- [ ] Loading states display during data fetch
- [ ] Error messages display appropriately
- [ ] Empty states handled gracefully
- [ ] Report is accessible from Reports main screen
- [ ] All numeric values handle string/number conversion correctly
- [ ] Currency values formatted correctly ($X,XXX.XX)
- [ ] Date values formatted correctly (MM/DD/YYYY)

### Technical Notes

1. **Data Type Handling**: API may return numeric values as strings. Helper functions `_toDouble()` and `_toInt()` handle this conversion safely.

2. **Date Formatting**: 
   - Display format: MM/DD/YYYY
   - API format: yyyy-MM-dd
   - Conversion handled in fetch method

3. **Export Dependencies**:
   - PDF: `pdf` and `printing` packages
   - Excel: `syncfusion_flutter_xlsio` package
   - File sharing: `share_plus` package

4. **State Management**: Uses local state with `setState()` for expand/collapse functionality

### Testing Checklist

- [ ] Test with leases ending data
- [ ] Test with MTM leases data
- [ ] Test with empty data
- [ ] Test search functionality
- [ ] Test all date range options
- [ ] Test custom date range
- [ ] Test expand/collapse functionality
- [ ] Test PDF export
- [ ] Test Excel export
- [ ] Test error handling
- [ ] Test loading states
- [ ] Test on different screen sizes

### Dependencies
- API endpoint must be available and functional
- Admin profile API for PDF header information
- Required packages: pdf, printing, syncfusion_flutter_xlsio, share_plus, path_provider

### Related Issues
- None

### Labels
`feature`, `reports`, `lease-management`, `export`, `pdf`, `excel`

### Sprint
[To be assigned]

### Assignee
[To be assigned]

### Reporter
[Your name/email]

---

## Additional Notes

### Export Column Details

**Leases Ending Table:**
- Property
- Tenant
- 2023 Rent
- 2024 Rent
- Deposits
- New Rent
- Includes Trash?
- Increase
- Times Late
- Court Filings
- Need Trash Svc?
- Notes

**MTM Leases Table:**
- Property
- Tenant
- 2023 Rent
- 2024 Rent
- 2025 Rent
- Last Increase
- Sec. Dep. (Security Deposit)
- New Rent
- Includes Trash?
- Increase
- Late (Times Late)
- Court (Court Filings)
- Need Trash Svc?
- Notes

### Future Enhancements (Out of Scope)
- Approve Renewal functionality
- Contact Tenant functionality
- CSV export
- Email report directly
- Scheduled report generation

