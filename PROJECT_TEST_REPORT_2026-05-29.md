# Full Project Test Report — 2026-05-29

**Scope:** Static, file-by-file review of both Flutter projects:
- `C:\CRM\crmmobile`           (branch context: `development` / `feature/*`)
- `C:\CLoudeRentalManager\302-property`   (branch context: `claude` / `feature/app-versioning-header-update-window`)

Both projects share the same Dart package name (`three_zero_two_property`) and the same overall `lib/` layout, but 302-property is the more recent fork.

> **Why no `flutter test` / `flutter analyze` output?**
> The sandbox where this scan ran has no Dart or Flutter SDK and no network access to Google's SDK mirrors. All findings below are from heuristic static analysis (`grep`, brace/paren accounting, file inspection). To get authoritative results, run `flutter analyze` and `flutter test` from your Windows machine in each project root.

---

## 1. Project size and structure

| Metric                          | crmmobile | 302-property |
| ------------------------------- | --------- | ------------ |
| `.dart` files in `lib/`         | 751       | 755          |
| `lib/` size on disk             | 39 MB     | 39 MB        |
| Files differing between projects | —        | 443          |
| Files only in 302-property      | —         | 4 (new `services/` files) |
| `pubspec.yaml` deps bumped      | —         | 7 packages upgraded, 1 new (`package_info_plus`) |

### Module breakdown (file counts — identical between projects unless noted)

| Module folder            | Files (both) |
| ------------------------ | -----------: |
| `lib/StaffModule`        | 269 |
| `lib/screens`            | 175 |
| `lib/Model`              | 91 |
| `lib/repository`         | 78 |
| `lib/TenantsModule`      | 51 |
| `lib/widgets`            | 33 |
| `lib/VendorModule`       | 31 |
| `lib/provider`           | 12 |
| `lib/services`           | 3 (crmmobile) / **7** (302-property) |
| `lib/constant`           | 3 |
| `lib/Model` + `lib/models` are duplicated holdings — see issue #5 below |

### `lib/screens/` feature folders (file counts)

| Feature           | Files |
| ----------------- | ----: |
| Rental            | 47 |
| Leasing           | 44 |
| Reports           | 32 |
| Dashboard         | 8 |
| Maintenance       | 8 |
| test_table        | 6 |
| Communications    | 5 |
| Plans             | 4 |
| Profile           | 4 |
| Password          | 3 |
| Property_Type     | 3 |
| Staff_Member      | 3 |
| BidRoom           | 2 |
| Signup            | 2 |
| Splash_Screen     | 1 |
| Login             | 1 |
| activity          | 1 |
| notifications     | 1 |

---

## 2. What 302-property added that crmmobile doesn't have

`302-property/lib/services/` adds four files that crmmobile lacks. They form a clean app-versioning / force-update subsystem:

| File                                        | Purpose |
| ------------------------------------------- | ------- |
| `services/app_headers.dart`                 | Caches `x-app-version`, `x-app-platform`, `x-app-channel`, `x-app-bundle`, and `User-Agent`; initialised once in `main()` |
| `services/api_client.dart`                  | Dio instance with `AppVersionInterceptor`; catches HTTP 426 → triggers force-update dialog |
| `services/api_helpers.dart`                 | Drop-in `apiGet/Post/Put/Delete/Patch` wrappers around `package:http` that auto-attach headers and handle 426 |
| `services/force_update_helper.dart`         | Shared force-update modal (Play Store / App Store links) |

