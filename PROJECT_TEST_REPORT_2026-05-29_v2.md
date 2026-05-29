# Full Project Test Report v2 — 2026-05-29 (deep pass, both projects)

**Scope:** Static-only deep re-scan of both Flutter projects. **No code changes were made.** Findings here are *new* — issues already covered in `PROJECT_TEST_REPORT_2026-05-29.md` are not repeated.

Projects: `C:\CRM\crmmobile`, `C:\CLoudeRentalManager\302-property`.

> Run `flutter analyze` and `flutter test` on Windows to confirm — sandbox has no Flutter SDK.

---

## CRITICAL / P0 — Security

### S1. Production Android signing keystore is committed to the repo
**Project: 302-property**

```
./CRMmobile-key.jks                  (signing keystore, in repo root)
./android/key.properties             (keystore credentials, in repo)
./android/key.properties contents:
    storePassword=CRM123
    keyPassword=CRM123
    keyAlias=CRMmobile-key-alias
    storeFile=../../CRMmobile-key.jks
```

`android/.gitignore` *does* list `key.properties` and `**/*.jks`, but the files were committed *before* those rules were added — so they still ship in `git ls-files`:

```
$ git ls-files | grep -E "\.jks|key\.properties"
CRMmobile-key.jks
```

**Impact.** Anyone with read access to the repository can sign updates that the Play Store will accept as legitimate Cloud Rental Manager releases. Passwords are also `CRM123` — trivially guessable.

**Action (manual, no code change implied).**
1. Rotate the Play Store signing key (if your account uses Play App Signing, only the upload key needs rotation).
2. `git rm --cached CRMmobile-key.jks android/key.properties` then force-push, and rewrite history (`git filter-repo`) so the key is removed from all old commits.
3. Move passwords out of `key.properties` into CI/CD secrets.

### S2. RapidAPI keys hardcoded in source (both projects)
**13 occurrences, 2 distinct keys** in `lib/`:

```
lib/repository/properties_summery.dart:759       'X-RapidAPI-Key': '1bd772d3c3msh11c1022dee1c2aep1557bajsn0ac41ea04ef7'
lib/screens/Leasing/RentalRoll/addcard/AddCard.dart:328               (same key)
lib/screens/Leasing/RentalRoll/Edit_make_payment.dart:778             (same key)
lib/screens/Leasing/RentalRoll/make_payment.dart:1007                 (same key)
lib/screens/Leasing/RentalRoll/Recurringpayment.dart:1444             '46e85a3cb0msh33efbb0c9360ff4p106ebcjsncf1a23d6dda1'
… (and identical hits across StaffModule/, TenantsModule/, VendorModule/)
```

These keys are extractable from any installed APK via `apktool`. Rotate both keys and route them through a server-side proxy or compile-time `--dart-define`.

### S3. Tokens stored in `SharedPreferences` (plaintext)
**Both projects. 1,275 references in crmmobile alone.**

All session tokens are read/written via `prefs.getString('token')` — i.e. plaintext in app sandbox. On a rooted Android device or jailbroken iOS, this is trivially extractable. Recommended: `flutter_secure_storage` (uses Android Keystore / iOS Keychain). `flutter_secure_storage` is **not** in either project's `pubspec.yaml`.

---

## P0 — Build configuration risk

### B1. Release builds in crmmobile are signed with the DEBUG keystore
**Project: crmmobile**

```
android/app/build.gradle:
    // TODO: Add your own signing config for the release build.
    signingConfig signingConfigs.debug
```

If you ship a `flutter build apk --release` from this project, it will be signed with the debug key. Play Store will refuse the upload (or, worse, take it and create a debug-keyed app on the store).

### B2. Both `build.gradle` AND `build.gradle.kts` exist
**Project: 302-property**

```
android/app/build.gradle      (Groovy, 2,367 bytes)
android/app/build.gradle.kts  (Kotlin DSL, 1,526 bytes)
```

Gradle will read only one — usually `.kts` if both are present, but the behaviour depends on Gradle version. The other file is silently ignored, so any "fix" applied to the wrong one will have no effect. Pick one and delete the other.

---

## P1 — Memory leaks (no `dispose()` for controllers held as class fields)

Static heuristic scan over files extending `State<...>`:

| Controller type             | Class-level fields with no `.dispose()` call |
| --------------------------- | -------------------------------------------- |
| `TextEditingController`     | **1,213** |
| `FocusNode`                 | 60 |
| `TabController`             | 18 |
| `PageController`            | 4 |
| `ScrollController`          | 4 |
| **Total flagged**           | **1,299** |

