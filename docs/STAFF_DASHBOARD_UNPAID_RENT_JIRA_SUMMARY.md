# Jira Summary: Staff Dashboard – Unpaid Rent Chart & Data Logic

## Epic / Story
**Staff dashboard: Replace work-order chart with “Percentage of Unpaid Rent” chart and align data with web.**

---

## Overview (whole chat – for Jira description)
Replaced the staff dashboard work-order pie chart with a “Percentage of Unpaid Rent” card. Total Unpaid comes from the Preview Late Letters API (`total_past_due_amount`) with fallback to the Balance API (`totalRentPastDue`). Total Rental Property and Total Properties with Unpaid Rent come from the Balance API (`totalActiveLeases`, `totalUnpaidRentLeases`). The pie chart shows unpaid (dark blue) and paid (light blue) segments matching the web; legend text wraps on small phones. Tapping a pie segment shows a tooltip with that segment’s percentage (e.g. “Unpaid Rent: 66.7%” or “Paid: 33.3%”); tooltip clears on release. Old work-order chart logic is kept in comments.

---

## Objective
- Replace the staff dashboard’s work-order pie chart with a “Percentage of Unpaid Rent” chart.
- Use the same data sources and logic as the web app so mobile and web match.
- Fix chart direction/colors to match web (unpaid = large dark blue, paid = small light blue).

---

## Scope
- **File:** `lib/screens/Dashboard/dashboard_sample.dart`
- **Widget:** `UnpaidRentChartCard` (and related fetch logic).
- **APIs:** Balance API, Preview Late Letters API (rentals API removed for this chart).

---

## Changes Implemented (Chronological)

### 1. Initial chart replacement
- Replaced work-order “Analytic” pie chart with “Percentage of Unpaid Rent” card.
- Old work-order chart logic kept in comments for future use.
- Fetched data from:
  - `GET /api/payment/admin_balance/{adminId}`
  - `GET /api/rentals/rentals/{adminId}`
- Initially used: Total Unpaid = sum of lease `balance` from rentals API; Total Rental Property = rentals `data.length`.

### 2. Total Rental Property source
- **Requirement:** “Total Rental Property” must come from balance API.
- **Change:** Use `totalActiveLeases` from balance API for “Total Rental Property” (instead of rentals API length).
- Later reverted to rentals length, then set back to `totalActiveLeases` for consistency with percentage denominator.

### 3. Total Unpaid – multiple iterations
- **First:** Total Unpaid = `totalRentPastDue` from balance API.
- **Then:** Total Unpaid = sum of lease `balance` from rentals API (to match web $324k vs API $217k).
- **Then:** Sum only leases with `rentDaysPastDue > 0` to reduce over-count (e.g. $362k → closer to web).
- **Final:** Total Unpaid = **`total_past_due_amount`** from **Preview Late Letters API** (`GET /api/leases/preview-late-letters/{adminId}`), with fallback to balance API `totalRentPastDue` if the late-letters API fails.

### 4. Data source summary (final)
- **Balance API** (`/api/payment/admin_balance/{adminId}`):
  - `totalActiveLeases` → “Total Rental Property”
  - `totalUnpaidRentLeases` → “Total Properties with Unpaid Rent”
  - `totalRentPastDue` → fallback for “Total Unpaid” if late-letters API fails
- **Preview Late Letters API** (`/api/leases/preview-late-letters/{adminId}`):
  - `total_past_due_amount` → **“Total Unpaid”** (primary source)
- **Percentage:** `(totalUnpaidRentLeases / totalActiveLeases) * 100` (0 if no active leases).

### 5. Chart direction and colors (match web)
- **Requirement:** Chart must look like web: large segment = unpaid (e.g. 66.7%), dark blue; small segment = paid (e.g. 33.3%), light blue; unpaid drawn first from top.
- **Change:** Pie sections order and colors:
  - First section (index 0): **unpaid** (percentage value), **dark blue** `RGBO(40, 60, 95)`.
  - Second section (index 1): **paid** (100 − percentage), **light blue** `RGBO(90, 134, 213)`.
