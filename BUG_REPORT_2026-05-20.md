# Bug Report — 302-property (CloudRentalManager Flutter App)

**Generated:** 2026-05-20
**Reviewer:** Read-only static review. **No code changes were made.**
**Scope:** Recently modified Dart files (last ~2 weeks of git history), the test/ folder, and a project-wide grep for common bug patterns.
**Note:** Flutter SDK is not available in this sandbox, so `flutter analyze` and `flutter test` could not be run. All findings below come from manual code reading and pattern search.

---

## Summary

| Severity | Count |
|----------|-------|
| HIGH     | 8     |
| MEDIUM   | 11    |
| LOW      | 5     |

Three themes dominate the findings:

1. **Async / lifecycle hazards** — `setState` and `Navigator.pop` called after `await` without `mounted` checks. Easy to crash by backgrounding the app or tapping back at the wrong moment.
2. **Payment math + input parsing** — `double.parse` on user input without `try/catch` or empty checks; surcharge formula repeated 6+ times; index access on lists that may be shorter than expected.
3. **Secrets & configuration in source** — staging URL hardcoded as the production base, RapidAPI key committed to git, iOS App Store placeholder ID still present.

---

## HIGH severity

### H1. Hardcoded RapidAPI key committed to source
- **File:** `lib/screens/Leasing/RentalRoll/Recurring_payment.dart`, line ~707
- Key string `1bd772d3c3msh11c1022dee1c2aep1557bajsn0ac41ea04ef7` is present in the repo. Anyone with repo access (or a decompiled APK) can use it. Treat as already-compromised and rotate.

### H2. Production base URL points to staging
- **File:** `lib/constant/constant.dart`, lines 12 / 20 / 24
- `Api_url`, `image_url`, `image_upload_url` all hardcoded to `https://staging.cloudrentalmanager.com`. Builds shipped from `main` will hit staging.

### H3. Placeholder iOS App Store ID in force-update flow
- **File:** `lib/screens/Splash_Screen/splash_screen.dart`, line 70
- `https://apps.apple.com/app/id0000000000` with TODO. On iOS, the force-update CTA opens a dead URL — users get stuck on the gate with no way out.

### H4. `setState` + `Navigator.pop` after `await` with no `mounted` check (payments)
- **File:** `lib/screens/Leasing/RentalRoll/Edit_make_payment.dart` lines ~3343, 3412, 3458, 3721, 3767
- **File:** `lib/StaffModule/screen/Leasing/RentalRoll/Edit_make_payment.dart` lines ~3524, 3591, 3653, 3721, 3767
- After `PaymentService.…then(...)`, the callback calls `setState` and then `Navigator.pop(context)` with no `if (!mounted) return;`. If the user backs out (or the OS kills/re-attaches the screen) while the API call is in-flight, the framework throws `setState() called after dispose`.

### H5. Force-unwrap of SharedPreferences values
- **File:** `lib/screens/Staff_Member/Staffmemvertable.dart`, lines ~490–491, 657–658
- `String? adminId = prefs.getString("adminId"); … Edit_staff_member(adminId: adminId!, …)`. On first launch (or after a logout that clears prefs), `adminId` and `token` are null and the `!` will throw.