A few of these are false positives (controller built then handed to another widget that disposes it), but the bulk are real. Each navigation in/out of these screens leaks the controller's listeners. On low-RAM Android devices this compounds into jank and eventual OOM.

Worst single offenders (likely refactor targets):
- `lib/screens/Dashboard/cronjob_payment_table.dart` — 6+ undisposed `TextEditingController`
- `lib/screens/Communications/Send E-mail/send_mail.dart` — 3 undisposed `FocusNode` + multiple controllers
- `lib/screens/Communications/Templates/Add_mail.dart` — same pattern
- `lib/screens/Rental/Properties/add_rentalowners.dart` — 4 undisposed `FocusNode`
- `lib/screens/Rental/Properties/summery_page.dart` — 3 undisposed `TabController`

---

## P1 — Async-gap `BuildContext` use (no `mounted` check)

**205 sites** in `lib/` use `Navigator`/`showDialog`/`ScaffoldMessenger`/`Provider.of` directly after an `await` without a `if (!mounted) return;` guard. Examples:

```
lib/screens/Leasing/Applicants/Applicants_table.dart:346
   await ApplicantRepository().DeleteApplicant(Applicantid: id);
   Navigator.pop(context);                  // <- context across async gap

lib/screens/Leasing/RentalRoll/edit_lease.dart:4603
   bool success = await LeaseRepository().updateLease(lease);
   ScaffoldMessenger.of(context).showSnackBar(...);

lib/screens/Leasing/RentalRoll/lease_table.dart:657
   await LeaseRepository().deleteLease(...);
   Navigator.pop(context);
```

If the user navigates away during the `await`, Flutter throws `_Dependents...` or schedules a redraw on a disposed `State`. `flutter analyze` will warn on these as `use_build_context_synchronously`.

---

## P1 — HTTP calls without timeouts

**1,186 of 1,223** outgoing API calls have no `.timeout(...)` chain within the next 500 chars. Default `package:http` and Dio request timeouts apply, but neither project sets per-call deadlines on `apiPost(...)` / raw `http.get(...)`. Mobile networks can hang for 30–120 s — every screen relying on these gets a frozen spinner.

The new `services/api_client.dart` in 302-property *does* set Dio defaults (`connectTimeout = 30s`, `receiveTimeout = 30s`), so Dio-based calls are covered. But `api_helpers.dart` (`apiGet/Post/...`) wraps `package:http`, which has **no** default timeout — those 1,186 calls still hang indefinitely until the OS drops the socket.

---

## P1 — `fromJson` factories with no null defaults (156 factories)

When the backend omits a field or sends `null`, the constructor throws. Top hotspot: model classes under `lib/Model/`. Use `json['x'] as String?` and provide `??` defaults.

---

## P1 — `DateTime.parse(...)` with no surrounding try/catch (58 files)

Same shape as `int.parse` in v1 — any malformed timestamp from the API crashes the screen.

---

## P2 — Code-hygiene findings (new)

### H1. Duplicate `import` statements — **52 files**
Some highlights:
```
lib/repository/ConvenienceFeeRepo.dart     dart:convert (2x), package:http (2x),
                                           shared_preferences (2x), api_helpers (2x)
lib/screens/Dashboard/dashboard_one.dart   dart:io (2x), material.dart (2x),
                                           services.dart (2x), rflutter_alert (2x)
lib/provider/color_theme.dart              package:flutter/material.dart (2x)
lib/provider/dateProvider.dart             services/api_helpers.dart (2x)
```
Harmless to runtime, but a clear copy-paste signal and `flutter analyze` will warn (`duplicate_import`).

### H2. 622 deprecated `.withOpacity(...)` calls
Deprecated since Flutter 3.27. Replace with `Color.withValues(alpha: ...)`. Sample sites: `lib/constant/constant.dart:244`, `lib/screens/BidRoom/bid_room_table.dart:825`, `:1644`, `lib/screens/BidRoom/create_bid_room.dart:1276`.

### H3. Other deprecated API usage
- `WillPopScope` — 6 sites (replace with `PopScope`)
- `accentColor` — 17 sites (replaced by `colorScheme.secondary`)
- `buttonColor` — 7 sites
- `textTheme.headline*` — 1 site (`headline1..headline6` are gone since 3.x; use `displayLarge`/`bodyMedium`/etc.)

### H4. `Image.network(...)` without an `errorBuilder` — 37 sites
A broken/timed-out image throws and breaks the surrounding widget. Add `errorBuilder` returning a placeholder.

### H5. Orphan and missing assets
**Project: 302-property**

