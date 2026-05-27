# Flow-Trace Bug Report — 302-property

**Generated:** 2026-05-26 (second full pass, flow-level)
**Reviewer:** Read-only static review. **No source code was modified.**
**Method:** This pass traces specific user journeys (Login, Splash routing, Make Payment) line-by-line, looking for bugs that span files or live in control flow — things the pattern scans in `FULL_PROJECT_TEST_REPORT.md` would miss. Treat this as a complement to that file, not a replacement.

---

## What's new vs. the project-wide report

The earlier reports counted symptoms across the whole codebase (425 files with awaits but no `mounted` checks, 30 force-unwraps, 13 RapidAPI key copies, etc.). This report walks the *actual code paths* a user hits in production and surfaces things you can only see by reading the call chain.

| New flow finding | Severity |
|------------------|----------|
| F1. User password saved to SharedPreferences in plaintext | **CRITICAL** |
| F2. `login_screen.dart` is 73% dead commented-out code, with two copies of the login class | HIGH |
| F3. Splash version-check is entirely commented out | HIGH |
| F4. Login `checkToken` force-unwraps server fields, will crash on partial responses | HIGH |
| F5. `loginsubmit` has no try/catch — network/parse failures leave the spinner stuck forever | HIGH |
| F6. 2FA verify edge case: token saved + `isAuthenticated=true` but no route fires for unknown `selectedrole` | HIGH |
| F7. Splash bounces authenticated admin to Login if plan API failed | MEDIUM |
| F8. Payment submit uses `.first` on a possibly-empty tenants list | HIGH |
| F9. Payment submit uses `double.parse` on raw input mid-network-call; FormatException leaves `_isLoading=true` | HIGH |
| F10. Payment `catchError` double-toasts the same error and passes a non-String to Fluttertoast | LOW |

---

## Flow 1: Login submit → token check → role routing

**Entry point:** `lib/screens/Login/login_screen.dart` → `loginsubmit()` (live copy at line 6175).

### F1 — CRITICAL — Password stored in plaintext in SharedPreferences

`lib/screens/Login/login_screen.dart:5866`
```dart
prefs.setString('password', password.text);
```
This is inside `checkToken`, which runs immediately after a successful login. On Android this writes the password to `/data/data/com.hostmerchantservices.cloudrentalmanager/shared_prefs/*.xml`, which is included in Auto Backup to Google Drive by default. On iOS it lands in NSUserDefaults. **Cleartext passwords should never be persisted.** The same write also appears in the commented-out historical block at line 1871, confirming this is established practice rather than a one-off.

Even ignoring storage location: there is no business reason for the client to need the password after login — the server returns a token at line 5851 that's used for every subsequent call. Whatever flow was supposed to read this password later should use the token.

**What to do:** delete the line. If a "remember me" feature really needs the password, move it to `flutter_secure_storage` (Keychain on iOS, EncryptedSharedPreferences on Android), and disable Android Auto Backup for the app or exclude the keys.

### F2 — HIGH — `login_screen.dart` is 73% dead commented-out code

The file is 8,286 lines total. Counting block-comment regions:
- Lines 1–4290: closed by `// }*/` at line 4291 — first old version, block-commented
- Lines 4293–6552: **the live login implementation** (~2,260 lines)
- Lines 6553–8286: opens with `/*import 'dart:convert';` and closes with `}*/` at line 8286 — second old version, also block-commented

Net result: of 8,286 lines, **about 6,026 are commented out**. Class declarations confirm the structure — `class Login_Screen` appears at line 4322 (live) AND 6585 (commented), `_Login_ScreenState` at 4329 AND 6592, and so on. Without realizing the block-comment context, even `grep` thinks there are duplicate classes.

This isn't a runtime bug today, but:
- Every edit on the live class has to mentally skip the dead copy below.
- IDE search-and-jump will land you in the dead copy half the time.
- A future merge that accidentally removes one of the `}*/` markers will cause a cascade of "duplicate definition" compile errors that look incomprehensible.

**What to do:** delete the dead halves (lines 1–4290 and 6553–8286). It's a single commit that shrinks the file from 8,286 to ~2,260 lines.

### F3 — HIGH — Splash version-check is commented out

`lib/screens/Splash_Screen/splash_screen.dart:340–351`
```dart
// ── VERSION CHECK (uncomment when ready to go live) ────────
// final versionResult = await AppVersionService.checkVersion();
// if (!mounted) return;
//
// if (versionResult.status == VersionStatus.forceUpdate) {
//   _showForceUpdateDialog(versionResult.latestVersion ?? '');
//   return; // Stop navigation — user must update
// } else if (versionResult.status == VersionStatus.softUpdate) {
//   _showSoftUpdateDialog(versionResult.latestVersion ?? '');
// }
```
The dialog widgets `_showForceUpdateDialog` / `_showSoftUpdateDialog` exist (lines 77, ~200), the service `AppVersionService.checkVersion` exists. Only the call site is commented out. If you ship a breaking API change, old clients will not be force-updated — they'll just start failing.

