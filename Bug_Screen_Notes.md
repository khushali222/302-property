# Bug Screen Notes — 302-Property (Flutter)

**Date:** 2026-06-27
**Scope:** Full read-only screen of `lib/` (771 Dart files) by 6 parallel agents.
**Important:** This is a NOTES-ONLY review. **No code was changed.** Line numbers are approximate — verify before fixing.

---

## Summary

| Area | High | Med | Low |
|---|---|---|---|
| StaffModule/screen | 8 | 6 | 6 |
| StaffModule repository/model/widgets | 7 | 8 | 5 |
| screens/Leasing·Rental·Reports | 8 | 16 | 2 |
| misc screens + Model | 6 | 8 | 2 |
| repository/provider/services | 10 | 9 | 6 |
| Tenants/Vendor/widgets | 6 | 9 | 5 |

**Cross-cutting patterns worth fixing systemically (not file-by-file):**

- `int.parse` / `double.parse` on user input and API fields **without `tryParse`** — dozens of sites. Top crash risk.
- `json.decode(response.body)[...]` accessed **before** checking status code / key existence — many repositories.
- **No HTTP timeout** anywhere (`services/api_helpers.dart`) — requests can hang indefinitely.
- Unsafe list access (`[0]`, `.first`, `.last`) without `isNotEmpty` guard.
- `TextEditingController` / `HtmlEditorController` not disposed (memory leaks).
- `void someFn() async` instead of `Future<void>` — errors can't be awaited/caught (Reports screens especially).

---

## HIGH severity

### Logic errors (most important — wrong behavior, not just crashes)

- **TenantsModule/screen/financial/payment/make_payment.dart ~3366, ~3374** — Surcharge condition `(surChargeAchflat != null || surChargeAchflat != 0.0)` is **always true** (should be `&&`). Bypasses surcharge validation → potentially incorrect payment amounts.
- **StaffModule/repository/lease.dart ~121** — `ids: applicantIds.isNotEmpty ? applicantIds : applicantIds` — both ternary branches identical; dead/incorrect logic.
- **screens/Reports/ReportScreens/AccountTotals.dart ~876** — `property.amount ?? 0 / 0` — precedence bug, evaluates `0/0` = NaN. Likely intended `(property.amount ?? 0) / divisor`.

### Crash risk — unsafe parsing on payment/financial paths

- **repository/payment/payment_service.dart ~231, ~482** — `double.parse(totalAmount)` no error handling (payment processing).
- **repository/payment/Edit_payment.dart ~215, ~363** — same unsafe `double.parse`.
- **repository/ScheduledChargesRepository.dart ~79** — `double.parse(amount!)` force-unwrap + parse.
- **TenantsModule/.../payment/make_payment.dart ~1385** — `int.parse(override_fee)` no null/format safety.
- **TenantsModule/.../AddCard/AddCard.dart ~1684, ~425, ~1621** — `double.parse`/`int.parse` of card amount and Luhn digits, unvalidated.
- **StaffModule/repository/payment/payment_service.dart ~232, ~473** and **Edit_payment.dart ~208, ~430** — unsafe `double.parse(totalAmount)`.
- **StaffModule/screen/Settings/Settings_screen.dart** (many lines ~187–463) — `int/double.parse` on TextControllers without try/catch.
- **screens/Dashboard/dashboard_one.dart ~179–185** — multiple `double.parse(data[...])` no try/catch.

### Crash risk — unsafe API/JSON access

- **repository/payment/payment_service.dart ~125–128, ~252–255** — nested `jsonData["data"]["responsetext"]` and re-decoding `response.body` in the throw, no key checks.
- **Model/payments/Payment_refund_model.dart ~58+** and **Model/Dashbord_table/Payment_refund_model.dart ~58–80** — ~21 direct `json["0"]` accesses; crash if key absent.
- **StaffModule/screen/Dashboard/Unpaid_Properties.dart ~116** — `jsonData['data'][0]` no empty check.
- **TenantsModule/.../payment/make_payment.dart ~276** and **dashboard.dart ~126–130** — nested `['data']`/`['balance']` access without null safety.

### Crash risk — unsafe list access / missing dispose

- **screens/Leasing/RentalRoll/make_payment.dart ~1130, ~578, ~200** — `data[0]`, `file.first`, `entry!.first` no empty guard; also TextEditingControllers (~58–60) never disposed.
- **screens/Reports/.../Recurring_Payments_Configuration_table.dart ~905–919** — `tenant.recurrings![0]` no empty check.
- **screens/Communications/Send E-mail/send_mail.dart ~35–37** — HtmlEditorController + 2 TextEditingControllers, no `dispose()`.
- **screens/Reports/.../ExpiringLeases.dart ~83–84** — `_fromDateController`/`_toDateController` not disposed.