| | Count |
|--|--|
| Files in `assets/` | 112 |
| Asset paths referenced in code | 76 |
| Orphan assets (declared in pubspec or copied in, never used) | 46 |
| **Missing assets (referenced but not present)** | **10** |

Missing assets (each one will crash with `Unable to load asset`):
```
assets/Nodata.png
assets/icons/$item.png            (looks like an unescaped string interpolation)
assets/icons/summary.png
assets/images/${text == …}        (also broken interpolation)
assets/images/contact_less.png
assets/images/contactless1.png
assets/images/mastercard.png
assets/images/no_internet.json
assets/no_data.jpg
assets/visa.png
```

The two `${...}` entries are concerning — that's literal source-code text being passed to `AssetImage`, meaning the variable name escaped the curly braces and is being read as a path.

Orphans worth deleting include the four Cursor IDE scratch images and `icons.zip` in `assets/`.

### H6. iOS Info.plist permission descriptions look incomplete
Project: 302-property

`NSPhotoLibraryUsageDescription` text: "We use this informaation to update the profile image based on by the user" — typo (`informaation`) and grammatically odd. Apple's review will flag this.

Permissions used in Dart code suggest more usage descriptions are needed (microphone, contacts), but only Camera, Photo Library, and Location WhenInUse are present. If the app actually never uses microphone/contacts then strip the calls; otherwise the App Store rejects on the missing keys.

### H7. Mismatched Android permissions between the two projects
| Permission | crmmobile | 302-property |
| ---------- | --------- | ------------ |
| INTERNET, ACCESS_NETWORK_STATE | ✅ | ✅ |
| ACCESS_FINE/COARSE_LOCATION | ✅ | ✅ |
| READ/WRITE_EXTERNAL_STORAGE | ✅ | ✅ |
| **CAMERA** | ❌ | ✅ |
| **NFC** | ✅ | ❌ |

crmmobile uses `image_picker` (camera) in code but is missing the `CAMERA` permission. 302-property declares NFC nowhere in code but the permission was removed from the manifest — neither situation looks intentional. Decide what each app actually needs.

### H8. `widget_test.dart` is the broken template in both projects
Already noted in v1 — repeating here because it means `flutter test` exits with a failing suite the first time you run it. Fix order:
1. `flutter test` (will fail on widget_test.dart)
2. Delete or rewrite `test/widget_test.dart`
3. `flutter test` again

---

## Side-by-side summary of new v2 findings

| ID  | Severity | Description                                          | Project(s)        |
| --- | -------- | ---------------------------------------------------- | ----------------- |
| S1  | P0       | Production signing keystore + passwords in repo      | 302-property      |
| S2  | P0       | Hardcoded RapidAPI keys in source                    | both              |
| S3  | P0       | Auth tokens stored in plaintext SharedPreferences    | both              |
| B1  | P0       | Release build signed with debug key                  | crmmobile         |
| B2  | P0       | Both `build.gradle` and `build.gradle.kts` present   | 302-property      |
| —   | P1       | 1,299 undisposed controllers (1,213 TextEditing)     | both (~identical) |
| —   | P1       | 205 `BuildContext` uses across `await` w/o mounted   | both              |
| —   | P1       | 1,186 HTTP calls without `.timeout(...)`             | both              |
| —   | P1       | 156 `fromJson` factories w/o null defaults           | both              |
| —   | P1       | 58 files with `DateTime.parse` outside try/catch     | both              |
| H1  | P2       | 52 files with duplicate imports                      | both              |
| H2  | P2       | 622 `withOpacity` (deprecated since Flutter 3.27)    | both              |
| H3  | P2       | `WillPopScope`/`accentColor`/`buttonColor`/`headline*`| both             |
| H4  | P2       | 37 `Image.network` without `errorBuilder`            | both              |
| H5  | P2       | 10 missing assets, 46 orphan assets                  | 302-property (likely both) |
| H6  | P2       | Typo + missing iOS permission usage strings          | 302-property      |
| H7  | P2       | Android permissions don't match what code uses       | both              |

---

## Commands to run on Windows for ground-truth (no code change needed)

```powershell
cd C:\CRM\crmmobile
flutter pub get
flutter analyze > analyze_crmmobile.log 2>&1
flutter test    > test_crmmobile.log 2>&1

cd C:\CLoudeRentalManager\302-property
flutter pub get
flutter analyze > analyze_302.log 2>&1
flutter test    > test_302.log 2>&1
```

Then compare against this report — the lints `use_build_context_synchronously`, `dispose_fields`, `unawaited_futures`, `duplicate_import`, `deprecated_member_use`, and `avoid_print` will overlap heavily with the findings above.

Reminder: **no source files were modified** during this scan. Only this `.md` report was written.