Note: this is also the reason H4 from the earlier reports (placeholder iOS App Store ID at line 70) hasn't bitten yet — the force-update flow never runs in production.

### F4 — HIGH — `checkToken` force-unwraps server fields

`lib/screens/Login/login_screen.dart:5841–5862`
```dart
final jsonData = json.decode(response.body);

if (jsonData['id'] != "") {                     // 5843 — guard is incorrect (see below)
  String? adminId = jsonData['admin_id'];
  String? companyName = jsonData['company_name'];

  prefs.setString('checkedToken', token);
  prefs.setString('adminId', adminId!);         // 5852 — NPE if missing
  prefs.setString('companyName', companyName!); // 5854 — NPE if missing
  prefs.setString("role", "Admin");
  prefs.setString('first_name', jsonData['first_name']);  // 5857 — type error if null
  prefs.setString('last_name', jsonData['last_name']);    // 5858 — type error if null
  prefs.setString('first_name', jsonData['first_name']);  // 5859 — duplicate write
  prefs.setString('last_name', jsonData['last_name']);    // 5861 — duplicate write
  prefs.setString('email', jsonData['email']);            // 5862 — type error if null
  prefs.setString('password', password.text);             // 5866 — see F1
```

Three independent bugs here:

1. **Line 5843 is the wrong guard.** `jsonData['id']` can be `null`, and `null != ""` is `true`, so a response missing the field entirely *passes* this validation, then crashes on the next line trying to access fields that aren't there. Should be `if (jsonData['id'] != null && jsonData['id'] != "")`.

2. **Lines 5852, 5854** force-unwrap fields the server might omit on edge accounts (legacy accounts created before company_name was required, deactivated users, etc.). NPE.

3. **Lines 5857, 5858, 5862** pass raw `jsonData['…']` to `prefs.setString`, which requires a non-null `String`. If any of those fields are null in the response, you get a `TypeError`.

4. (Bonus) **Lines 5859, 5861 duplicate writes of `first_name` and `last_name`** from 5857/5858 — harmless but suggests autogenerated/IDE-merged code.

The same pattern repeats in `checkTokenStaff`, `checkTokenTenant`, `checkTokenVendor`, `checkCompany` (lines 5929+, 5977+, 6022+, 6077+).

### F5 — HIGH — `loginsubmit` has no try/catch around the network call

`lib/screens/Login/login_screen.dart:6175–6235`
```dart
Future<void> loginsubmit() async {
  setState(() { loading = true; });
  …
  final response = await http.post(Uri.parse('${Api_url}/api/auth/login'), body: {…});
  print(response.body);
  final jsonData = json.decode(response.body);          // ← throws on non-JSON / empty body
  if (jsonData["statusCode"] == 200) { … }
  else { … setState(() { loading = false; }); }
}
```

The whole function has no `try`/`catch`. Failure modes that brick the screen:
- **No internet** → `http.post` throws `SocketException`. Spinner stuck (loading never reset).
- **502/504 from gateway** → returns HTML, `json.decode` throws `FormatException`. Spinner stuck.
- **Timeout** → `http.post` throws `TimeoutException` (eventually). Spinner stuck.
- **Server returns success but no body** → `json.decode("")` throws. Spinner stuck.

User has to force-quit the app. Wrap the body in `try/catch` and always reset `loading` in a `finally`.

### F6 — HIGH — 2FA verify edge case: token saved but no navigation fires

`lib/screens/Login/login_screen.dart:6237–6299` (`loginsubmitverify2fa`).

The success path saves token + `isAuthenticated=true` *first*, then routes by role:
```dart
if (jsonData["statusCode"] == 200) {
  …
  prefs.setBool('isAuthenticated', true);
  prefs.setString('token', jsonData["token"]);
  prefs.setString('userId', userId!);                       // 6267 — force unwrap

  if (selectedrole == "staffmember" || selectedrole == "staff")
    await checkTokenStaff(jsonData["token"]);
  if (selectedrole == "tenant") await checkTokenTenant(jsonData["token"]);
  if (selectedrole == "vendor") await checkTokenVendor(jsonData["token"]);
  if (selectedrole == "admin")  await checkToken(jsonData["token"]);
  setState(() { loading = false; });
}
```

