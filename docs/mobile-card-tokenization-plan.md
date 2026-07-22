# Mobile Card-Add → Client-Side Tokenization (PCI) — Plan

Status: **planned, awaiting Eric's approval** (see Phase 0). Self-contained handoff — paste into a new chat to continue.

---

## 1. Why this exists
- The mobile Add Card **display bug** ("card saves but doesn't show") is **FIXED & live** (server stale-sort fix by Neil; mobile now accepts `200` **and** `201`).
- **This task is the separate PCI follow-up Eric raised.** The mobile Add Card flow sends the **raw card number (PAN) through our server**:
  - `create-customer-vault` / `create-customer-billing` take `ccnumber`, **and** `addCreditCard` takes `cc_number` (for BIN). We don't store it, but transmitting the PAN through our backend is a **PCI violation**.
- Eric: *"we should only ever be passing around tokens that collect.js generates … we're doing this successfully in Cloud Studio and Cloud Job mobile apps."*
- Fix: move mobile Add Card to **client-side tokenization** — the card is tokenized **in the app** (Collect.js in a WebView), and only a `payment_token` reaches our server, exactly like the website.

## 2. Scope (confirmed)
**IN scope — Add Card + Add ACH, across all 3 modules (everywhere a raw card/bank number is typed):**
| Module | Screen files |
|---|---|
| Admin | `lib/screens/Leasing/RentalRoll/addcard/AddCard.dart` + `Service.dart` + `CardModel.dart` |
| Staff | `lib/StaffModule/screen/Leasing/RentalRoll/addcard/AddCard.dart` + `Service.dart` + `CardModel.dart` |
| Tenant | `lib/TenantsModule/screen/financial/AddCard/AddCard.dart` + `Service.dart` + `CardModel.dart` |

Each module keeps its **own copy** of `CardModel.dart` / `Service.dart` (3 duplicates) — the change must be applied to all three.

**Add ACH** (Admin / Staff / Tenant) also gets the same WebView + Collect.js treatment (bank account/routing → token via `POST /api/nmipayment/tenant/add-tenant-ach`). Verify the ACH screen files + endpoint contract the same way we did for cards before wiring.

**OUT of scope:**
- **Make Payment / sale / refunds / wallet** — already use **saved vaulted cards** (`customer_vault_id` / `billing_id`), no raw PAN entry. Unaffected.
- **Plan / Subscription purchase** (`planform.dart`, `PreminumPlanForm.dart`) — **out of scope.** Separate SaaS self-billing flow (admin buys a CRM plan), not part of the tenant card-add fix.

## 3. Approved approach
- NMI's tokenizer is **Collect.js**, browser-only. NMI has **no keyed-card mobile SDK** (their mobile SDKs are hardware card-readers only).
- Therefore: **Collect.js inside a `webview_flutter` WebView** — NMI's intended mobile method, and what the RN apps (Cloud Studio / Cloud Job = `cpmobile2025`) already do.
- **Build ONE reusable tokenizing card widget; reuse across all 3 screens.**

## 4. Verified backend contract (read from web source of truth — confirm on **staging + prod** before shipping; local `main` can be stale)

### Tokenization key
`GET /api/tenant/nmi_public_key/{tenant_id}` — auth: `verifyToken`.
- Returns `{ statusCode: 200, publicKey, message }`.
- `publicKey` = `SecurityKey.public_key` for `tenant.admin_id`; **can be `null`** (no NMI configured) → must guard with a clear "payment gateway not configured" message, **don't crash/proceed**.
- Also handle the **404 "Tenant not found"** branch.
- `GET /api/tenant/nmi_public_key_by_admin/{admin_id}` exists but is **unauthenticated** (for public applicant forms). **Use the tenant-scoped `verifyToken` route** for Admin/Staff-on-behalf; only fall back to `_by_admin` when there is no tenant record yet.

### Collect.js script
Load from **`https://hms.transactiongateway.com/token/Collect.js`** with `data-tokenization-key={publicKey}` + `data-theme="material"`.
⚠️ **NOT** `secure.networkmerchants.com` (that's the RN apps' own NMI account) and **NOT** `secure.nmi.com` (web uses that only for public applicant forms). The key + domain must match the same platform.