- Legend bullet colors: “Unpaid Rent: X%” and “Total Unpaid: $X” use **dark blue** to match the unpaid segment.

### 6. UX and robustness
- Legend text “Total Properties with Unpaid Rent” allowed to wrap on small screens (no cutoff).
- `_legendRow` helper with `softWrap`, `maxLines: 2`, responsive font size.
- Console debug logs added for Balance API, Preview Late Letters API, and chart values (summary lines).

### 7. Documentation in code
- Doc comment above `_fetchUnpaidRentData` describing:
  - Balance API and Preview Late Letters API roles.
  - Which field maps to each summary line (Total Unpaid, Total Rental Property, Total Properties with Unpaid Rent, Percentage).

### 8. Pie chart tooltip on tap
- **Requirement:** When user taps a pie segment, show that segment’s percentage (like reference image).
- **Change:** 
  - Added state `int? _touchedSectionIndex` (0 = Unpaid, 1 = Paid; null when not touching).
  - Wired `PieChartData.pieTouchData` with `PieTouchData(touchCallback: ...)` using fl_chart’s `FlTouchEvent` and `PieTouchResponse`; on touch, set `_touchedSectionIndex` from `response?.touchedSection?.touchedSectionIndex`, clear on release.
  - Wrapped the pie in a `Stack`; when `_touchedSectionIndex != null`, a centered tooltip overlay shows:
    - **Section 0:** “Unpaid Rent: X.X%”
    - **Section 1:** “Paid: X.X%”
  - Tooltip styling: dark blue background, white text, rounded corners, light shadow; disappears when finger lifts or moves off the chart.

---

## Acceptance Criteria (Final)

| # | Criterion | Status |
|---|-----------|--------|
| 1 | Chart shows “Percentage of Unpaid Rent” with pie chart and legend (Unpaid Rent %, Total Unpaid $, Total Properties with Unpaid Rent, Total Rental Property). | Done |
| 2 | Total Unpaid = `total_past_due_amount` from Preview Late Letters API; fallback = balance API `totalRentPastDue`. | Done |
| 3 | Total Rental Property = `totalActiveLeases` from balance API. | Done |
| 4 | Total Properties with Unpaid Rent = `totalUnpaidRentLeases` from balance API. | Done |
| 5 | Percentage = (totalUnpaidRentLeases / totalActiveLeases) × 100. | Done |
| 6 | Chart direction/colors match web: unpaid = large dark blue, paid = small light blue; legend dots for unpaid use dark blue. | Done |
| 7 | No summing of `rentDueAmount` or `balance` from rentals for Total Unpaid; only late-letters API (and balance fallback). | Done |
| 8 | Legend text does not cut off on small phones. | Done |
| 9 | Old work-order chart logic retained in comments. | Done |
| 10 | Tapping a pie segment shows a tooltip with that segment’s percentage (Unpaid Rent: X% or Paid: X%); tooltip clears on release. | Done |

---

## API Contract (Reference)

### Balance API
`GET /api/payment/admin_balance/{adminId}`  
Response: `totalRentPastDue`, `totalActiveLeases`, `totalUnpaidRentLeases`, …

### Preview Late Letters API
`GET /api/leases/preview-late-letters/{adminId}`  
Response: `total_past_due_amount` (number or string), `data[]` (late letter previews).

---

## Testing Notes
- Verify Total Unpaid matches web when late-letters API returns same admin (e.g. $386.00 when `total_past_due_amount: 386`).
- Verify chart shows unpaid as larger dark blue segment and paid as smaller light blue segment.
- Verify on narrow device that “Total Properties with Unpaid Rent” does not truncate.
- Verify tapping the unpaid segment shows “Unpaid Rent: X.X%” and tapping the paid segment shows “Paid: X.X%”; tooltip disappears when touch is released.

---

## Files Touched
- `lib/screens/Dashboard/dashboard_sample.dart` (UnpaidRentChartCard, fetch logic, pie chart, legend).

---

*Summary covers work from initial chart replacement through chart direction/colors, legend wrap, data source alignment, and pie chart tap tooltip (full chat).*