Two distinct problems:
1. **No `else`** — if `selectedrole` is anything other than the four expected values (empty, `Admin` with capital A, `Staff` with capital S, server-side renamed role…), none of the `checkToken*` calls fire. But `isAuthenticated=true` and `token` are already in `SharedPreferences`. The user sits on the login screen with the spinner stopping but no navigation. Next time they relaunch the app, the splash sees `isAuthenticated=true` and routes them based on `prefs.getString("role")` — which they never had a chance to set, because the role string is set inside the `checkToken*` calls, not here.
2. **Line 6267 `userId!`** — force-unwrap on a state field. If the email/role-detection step didn't populate `userId` (which can happen if the user enters credentials before the role-detection AJAX returns), NPE.

### F7 — MEDIUM — Splash bounces authenticated admin to Login if plan API fails

`lib/screens/Splash_Screen/splash_screen.dart:399–408`
```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => isAuthenticated == true
        ? isPlanActive!
            ? Dashboard()
            : provider.checkplanpurchaseModel != null ? PlanPurchaseCard() : Login_Screen()
        : Login_Screen(),
  ),
);
```

Trace: user is authenticated (`isAuthenticated == true`), plan API call at line 361 fails (network blip, server hiccup, anything) → `provider.checkplanpurchaseModel == null` → fallback branch routes to `Login_Screen()`.

So a network blip on cold start kicks the user out of their session. They have a valid token sitting in prefs but the splash sends them to the login screen anyway. They re-enter credentials, the login API succeeds, they're back in. Better than crashing but a poor experience and an audit headache ("why are users hitting `/api/auth/login` 6× a day").

Fallback should be `Dashboard()` (let the plan check retry inside the app) or a dedicated "we couldn't reach the server, retry?" screen.

### Other smaller things in the login + splash flows (already pattern-counted, repeated here for the trace)

- `splash_screen.dart:338` — hardcoded `Future.delayed(Duration(seconds: 5))`. Five seconds before any real work begins is a lot of perceived wait.
- `splash_screen.dart:357–359` — `if (role != "")` reads `DateProvider` into an unused local. Dead code.
- `splash_screen.dart:372`, `login_screen.dart:5901` — `DateFormat('yyyy-MM-dd').parse(expirationDateString)` with no `try`/`catch`. A non-conforming date string from the server throws `FormatException`.
- `login_screen.dart:5890–5919` — only one `if (!mounted) return;` (line 5888), then two more awaits at 5891 and 5918 each followed by context use. Need extra mounted guards.

---

## Flow 2: Make Payment submit (admin tree)

**Entry point:** `lib/screens/Leasing/RentalRoll/Edit_make_payment.dart` → submit button onPressed at line ~3320.

### F8 — HIGH — Submit handler uses `.first` on a possibly-empty filtered list

`Edit_make_payment.dart:3379–3385` and `3425–3431`
```dart
List<Map<String, String>> filteredTenants = tenants.where((tenant) {
  return tenant['tenant_id'] == selectedTenantId;
}).toList();
Map<String, String> selectedTenant = filteredTenants.first;   // ← StateError if empty
```

If the tenants list was refreshed in the background and `selectedTenantId` no longer corresponds to anything in it (tenant removed/updated, list refetched returned different IDs), `.first` throws `StateError: No element`. The submit dies mid-flight; spinner stays on.

### F9 — HIGH — `double.parse` on raw user input mid-submit

`Edit_make_payment.dart:3337, 3393, 3395, 3440, 3442`
```dart
totalAmount: double.parse(amountController.text.trim()),
…
"${(double.parse(amountController.text.trim()) * (surCharge ?? 0.0) / 100)}",
"${(double.parse(amountController.text.trim()) * (surCharge ?? 0.0) / 100) + double.parse(amountController.text.trim())}",
```