### H6. `double.parse` on raw `TextEditingController.text` without guard
- **File:** `lib/screens/Leasing/RentalRoll/Edit_make_payment.dart` lines ~3390, 3392, 3437, 3439, 3701, 3748
- **File:** `lib/screens/Rental/Tenants/edit_tenants.dart` lines ~2910–2911
- A stray space, an empty field, or a non-numeric paste throws `FormatException` and crashes the screen mid-submit. Use `double.tryParse(...) ?? 0` (don't fix in this review — just noting).

### H7. List index access without bounds check (charges/balances)
- **File:** `lib/screens/Leasing/RentalRoll/Edit_make_payment.dart`, lines ~667, 676, 692
- `charges_balances[index]` accessed during rapid row add/remove. If `index >= charges_balances.length` (e.g. row removed mid-edit), throws `RangeError`.

### H8. Duplicate state variable with different casing
- **File:** `lib/screens/Maintenance/Vendor/edit_vendor.dart`, lines 78–79
- `bool isLoading = false;` AND `bool isloading = false;` are both declared. Code paths that update one but check the other silently desync — common cause of "spinner stuck" or "button stays disabled" bugs.

---

## MEDIUM severity

### M1. Surcharge formula duplicated 6+ times across two files
- `Edit_make_payment.dart` (both `screens/` and `StaffModule/screen/`): the calculation `(double.parse(amount) * (surCharge ?? 0.0) / 100) + double.parse(amount)` appears in 6+ places. When one is patched and the others aren't, totals drift — exactly the kind of thing the recent "Fix charge display and total calculation" commit was about. Worth pulling into one helper at some point.

### M2. Floating-point used for money
- Same files as M1. `double` for currency accumulates rounding error across surcharge + multi-line totals. The visible symptom is "off by a cent" on totals; the audit symptom is mismatched ledger totals.

### M3. Force-cast of dynamic JSON without type check
- **File:** `lib/services/app_version_service.dart`, lines ~43–45
- `data['latest_version'] as String`, `… as bool`. A malformed or partial payload from the version endpoint throws `TypeError` during splash and the user never gets past the loader.

### M4. Silent `catch` that swallows version-check failures
- **File:** `lib/services/app_version_service.dart`, lines ~70–73
- Any error returns `VersionStatus.upToDate`. A real outage of the version endpoint looks identical to a real "you're fine, proceed" — so a broken backend silently masks itself.

### M5. Navigator after `await` without `mounted` (splash)
- **File:** `lib/screens/Splash_Screen/splash_screen.dart`, lines ~336–453, `_navigateToCorrectScreen()`
- Multiple `await provider.fetchXXX()` calls followed by `Navigator.pushReplacement(context, …)` with no `if (!mounted)` between them. Backgrounding the app during splash can crash on resume.

### M6. Missing `await` in card-fetch loop
- **File:** `lib/screens/Leasing/RentalRoll/Recurring_payment.dart`, line ~66
- `fetchcreditcard(tenantId)` is fire-and-forgotten inside `getAllTenantCardData()`. Downstream code runs assuming cards are loaded — race condition produces "no saved cards" on a screen that should show them.

### M7. Unsafe `.first` on possibly-empty list
- **File:** `lib/screens/Leasing/RentalRoll/Recurring_payment.dart`, line ~400, `uploadPdf()`
- `file.first["filename"]`. If the upload service returns an empty `files` array (timeout, validation reject), this throws `StateError`.

### M8. Unbounded loop accessing `cardDetailsList[i]`
- **File:** `lib/screens/Leasing/RentalRoll/Recurring_payment.dart`, line ~823 in `postBillingCustomerVault()`
- Loop is bounded by `customerData.billing.length` but indexes into `cardDetailsList` — if those lengths ever diverge (and there's no guarantee they won't), `RangeError`.

### M9. Empty / print-only `catch` blocks
- **File:** `lib/screens/Rental/Tenants/edit_tenants.dart`, lines ~2655–2664
- **File:** `lib/screens/Staff_Member/Edit_staff_member.dart`, lines ~946–953
- **File:** `lib/screens/Leasing/RentalRoll/Edit_make_payment.dart`, lines 78–92, 98–110, 260–314
- API failures vanish into the console with no user-visible feedback — the screen looks frozen / appears to have worked when it didn't.

### M10. Password validator only checks `null`, not empty string
- **File:** `lib/screens/Maintenance/Vendor/edit_vendor.dart`, lines ~312–314
- Lets `""` through as valid. Depends on what the API does with empty passwords (likely a server-side 4xx, but worth not relying on that).

### M11. `charges_balances` initial state mismatches `rows`
- **File:** `lib/screens/Leasing/RentalRoll/Edit_make_payment.dart`, lines 188–191
- `charges_balances` is preinitialized to `[0.0]` even when `c_data.entry` is empty/null, leaving a stale element that desyncs from `rows` and contributes to H7 above.

---

## LOW severity

### L1. DevicePreview enabled in release builds
- **File:** `lib/main.dart`, lines ~103–110
- `enabled: kDebugMode ? true : true` — the ternary is a no-op. DevicePreview ships in release builds and adds overhead / UI you don't want users to see.

### L2. Unused / duplicated paging state
- **File:** `lib/screens/activity/activity_table.dart`, line ~214 and 313–334 (commented).
- `_tableData` list and orphaned paging logic remain after a refactor. Not a runtime bug but it's a trap for the next person to edit the file.

### L3. Single boilerplate widget test, and it's broken
- **File:** `test/widget_test.dart`
- This is the Flutter default counter test, with `await tester.pumpWidget(MyApp());` commented out. The first `expect(find.text('0'), findsOneWidget);` will fail because nothing was pumped. So `flutter test` will return non-zero — there is effectively no test coverage on the project. (You didn't ask to fix it, just flagging.)

### L4. Extensive PII / API-URL `print()` calls
- **Files:** `lib/constant/constant.dart`, `lib/services/app_version_service.dart`, and many others (project-wide count of `print(` / `debugPrint(`: 64+ occurrences across 10+ files).
- These survive in release builds. If a logcat / device log is ever shared, dates, user actions, API URLs, and response bodies leak. Not a crash, but a real privacy concern in a tenancy product.

### L5. `Edit_staff_member.dart` initState TODO + many other `// TODO: implement initState` markers (~30 files)
- These are autogenerated IDE stubs and harmless on their own, but the codebase-wide grep shows several real TODOs sitting on top of them — particularly `Profile_screen.dart:3654` "Implement actual disable 2FA functionality" and `:3742` "Implement actual regenerate backup codes functionality". If those UI buttons are visible to users, they currently do nothing.

---

## What I did NOT cover

- I did not run `flutter analyze` (Flutter SDK unavailable in this environment). When you run it locally you will get a separate, larger list of analyzer warnings — null safety, dead code, prefer_const, unused imports, etc.
- I did not run `flutter test` for the same reason. The single `test/widget_test.dart` is broken regardless (see L3).
- I did not look at the Android/iOS native sides, the build/ folder, or third-party plugin pins in `pubspec.yaml`.
- I did not review the `StaffModule/` versions of every file — there is heavy duplication between `lib/screens/...` and `lib/StaffModule/screen/...` for the same features (Edit_make_payment, edit_vendor, edit_tenants, etc.). Bugs in one almost certainly exist in the other. Worth running the same checks across the mirrored Staff/Vendor/Tenants modules.

---

## Recommended order to address (when you decide to fix)

1. H1 (rotate RapidAPI key — it's already public if the repo is shared).
2. H2 (point production builds at the production API).
3. H3 (real iOS App Store ID).
4. H4 + M5 (`mounted` checks after `await` — both payment and splash).
5. H5 + H6 + H7 (defensive parsing/index access on the payment screen).
6. M2 (move money math off `double` — `Decimal` package or integer cents).
7. Everything else.

No source files were modified in this review.