### Networking infrastructure

- **services/api_helpers.dart** — no timeout on any HTTP method (apiGet/Post/Put/Delete/Patch). Add a `.timeout(...)`.

---

## MEDIUM severity

- **repository/payment/payment_service.dart ~155–157** — unreachable `return` after error block (dead code).
- **repository/ScheduledChargesRepository.dart ~99–108, ~100, ~131–135** — empty `else` (silent failure on non-2xx); returns raw `response.body` string instead of parsed JSON; decodes body before status check.
- **provider/lease_provider.dart ~75–381** — `notifyListeners()` called without a disposed guard; risk of "called after dispose" from late async callbacks.
- **StaffModule/model/properties.dart ~65, ~74, ~76** — bool/List fields defaulted to `""` (type mismatch in fromJson). Similar in **staffmember.dart ~40–41**, **unit.dart ~29**, **edit_lease.dart ~216–217** (`double.parse` w/o fallback).
- **StaffModule/model/{tenants,vendor,cosigner}.dart** — `.toString()` on possibly-null phone fields → crash; use `?.toString() ?? ""`.
- **StaffModule/model/rental_properties.dart ~147–148**, **Model/edit_lease.dart ~254 / lease.dart ~21–52**, **CustomReportDataModel**, **fetch_payment_table** — `json[...] as List` casts without null checks.
- **Model/applicant_summery_model.dart ~235–236, ~247, ~624** — `json['rental_id'][0]` and `List.join` on possibly-empty/null list.
- **StaffModule/repository/vendor_repository.dart ~28** — posts `toJson()` Map instead of `jsonEncode(...)`; likely missing Content-Type/body encoding.
- **TenantsModule/.../make_payment.dart ~2659–2662** — `double.parse(double.parse(x).toStringAsFixed(2))` redundant double-rounding.
- **TenantsModule/screen/financial/AddAchAccount/AddAchAccount.dart ~210**, **financial_table.dart ~335** — `catch (_) {}` silently swallows errors (user gets no feedback; wrong payment methods may show).
- **screens/Password/otp_vrify.dart ~169–173** — `int.parse(code)` no try/catch.
- **Numerous `void ... async`** that should be `Future<void>`: ExpiringLeases, Home_System_Report, rentalownerreport, RentRollReport, ReopenWorkorder, PropertyTaxReport (export/share), Addmortgage `_saveForm`, changepassword, Property_type_table, email_log_table, Vendor_table.
- Unsafe `.first` without empty checks across **Rental/Rentalowner/rentalowner_summery.dart ~1118**, **Rental/Tenants/Tenant_summary.dart ~3016**, **Rental/Properties/summery_page.dart ~271**, **Leasing/RentalRoll/Recurringpayment.dart ~220**.

---

## LOW severity

- **TenantsModule/.../make_payment.dart ~103** — `await apiPost` without try/catch in token check; ~799 force-unwrap `charges!["override_fee"]`; ~1003 redundant `int.tryParse` of already-int.
- **TenantsModule/.../AddCard/AddCard.dart ~1249** — `Navigator.pop()` in async callback, no `mounted` check.
- **TenantsModule/repository/workorder.dart ~151** & **VendorModule/repository/workorder.dart ~151** — `json.decode` before checking, no try/catch.
- **TenantsModule/model/lease_model.dart ~70** — deprecated `new` keyword (style).
- **repository/ScheduledChargesRepository.dart ~11, ~73** — unused `baseUrl` field and unused `leaseId` param.
- **repository/properties_summery.dart ~27** — hardcoded RapidAPI URL (move to constants).
- **screens/Notifications/notifications.dart ~40** & **TenantsModule notifications ~32** — force-unwrap / `late Future` that may be unassigned if init fails.
- **Communications** (send_mail ~265, Add_mail ~139, email_log_table ~420) — `int.parse` without try/catch.
- Various `double.parse` without try/catch in **Rental/Tenants/{add,edit}_tenants.dart** and **Rental/mortgage/Addmortgage.dart**.

---

## Recommended fix priority

1. The three **logic errors** at the top (wrong payment surcharge `||`, identical-branch ternary, `0/0` NaN) — these produce wrong results silently.
2. **Payment/financial parse + JSON access** crash paths (payment_service, Edit_payment, ScheduledCharges, AddCard, make_payment).
3. Add **HTTP timeout** in `api_helpers.dart` globally.
4. Sweep `parse` → `tryParse` and guard list `.first/[0]` access.
5. `void async` → `Future<void>`; add `dispose()` for controllers; add `mounted` checks after awaits.

*No files were modified during this review.*