The amount field is editable until the user taps Make Payment. If they clear it (or paste something non-numeric, or leave a stray space the `.trim()` won't catch like a comma), `double.parse` throws `FormatException` *after* `_isLoading` was set to `true` but *before* `_isLoading = false` is reached. Spinner stays forever.

The fix used at line 325 of the same file (`double.tryParse(amountController.text) ?? 0.0`) shows the team knows the pattern — it just hasn't been applied to the submit handler.

Also: the formula `(amount * surcharge / 100) + amount` is repeated four times in this one handler — see M4 in the project-wide report. A typo in one of those four places (a missing parenthesis, a wrong `surCharge ?? 0.0` default) would silently produce different totals between fields and the receipt.

### F10 — LOW — `catchError` shows two toasts and passes a non-String to one of them

`Edit_make_payment.dart:3462–3470`
```dart
}).catchError((e) {
  print(e);
  Fluttertoast.showToast(msg: e);            // ← `e` is Object, not String
  setState(() { _isLoading = false; });
  Fluttertoast.showToast(msg: "Payment failed $e");   // ← second toast for the same error
});
```

`Fluttertoast.showToast(msg: …)` expects a `String`; passing an `Object` will either silently fail or show whatever `toString()` returns. Then immediately afterwards, a second toast fires with "Payment failed $e" — so the user sees one or two toasts depending on what `e` is. Same pattern doesn't appear in the ACH branch (3347–3374) which only toasts once via the proper Alert dialog.

### F11 — MEDIUM — Force-unwraps inside payment payload

`Edit_make_payment.dart:3389–3391, 3404, 3435–3438, 3443`
```dart
firstName: selectedTenant["first_name"]!,
lastName: selectedTenant["last_name"]!,
emailName: selectedTenant["email"]!,
…
paymentId: widget.data!.paymentId!,
…
tenantId: selectedTenantId!,
```

Any of these can be null in real data:
- `widget.data` is null if the screen is reused for "new payment" without a prior payment object.
- `selectedTenant["…"]` is null if the tenants endpoint returned a tenant with missing fields (legacy data, soft-deleted, etc.).
- `selectedTenantId` is null if the dropdown was never touched.

Validation should happen before the submit, with user-visible "missing tenant" / "missing payment id" errors rather than NPEs.

### F12 — HIGH — `setState` / `Navigator.pop` after `await` with no `mounted` check (payment success path)

`Edit_make_payment.dart:3340–3346, 3410–3415, 3456–3461` — all three payment branches do:
```dart
await PaymentService().…().then((value) {
  Fluttertoast.showToast(msg: …);
  setState(() { _isLoading = false; });
  Navigator.pop(context, true);
});
```

No `if (!mounted) return;` between the `await` and the `setState` / `Navigator.pop`. If the user backs out (or the OS kills/re-attaches the screen) while the payment API is in-flight, framework throws `setState() called after dispose`. This is the same H5 cluster as the project-wide report, just narrowed to the exact lines in this flow.

---

## Flow 3: Create Bid Room (new feature)

Already covered in `BUG_REPORT_2026-05-26.md` (H9: 21 awaits / 0 mounted checks, `Navigator.pop(context, true)` at lines 565 and 589 after `http.put` / `http.post`, `setState` in `finally` at line 606). Nothing new from the trace beyond what's in that report.

---

## Cross-flow observations

- **Auth state is split across many SharedPreferences keys**: `isAuthenticated`, `token`, `checkedToken`, `adminId`, `userId`, `staff_id`, `role`, `companyName`, `first_name`, `last_name`, `email`, `password`, `brand_logo`, plus per-role variants. There is no single "session" object — every screen does its own `prefs.getString(...)`. The 30 `prefs.getString("adminId")!` force-unwraps from the earlier report are a direct consequence; in F6 above, the half-written auth state is another. Worth wrapping in a `Session` helper that either returns a complete `Session` object or `null`.

- **Both the splash and `checkToken` after login independently call `fetchPlanPurchaseDetail()`**. A logout+login round-trip therefore calls it twice. Provider state from before logout may be cached if logout doesn't clear the providers.

- **Every screen in the app reads `Api_url` directly from `lib/constant/constant.dart`** (568 files). H1 in the project-wide report is "production points at staging" — flipping it requires touching one line, but you can't easily verify the change by reading the code because every screen baked in the assumption that `Api_url` *is* the production URL. Worth keeping a `lib/constant/env.dart` with `Api_url`, `image_url`, `image_upload_url` derived from a single `kReleaseMode ? prod : staging` switch.

---

## Recommended actions (delta to previous report)

The recommended order from `FULL_PROJECT_TEST_REPORT.md` still stands. Add at the top:

1. **F1** — delete the `prefs.setString('password', …)` line. This is the single fastest highest-impact security fix in the project.
2. **F3** — uncomment the version-check block in `splash_screen.dart:340-351` (and finish H4 / the iOS App Store ID at the same time, since they pair).
3. **F2** — delete the dead halves of `login_screen.dart` so the next bug fix on the login flow is sane to review.
4. **F4, F5, F6** — wrap `loginsubmit` / `loginsubmitverify2fa` / `checkToken*` in `try/finally`, switch the force-unwraps to null-safe access, add an `else` branch in the 2FA verify role-routing.
5. **F7** — change the splash fallback so an authenticated user with a failed plan-check still gets into the app.
6. **F8, F9, F11, F12** — same defensive treatment for the payment submit handler.

No source files were modified in this review.