### Save (submit token)
`POST /api/nmipayment/tenant/add-tenant-payment` — auth: `verifyToken`, `Content-Type: application/json`.
- **REQUIRED:** `payment_token`, `first_name`, `email`, `phone`, `tenant_id`, `admin_id` (admin_id drives the server security-key + company lookup).
- **OPTIONAL:** `last_name`, `address1`, `address2`, `city`, `state`, `zip`, `country`, `company`.
- **RECOMMENDED:** `cc_bin` (from `response.card.bin`) — drives the stored `card_type`.
- **`cc_exp`** is now sent for **exact web parity** (web's `AddCardForm.jsx:153` sends `cc_exp: response.card.exp`); the route **ignores it** — the token carries expiry — so it's harmless. Value = `CardToken.exp` (same Collect.js source as web). Added to all 3 services 2026-07-23.
- **DO NOT SEND:** `cc_last4`, `customer_vault_id`, `billing_id` (server generates/resolves).
- **Success:** HTTP **200**, human message at **`data`** (string). Creates/updates the vault; new-vault path also sends a welcome email + writes an Activities log → **treat 200 as committed, no blind retries.**
- **Failure:** **403** (validation / NMI decline, `responsetext`) **or 500** (network/exception) — message at **`data.error`**. Don't key error handling on 403 alone.
- Server keys off `admin_id` (security key) + `tenant_id` (target), so **Admin/Staff-adding-on-behalf works** through this one route.

## 5. Current state (what each screen does today — the thing we're replacing)
- Collects Card Number (Luhn/16-digit), Expiration, CVV as native `CustomTextField`s.
- **Strict two-step save**, raw PAN in **both** payloads:
  1. `create-customer-vault` **or** `create-customer-billing` (sends `ccnumber`), then
  2. `addCreditCard` (sends `cc_number` for BIN).
- CVV is captured/validated but **never sent** to the server (no cvv key in any body).
- Success accepted on **200 or 201**.
- **Weak error handling:** `addCreditCard` is `Future<void>`, never checked → success toast + `Navigator.pop` fire **even if it fails**; in the with-vault branch the error `else` is commented out (spinner hangs). Fix during migration.
- **Dead code to remove:** the `create-customer-vault` branch (guard never true → always runs billing branch), `_validateInput`/`carderrorMessage`, expiry pickers `_selectedExpiring*`, `card_id` (always null), unreferenced `abc2.dart`.
- **Two layouts:** `>600px` = tablet (no try/catch, looser validation) vs mobile — **QA must cover both.**
- **Debug logs** print the full request body incl. `ccnumber` (kDebugMode-guarded) — **delete when tokenizing.**
- Staff: `id` header must carry **`staff_id`** (not adminId); staff has no `adminId` in prefs (company `admin_id` comes from lease/tenant). Tenant: guard the null-`adminId` prefs case that currently throws.

## 6. Target flow (after)
1. Screen opens → `GET nmi_public_key/{tenant_id}` → `publicKey` (guard null / 404).
2. WebView loads inline HTML with Collect.js (hms domain) + `#ccnumber #ccexp #cvv`; `CollectJS.configure({variant:'inline', fields})`.
3. Billing fields stay **native Flutter**; only the 3 card inputs become the WebView box.
4. User taps native **Add Card** → Dart `runJavaScript('window.submitForm()')` → `CollectJS.startPaymentRequest()`.
5. Collect.js callback → JS→Dart channel returns `payment_token` + `card.bin`.
6. Dart `POST add-tenant-payment` with `payment_token` + `cc_bin` + billing + `admin_id`/`tenant_id`. Success = 200.
7. Remove both old raw-card calls. **Raw PAN never touches Dart or our server.**

## 7. RN reference (Cloud Studio / Cloud Job = `cpmobile2025`)
- `src/components/adminViews/AddCardForm.jsx` — the save-card variant (our model). `react-native-webview` + inline HTML + Collect.js; native billing inputs; `injectJavaScript('window.submitForm()')` → `startPaymentRequest()`; token out via `window.ReactNativeWebView.postMessage` → `onMessage` → posts `{...form, payment_token}`. Ready-guard on a `collectjs_loaded` message.
- `src/components/payment/POSPaymentModal.jsx` — a **direct-sale** variant that posts the token to NMI `transact.php` with a **hardcoded security key**. ⚠️ **Do NOT copy** — our token goes to our server, which does the NMI call server-side.
- Uses `secure.networkmerchants.com` (their account) — **we use `hms.transactiongateway.com`**.

### Flutter mapping (1:1)
| Move | RN (`react-native-webview`) | Flutter (`webview_flutter`) |
|---|---|---|
| Load HTML | `<WebView source={{html}}/>` | `controller.loadHtmlString(html)` |
| JS→Dart (token out) | `ReactNativeWebView.postMessage` + `onMessage` | `addJavaScriptChannel('PayBridge')` |
| Dart→JS (tokenize) | `injectJavaScript('submitForm()')` | `controller.runJavaScript('submitForm()')` |
| page-loaded | `onLoad` | `NavigationDelegate(onPageFinished:)` |

## 8. Build phases (one at a time; current flow keeps working until Phase where it's swapped)
- **Phase 0 — Approval:** confirm scope with Eric (Add Card + Add ACH, all 3 modules). Confirm with Neil: the payments-router **mount prefix** and that the contract matches **staging + prod**.
- **Phase 1 — Setup:** add `webview_flutter`; Android internet permission; iOS check.
- **Phase 2 — Prove render:** blank WebView renders.
- **Phase 3 — Card HTML:** Collect.js + fields + configure.
- **Phase 4 — Token bridge:** JS channel returns token/bin; ready-guard.
- **Phase 5 — API:** `add-tenant-payment`; success (200/`data`) + error (403/500/`data.error`) handling; null-key guard.
- **Phase 6 — Wire Admin:** replace card fields with the widget; remove both raw-card calls; cover mobile + tablet.
- **Phase 7 — Rollout:** Staff + Tenant (shared widget); staff `id` header; tenant `adminId` guard; apply the same swap to each module's **Add ACH** screen (→ `add-tenant-ach`).
- **Phase 8 — Test + PCI + cleanup:** matrix (3 modules × iOS/Android × mobile/tablet; test card, decline, null-key, no-network); proxy-verify **no PAN leaves the app**; delete raw-card controllers/fields/logs + dead branches; regression Make Payment.

## 9. Open items to confirm
- **Eric:** scope OK?
- **Neil:** payments-router mount prefix; contract unchanged on **staging + prod**; desired `card_type` when `cc_bin` omitted; that a **Staff token** passes `verifyToken` on `nmi_public_key`; the **`add-tenant-ach`** contract (verify like the card route).

## 10. Test card
`4242 4242 4242 4242`, exp `12/29`, CVV `123` → token → saves → shows.