302-property has begun migrating call sites in repository files from raw `http.get(...)` to `apiGet(...)` — partial. Many repositories still use bare `http` (see issue #4).

---

## 3. Heuristic health metrics (identical or near-identical between projects)

| Metric                             | crmmobile | 302-property |
| ---------------------------------- | --------: | -----------: |
| `print(...)` calls (top-level)     | 7,268     | 7,284 |
| `TODO` / `FIXME` markers           | 72        | 71 |
| Empty `catch(...) {}` blocks       | 36        | 36 |
| `int.parse(...)` calls             | 102       | 102 |
| `int.tryParse(...)` calls          | 65        | 65 |
| `double.parse(...)` calls          | 189       | 189 |
| `double.tryParse(...)` calls       | 294       | 294 |
| `yourapiurl.com` placeholder hits  | 6         | 6 |
| LAN URL hits (`192.168.x`)         | 16        | 16 |
| `localhost` URL hits               | 4         | 4 |
| `MaterialPageRoute(` count         | 696       | 696 |
| `Navigator.push/pop/of` count      | 1,982     | 1,983 |
| `setState(...)` call sites         | 8,948     | 8,948 |

Conclusion: the underlying code-quality profile is the same in both projects. The fixes proposed here apply to both — the only difference is that 302-property is the right place to land them because it's the newer branch.

---

## 4. Findings, by severity

Below are issues confirmed by file/line in both projects unless otherwise noted. **Severity legend:** P0 = blocks a feature now or ships an obvious bug · P1 = will crash on unexpected input or leaks resources · P2 = smell / cleanup.

### P0 — Placeholder API URL in Vendor add/edit screens

Vendor "Add" and "Edit" screens point at a domain that does not exist. Any vendor save action will fail with DNS/network error.

```
lib/screens/Maintenance/Vendor/add_vendor.dart:48
lib/screens/Maintenance/Vendor/edit_vendor.dart:89
lib/StaffModule/screen/Maintenance/Vendor/add_vendor.dart:960
lib/StaffModule/screen/Maintenance/Vendor/edit_vendor.dart:1096
   VendorRepository(baseUrl: 'https://yourapiurl.com');
```

Fix: replace with `Api_url` from `lib/constant/constant.dart`.

### P0 — Auth headers never implemented

`lib/constant/api_constants.dart` returns headers with no `Authorization`:

```dart
static Future<Map<String, String>> getHeaders() async {
  // TODO: Implement proper authentication headers
  return {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
```

Any caller relying on `ApiConstants.getHeaders()` hits unauthenticated endpoints. Either remove the helper (so the omission is visible at every call site), or wire it to the same auth token used by the rest of the app.

### P0 — Default `widget_test.dart` is broken in both projects

`test/widget_test.dart` is the unmodified Flutter counter template, AND `await tester.pumpWidget(MyApp());` is commented out. So the test:

1. Runs `await tester.pumpWidget(...)` → no widget tree.
2. `expect(find.text('0'), findsOneWidget)` → fails.

Running `flutter test` will currently fail on the only test file in the suite. Either delete `test/widget_test.dart` or replace it with a real smoke test of `SplashScreen`.

### P0 — Multiple environments hard-coded in the same source tree

`lib/constant/constant.dart` keeps every URL in comments and only the *active* one uncommented. This is fragile — devs often re-comment a line during local debugging and ship that. Confirmed hits:

```
lib/constant/constant.dart:12    String image_url = "https://staging.cloudrentalmanager.com/api/images/get-file/";
lib/constant/constant.dart:13    // http://192.168.1.37:4000/api/images/get-file/
lib/constant/constant.dart:16    // String Api_url = "http://192.168.39.1:4000";
lib/constant/constant.dart:17    // String Api_url = "http://192.168.1.33:4000";
lib/constant/constant.dart:20    String Api_url = "https://staging.cloudrentalmanager.com";
lib/constant/constant.dart:21    // String Api_url = "https://development.cloudrentalmanager.com";
```

LAN URLs still referenced in source (some commented, some live in repositories/screens):

| Host             | Hits in lib/ |
| ---------------- | -----------: |
| `192.168.1.10`   | 1 |
| `192.168.1.11`   | 1 |
| `192.168.1.17`   | 4 |
| `192.168.1.22`   | 1 |
| `192.168.1.26`   | 4 |
| `192.168.1.33`   | 1 |
| `192.168.1.37`   | 1 |
| `192.168.1.39`   | 1 |
| `192.168.39.1`   | 1 |
| `http://localhost` | 4 |

Fix: replace `constant.dart` with `--dart-define`d environment values (already in use by `AppHeaders.channel` in 302-property), and drop all commented LAN URLs.

### P1 — `int.parse` / `double.parse` without `tryParse` — **102 + 189 sites**

Each throws `FormatException` on any non-numeric input. Top offenders include:

```
lib/constant/constant.dart:540    final month = int.parse(parts[0]);
lib/constant/constant.dart:541    final year  = int.parse(parts[1]);
lib/screens/Communications/E-mail Logs/email_log_table.dart:415  int.parse('${data.openedAt}')
lib/screens/Communications/Send E-mail/send_mail.dart:272-274    int.parse(match.group(1)!)  // x3
lib/screens/Communications/Templates/Add_mail.dart:140-142       int.parse(match.group(1)!)  // x3
```

Pattern fix: wrap each in `?? 0` after `tryParse`, or guard with `if (RegExp(r'^\d+$').hasMatch(s))`.

### P1 — Empty `catch (_) {}` blocks — 36 sites

A swallowed exception in a network/IO path is one of the most expensive bugs to diagnose in production. Confirmed at:

```
lib/screens/BidRoom/bid_room_table.dart:148
lib/screens/BidRoom/create_bid_room.dart:98, :411
lib/screens/Dashboard/dashboard_sample.dart:1000
lib/screens/Leasing/RentalRoll/lease_table.dart:312, :2750
lib/screens/Maintenance/Workorder/Workorder_table.dart:505
lib/screens/Rental/mortgage/mortgage_summery.dart:1732, :2534, :2558, :2568
lib/screens/Rental/Properties/Maintenance/Add_Edit_maintenance.dart:200
lib/screens/Rental/Properties/Maintenance/maintenance_table.dart:163
lib/screens/Rental/Tenants/Payments/Tenant_payments.dart:243
lib/screens/Rental/Tenants/Tenant_summary.dart:143
(...22 more)
```

Minimum fix: `catch (e, st) { debugPrint('...'); debugPrintStack(stackTrace: st); }`.

### P1 — 23 files have unbalanced `{`/`}` or `(`/`)` counts

Most are false positives caused by braces inside comments and string literals (e.g. `login_screen.dart` ends inside a `/* ... */` block at line ~10,400). Worth a one-by-one eyeball — Flutter will reject any that are actual syntax errors at build time:

| File | `{` | `}` |
| ---- | --: | --: |
| `screens/Login/login_screen.dart` | 878 | 874 |
| `screens/Profile/manage_template.dart` | 65 | 64 |
| `screens/Rental/Properties/add_new_property.dart` | 343 | 342 |
| `screens/Rental/Properties/EditProperties.dart` | 591 | 592 |
| `screens/Leasing/RentalRoll/Renters Insurance/Edit_Renters_insurance.dart` | 127 | 126 |
| `screens/Reports/ReportScreens/ConvenienceFee.dart` [parens] | 1,120 | 1,119 |
| `screens/Reports/ReportScreens/CustomReportBuilder.dart` [parens] | 581 | 583 |
| `StaffModule/screen/Maintenance/Vendor/edit_vendor.dart` | 323 | 327 |
| `StaffModule/screen/Maintenance/Vendor/edit_vendor.dart` [parens] | 1,327 | 1,336 |
| `StaffModule/screen/Rental/Properties/EditProperties.dart` | 611 | 612 |
| `StaffModule/screen/Rental/Properties/summery_page.dart` | 1,534 | 1,533 |
| `widgets/file_viewer.dart` | 184 | 182 |
| `widgets/test.dart` | 169 | 168 |
| `VendorModule/screen/dashboard.dart` | 167 | 169 |
| ... (8 more) |

Spot check: `login_screen.dart` ends with `}*/` — the diff is contained inside a `/* ... */` block comment, so it's a false positive. But `StaffModule/screen/Maintenance/Vendor/edit_vendor.dart` is off by **4** braces *and* **9** parens — that one deserves a real look.

### P2 — 7,000+ raw `print(...)` calls

7,268 in crmmobile, 7,284 in 302-property. These ship to release builds unless silenced. 302-property already has the right hook for this (see `app_headers.dart`'s "Auto-suppressed in release/profile by the zone-level print filter in main()"), but verify the zone filter in `main()` actually wraps `runApp` and `kReleaseMode` checks; otherwise these still go to logcat / oslog in production.

### P2 — Refactor candidates (files > 350 KB)

| Bytes      | File |
| ---------: | ---- |
| 1,415,484  | `StaffModule/screen/Rental/Properties/summery_page.dart` |
| 1,148,255  | `screens/Rental/Properties/summery_page.dart` |
|   537,572  | `screens/Profile/Settings_screen.dart` |
|   491,325  | `screens/Leasing/Applicants/Summary/ApplicantContent.dart` |
|   489,039  | `StaffModule/screen/Leasing/Applicants/Summary/ApplicantContent.dart` |
|   477,223  | `screens/Leasing/RentalRoll/newAddLease.dart` |
|   450,401  | `StaffModule/screen/Leasing/RentalRoll/edit_lease.dart` |
|   442,028  | `screens/Leasing/RentalRoll/edit_lease.dart` |
|   436,723  | `StaffModule/screen/Rental/Properties/EditProperties.dart` |
|   430,439  | `screens/Rental/Properties/EditProperties.dart` |

`summery_page.dart` is **1.4 MB of Dart** — almost certainly contains widget classes that should be split into separate files. The duplicate (`screens/...` vs `StaffModule/screen/...`) suggests a copy-paste fork rather than a shared widget.

### P2 — Top-level folder casing/spacing irregularities

These cause cross-platform pain (e.g., case-insensitive Windows builds vs case-sensitive CI):

- `lib/User Permission/` — folder name contains a space.
- `lib/Model/` (singular) AND `lib/models/` (plural) coexist. `lib/models/` has 1 file; `lib/Model/` has 91. Pick one.
- `lib/StaffModule/repository/Preminum Plans/` — folder name has a typo ("Preminum") and a space.
- `lib/StaffModule/repository/AdminUser Permission/` — folder name has a space.

### P2 — Asset folder has Cursor IDE scratch images

```
assets/c__Users_Khushali_AppData_Roaming_Cursor_User_workspaceStorage_3aef5e8fa16be499110f962203ecefa1_images_image-*.png  (4 files)
```

These look like accidentally-committed Cursor IDE scratch pads. Remove unless they're genuinely shipped.

---

## 5. Module-by-module status

### `lib/main.dart`
- crmmobile: standard provider-based bootstrap.
- 302-property: same plus `AppHeaders.init()` / `ApiClient.navigatorKey` wiring. Top of file has a large commented-out experimental `main()` — clean up.

### `lib/screens/Login/`
- Single file: `login_screen.dart` (878 `{` / 874 `}`). Ends inside a `/* ... */` block — false positive on the brace check.

### `lib/screens/Rental/`
- 47 files. Hot spots: `Properties/summery_page.dart` (1.1 MB), `Properties/EditProperties.dart` (430 KB), `Properties/add_new_property.dart` (brace off-by-1, likely false positive).
- Both Rental files use a LAN URL on line ~350 (`add_new_property.dart`) and ~843 (`EditProperties.dart`): `http://192.168.1.17:4000/api/images/upload`.

### `lib/screens/Leasing/`
- 44 files. Hot spots: `RentalRoll/newAddLease.dart` (477 KB) and `RentalRoll/edit_lease.dart` (442 KB).
- `RentalRoll/SummeryPageLease.dart` parens off by 2 — likely false positive but worth a glance.
- 11 of the 36 empty `catch(_) {}` blocks live in this folder.

### `lib/screens/Maintenance/`
- 8 files. Vendor add/edit ship the placeholder `yourapiurl.com` (P0 above).

### `lib/screens/Reports/`
- 32 files. `ConvenienceFee.dart` and `CustomReportBuilder.dart` have small paren imbalance — likely false positives.

### `lib/screens/Communications/`
- 5 files. Several `int.parse(match.group(...)!)` without `tryParse` in `send_mail.dart` and `Add_mail.dart` (P1 above).

### `lib/screens/Dashboard/`
- 8 files. `RentPastDueReport.dart` has 13 more `)` than `(` — almost certainly inside strings (regex/url formatting), but worth a quick check.

### `lib/screens/BidRoom/`
- 2 files. **New** vs older snapshots — 4 empty catch blocks combined.

### `lib/screens/Splash_Screen/`, `Signup/`, `Password/`, `Plans/`, `Profile/`, `Property_Type/`, `Staff_Member/`, `activity/`, `notifications/`
- Smaller modules — no specific bugs surfaced beyond the global ones above.

### `lib/StaffModule/`
- 269 files — largest single module. Mostly a parallel copy of `lib/screens/` plus its own repositories. The duplication between `lib/screens/...` and `lib/StaffModule/screen/...` is the single largest refactor opportunity in this codebase.
- `lib/StaffModule/screen/Maintenance/Vendor/edit_vendor.dart` has the worst brace/paren imbalance — investigate first.

### `lib/TenantsModule/`
- 51 files. `screen/financial/financial_table.dart` parens off by 3 — likely a regex string.

### `lib/VendorModule/`
- 31 files. `screen/dashboard.dart` has 2 more `}` than `{` — investigate; smaller file makes a real syntax error more plausible.

### `lib/repository/` (78) + `lib/StaffModule/repository/`
- These hold the bulk of network calls. 302-property has begun the migration from `http.*` to `apiGet/Post/...` (the new helpers in `lib/services/api_helpers.dart`) — many `// final response = await http.get(...)` lines now have a sibling `// final response = await apiGet(...)`, but plenty of repository files still use raw `http`. Track the migration to completion before relying on the version-header behaviour to actually be sent on every request.

### `lib/widgets/`
- 33 files. `widgets/test.dart` is checked in and has a brace mismatch — looks like dead exploration code; delete or move out of `lib/`.

### `lib/Model/` (91) + `lib/models/` (1)
- `lib/models/` contains a single file. Merge it into `Model/` (or rename `Model/` to `models/`) and delete the singleton.

---

## 6. Recommended action list (in order)

1. Fix the 4 Vendor screens — replace `https://yourapiurl.com` with `Api_url`. (Mechanical, ~10 min.)
2. Decide on `ApiConstants.getHeaders()` — wire to real auth or remove. (Mechanical, ~15 min.)
3. Replace `test/widget_test.dart` with a real smoke test, or delete it, so `flutter test` doesn't fail on a default-template file. (5 min.)
4. Eyeball the 5 brace/paren mismatches most likely to be real (not inside `/* */` blocks):
   - `StaffModule/screen/Maintenance/Vendor/edit_vendor.dart`
   - `widgets/file_viewer.dart`
   - `widgets/test.dart`
   - `VendorModule/screen/dashboard.dart`
   - `screens/Profile/manage_template.dart`
5. Run `flutter analyze` from Windows in each project root. Capture full output and diff it against this report — it will surface any real syntax issues plus deprecated-API and unused-import warnings.
6. Run `flutter test` to confirm whether the broken `widget_test.dart` fails as predicted.
7. Migrate the remaining `http.*` call sites in 302-property repositories to `apiGet/Post/...` so the new version-header subsystem actually covers every API request.
8. Replace `lib/constant/constant.dart` LAN URLs with `--dart-define` env variables.
9. (Larger) Split the 1+ MB files (`summery_page.dart`, `EditProperties.dart`, `newAddLease.dart`, `edit_lease.dart`) into per-widget files.
10. (Larger) Collapse `lib/screens/` + `lib/StaffModule/screen/` into one shared screen tree with role-based widgets.

---

## 7. Commands to actually run the tests (on Windows)

```powershell
# crmmobile
cd C:\CRM\crmmobile
flutter pub get
flutter analyze   > analyze.log 2>&1
flutter test      > test.log 2>&1

# 302-property
cd C:\CLoudeRentalManager\302-property
flutter pub get
flutter analyze   > analyze.log 2>&1
flutter test      > test.log 2>&1
```

Then compare `analyze.log` / `test.log` against this report. Any new findings should be appended to `BUGS_LIST.md`.
