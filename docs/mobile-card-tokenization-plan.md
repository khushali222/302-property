# Mobile Card-Add → Client-Side Tokenization (PCI) — Handoff Brief

Paste this into a new chat to continue. It's self-contained.

## 1. Background / why this task exists
- The mobile Add Card **bug** ("card saves but doesn't show") is **FIXED and DONE**:
  - Server side (Neil): `getCreditCards` stale-sort fixed (timestamps added) — **live on prod** (v2026.07.16.2).
  - Mobile side (us): app now accepts **`200` AND `201`** as success — done + verified on staging (build 1.0.393), Admin + Staff (Tenant fix also applied).
- **This task is a SEPARATE, follow-up item raised by the client (Eric): PCI compliance.**
  - Problem: the mobile app sends the **raw card number through our server** (`create-customer-vault` takes `ccnumber`; `addCreditCard` takes `cc_number` for BIN). Even though we don't store it, transmitting the PAN through the server is a **PCI violation**.
  - Required fix: move mobile to **client-side tokenization** — the card is tokenized **before** it reaches our server; the app only ever handles a **token** (same as the website).
- Status: acknowledged by Eric + Neil. Priority/timeline pending Eric's confirmation. NOT started. Not urgent (current flow works as interim).

## 2. The approach (decided)
- NMI's tokenizer is **Collect.js**, which is **browser-only**.
- **NMI has NO mobile SDK for keyed/typed cards** — their iOS/Android SDKs are hardware card-readers only (verified: https://docs.nmi.com/docs/device-sdk-ios-android).
- Therefore the only viable Flutter approach = **Collect.js inside a WebView** (`webview_flutter`). This is NMI's intended mobile method.

## 3. Target flow (what to build)
1. `GET /api/tenant/nmi_public_key/{tenant_id}` → returns `{ publicKey }` (the Collect.js tokenization key; comes from the server `SecurityKey` collection `public_key`). Also `/nmi_public_key_by_admin/{admin_id}`.
2. Load a small HTML page in a WebView with `<script src="https://hms.transactiongateway.com/token/Collect.js" data-tokenization-key="{publicKey}">` + card fields (ccnumber/ccexp/cvv).
3. User types card into Collect.js's secure fields → Collect.js returns `payment_token` (+ `card.bin`, `card.exp`, last4).
4. WebView passes the token to Flutter via a JS channel.
5. Flutter POSTs to **`POST /api/nmipayment/tenant/add-tenant-payment`** with `payment_token` + `cc_bin`, `cc_last4`, `cc_exp` (MMYY) + first_name/last_name/email/phone/address1/city/state/zip/country/admin_id/tenant_id. Success = `{status:200,...}`.
6. Remove the old two-step calls (`create-customer-vault`/`create-customer-billing` + `addCreditCard`) once the token flow works.

## 4. Files to change (3 modules — all share the same pattern)
- Admin:  `lib/screens/Leasing/RentalRoll/addcard/AddCard.dart` + `Service.dart` + `CardModel.dart`
- Staff:  `lib/StaffModule/screen/Leasing/RentalRoll/addcard/AddCard.dart` + `Service.dart` + `CardModel.dart`
- Tenant: `lib/TenantsModule/screen/financial/AddCard/AddCard.dart` + `Service.dart` + `CardModel.dart`
- Consider building ONE shared WebView tokenization widget and reusing it in all three.

## 5. Ask Neil first (Phase 0 — before coding)
1. Confirm `GET /api/tenant/nmi_public_key/{tenant_id}` returns the correct Collect.js key for the app.
2. Exact `POST /api/nmipayment/tenant/add-tenant-payment` request contract (fields + headers).
3. Does `add-tenant-payment` work when **Admin/Staff add a card on behalf of a tenant** (passing tenant_id), or is it tenant-self only? If not, what endpoint?
4. Which environment to build/test against (newdev / staging).

## 6. Build steps (do one phase at a time; current flow keeps working)
- **Phase 1 Setup:** add `webview_flutter` to pubspec → `flutter pub get`. Android: internet permission; iOS: no extra setup on recent versions.
- **Phase 2 Prove render:** show a WebView loading any simple HTML — confirm it renders.
- **Phase 3 Card page:** HTML string with Collect.js + card fields + a Save button that calls Collect.js tokenize.
- **Phase 4 Token bridge:** add a JS channel; in Collect.js callback, send payment_token/bin/exp/last4 to Flutter; print to confirm it arrives.
- **Phase 5 API call:** POST token to `/tenant/add-tenant-payment`; handle success/error; on success pop + refresh list.
- **Phase 6 Wire in:** replace card-number fields with the WebView box; keep name/address/tenant selection native; remove old two-step calls.
- **Phase 7 Rollout:** apply to Admin, Staff, Tenant (shared widget if possible).
- **Phase 8 Test + PCI check:** add test card (`4242 4242 4242 4242`, exp `12/2029`, CVV `123`) → token → saves → shows; error cases; iOS+Android; **verify the raw card never leaves the app / never hits our server.**

## 7. Useful facts / gotchas
- Response envelopes: `/api/nmipayment/*` = `{status, data}` (payload under `data`); `/api/creditcard/*` = flat JSON.
- `addCreditCard` returns `200` (append to existing vault) or `201` (new vault) — both success.
- Exp format: old two-step accepts `MM/YYYY`; the token endpoint uses `MMYY` (e.g. `1229`).
- Debug logs already in the code, tagged `[ADMIN/STAFF/TENANT ADD-CARD]` (🟪/🟦🟩/🟧), all wrapped in `if (kDebugMode)` so they're debug-only (off in release). Card number prints only in the create-vault/billing REQUEST logs — debug-only now, but delete these logs once tokenization ships.
- Web reference (source of truth) is checked out at `/Users/sparrow_softtech/Documents/302 Web/crm/`. Web add-card client: `Client/src/components/Payments/AddCardForm.jsx` (Collect.js config + token callback). Server new endpoint: `Server/routes/api/payments/NMI-response.js` (`/tenant/add-tenant-payment` ~line 6193). publicKey endpoint: `Server/routes/api/superadmin/Tenants.js` (`/nmi_public_key/:tenant_id` ~line 2450).

## 8. Effort
Feature-sized: ~3–5 working days including WebView + token bridge + wiring + rollout to 3 modules + testing (plus any backend dependency from the Phase-0 answers).
