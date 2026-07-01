# Add Tenant — Web Alignment Notes (2026-06-30)

Reference for reviewing the redesigned **Admin Add Tenant** screen.

- **Scope done:** Admin **Add Tenant** only — UI redesign (Pass 1) + payload (Pass 2).
- **Not done yet:** Staff module Add Tenant, and the **Edit** screen.
- **Files changed:**
  - `lib/screens/Rental/Tenants/add_tenants.dart` (form + payload)
  - `lib/repository/tenants.dart` (new `addTenantPayload` method)
- **Backup of original:** in the session scratchpad → `add_tenants.dart.bak`
- **Analyzer:** 0 errors, 0 warnings.

---

## 1. Screen layout (top → bottom)

One responsive scroll (3 old duplicate layouts were collapsed into one). Order:

1. Blue **"Add Tenant"** header (`titleBar`, original style)
2. Card: **Personal Information**
3. Card: **Account Setup**
4. Card: **Notes**
5. Card: **Emergency Contacts**
6. Card: **Payment Settings**
7. **Cancel** + **Add Tenant** buttons — now scroll with the form (not pinned)

Colors all from `constant.dart` (`navyClr`, `pageBg`, `borderClr`, `outlineClr`, `checkOffClr`, `mutedClr`, `tintBg`, `redClr`). Inputs reuse the existing `CustomTextField` in flat mode (`showElevation:false` + `borderColor`).

---

## 2. How each section works

### Personal Information
- Fields: First Name*, Last Name*, Phone Number*, Work Number, Email*, Alternative Email, Date of Birth*.
- `*` = required. Required is enforced by `CustomTextField(optional:false)`.
- **Date of Birth** is read-only + tap opens the date picker (`_selectDate`); now **required**.
- Phone uses 10-digit validation; email uses email-format validation.

### Account Setup  🆕
- One checkbox: **"Email tenant a welcome email to set up their account"** (default **ON**) + helper text.
- Drives `send_welcome_email` in the payload. Replaces the old Password field (server now generates the password and emails a setup link).

### Notes
- Multiline text box → `comments`.

### Emergency Contacts  🆕 (dynamic)
- Starts empty → shows *"No emergency contacts yet. Tap Add Contact to add one."*
- **Add Contact** appends a row labelled **Contact #1, #2, …** (Name, Relationship, Email, Phone).
- 🗑 trash icon removes that row (disposes its controllers).
- On submit: fully-empty rows are skipped; the rest go out as the `emergency_contacts` **array** (new ones have no `contact_id` — the server assigns it).

### Payment Settings
- **"Global debit card fee: X%"** read-only line. ⚠️ Currently hardcoded `"8"` placeholder — **TODO: wire the owner's real global fee** (Pass-2/API leftover).
- Checkbox **"Replace this tenant's debit card fee"** → when ON, shows a `%` input (`override_fee`).
- **Allowed Payment Methods** box: **ACH** + **Credit Card** checkboxes (both ON by default).

---

## 3. What the screen SENDS (POST /api/tenant/tenants)

Built in `addTenant()` as a plain Map, sent via `TenantsRepository().addTenantPayload(body)`:

```json
{
  "tenant_id": "",
  "tenant_firstName": "...",
  "tenant_lastName": "...",
  "tenant_phoneNumber": "(xxx) xxx-xxxx",
  "tenant_alternativeNumber": "",
  "tenant_email": "...",
  "tenant_alternativeEmail": "",
  "tenant_birthDate": "yyyy-MM-dd",
  "comments": "...",
  "send_welcome_email": true,
  "emergency_contacts": [
    { "name": "...", "relation": "...", "email": "...", "phoneNumber": "" }
  ],
  "enable_override_fee": true,
  "override_fee": "2",
  "allow_ach": true,
  "allow_card": true,
  "admin_id": "...",
  "company_name": "..."
}
```

- Phones formatted via `formatPhoneNumberedit()` → `(xxx) xxx-xxxx`, empty → `""`.
- `override_fee` sent as a **string** (`""` when the checkbox is off).
- `admin_id` = `prefs('adminId')`, `company_name` = `prefs('companyName')`.

### Matches the web capture on all 18 real fields. ✅

### Intentionally NOT sent (differ from web on purpose)
- `is_web`, `user_active_recently` — web-only session flags (decision still open if you want them added).
- `tenant_password` — server generates it.
- `taxPayer_id` — SSN/TIN not stored.
- Old noise keys (`_id`, `applicant_id`, `createdAt`, `rental_adress`, etc.) no longer sent.

---

## 4. Old code (kept, not deleted) — for future reference
In `add_tenants.dart`:
- Old `Tenant(...)` payload block inside `addTenant()` is **commented out** with a header.
- Old field declarations commented: `passWord`, `taxPayerId`, `contactName`, `relationToTenant`, `emergencyEmail`, `emergencyPhoneNumber`.
- `Model/tenants.dart` import kept (with `// ignore: unused_import`) so the commented legacy code still compiles if restored.
In `repository/tenants.dart`:
- Old `addTenant(Tenant)` is **untouched** (still used by Staff module / other callers).

---

## 5. TODO / to check next day
- [ ] **Live test:** run app → Tenants → Add Tenant → submit; compare outgoing body to the web capture.
- [ ] Wire the **real global debit fee** (replace hardcoded `"8"`).
- [ ] Decide on `is_web` / `user_active_recently` (add or keep out).
- [ ] Apply the same redesign + payload to the **Staff module** Add Tenant.
- [ ] Apply to the **Edit Tenant** screen.
- [ ] Confirm phone format with backend (we now send `(xxx) xxx-xxxx` like web).
