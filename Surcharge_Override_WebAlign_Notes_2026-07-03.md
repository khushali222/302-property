# Surcharge / Convenience-Fee Override — Web Alignment Notes

**Date:** 2026-07-03
**Branch:** feature/tenant-summary-ui-and-account-login-enhancements
**Source of truth:** staging/production web app (`302 Web/crm`)
**Scope:** payment-surcharge calculation only — no UI/layout changes

---

## 1. Why this change

A tenant (Mark Steele) paid through the **mobile Tenant Portal** and was charged a **$2
surcharge** on a payment where the web app and older mobile builds recorded **$0**. The
payment record itself confirmed the source: `source_platform: "Mobile App"`,
`source_user_agent: CRM-Mobile/1.0.148`.

The server does **not** compute the surcharge — it records whatever amount the client
sends (`PaymentService.js`: the saved `surcharge` is taken from the request body). So the
wrong number was produced and sent by the mobile app.

Investigation showed the mobile payment screens had drifted from the web's surcharge
rules. The drift was **pre-existing** (the payment code is byte-identical between builds
1.0.133 and 1.0.148 — the version correlation was a coincidence of which payment method /
settings were used).

---

## 2. The web rule (the behaviour we aligned to)

Confirmed identical across all three web payment screens:
`AddPaymentByTenant.jsx` (tenant), `Staffaddpayment.jsx` (staff), `AddPayment.jsx` (admin).

Surcharge is computed on the base amount and added on top. Payment method is chosen by
explicit state (ACH vs Card), never inferred.

| Payment type | Formula | Uses `override_fee`? |
|---|---|---|
| **ACH** | `base * surcharge_percent_ACH/100 + surcharge_flat_ACH` (each term only if > 0; flat is a **dollar** amount, not a %) | **No** |
| **CREDIT** card | `base * surcharge_percent / 100` | **No** |
| **DEBIT** card | `base * effectivePercent / 100`, where `effectivePercent = override_fee` **only when** `enable_override_fee == true` **AND** `override_fee != null`; otherwise `surcharge_percent_debit`. `override_fee` is a **percentage**. | **Yes — debit only** |
| Unknown card type | `0%` | — |

**Key takeaway:** the override applies **only to debit cards, and only when the
`enable_override_fee` flag is on.** Credit and ACH never touch it.

---

## 3. What the mobile app was doing wrong

Across the payment screens (worst on the tenant screen, which produced the $2):

1. **`enable_override_fee` was never read.** The override was applied purely on whether an
   `override_fee` value existed — even when the owner had the override switched off.
2. **The override was wrongly applied to CREDIT cards** (tenant screen). Web never does
   this — credit always uses `surcharge_percent`.
3. **The debit override didn't recompute the fee.** The percent variable was set but the
   `surchargeamount`/total was left at a previously-computed value — so a stale default fee
   (the $2) got sent.
4. **Any non-credit card was treated as debit** (bare `else`), instead of mapping unknown
   types to 0%.
5. **Percents were parsed as `int`**, truncating fractional rates (e.g. 2.5% → 2).
6. Surcharge/total were sent unrounded (raw float artifacts).

---

## 4. Files changed and what was done

All five screens now follow the web rule exactly. ACH math was already correct and its
behaviour was preserved (only broken always-true guards and rounding were fixed).

| # | File | Module |
|---|---|---|
| 1 | `lib/TenantsModule/screen/financial/payment/make_payment.dart` | Tenant (the $2 screen) |
| 2 | `lib/screens/Leasing/RentalRoll/make_payment.dart` | Admin — make payment |
| 3 | `lib/screens/Leasing/RentalRoll/Edit_make_payment.dart` | Admin — edit payment |
| 4 | `lib/StaffModule/screen/Leasing/RentalRoll/make_payment.dart` | Staff — make payment |
| 5 | `lib/StaffModule/screen/Leasing/RentalRoll/Edit_make_payment.dart` | Staff — edit payment |

Changes applied per file (same pattern):

- **Read `enable_override_fee`** as a sibling of `override_fee` from the same tenant JSON
  object (tenant screen: the `tenant_due_amount` / token-check response; admin & staff:
  the tenant-list record, via a new `getEnableOverrideFee()` helper alongside the existing
  `getOverrideFee()`).
- **CREDIT** → always `surcharge_percent`; override removed from this path.
- **DEBIT** → `override_fee` only when `enable_override_fee == true` AND the value is a
  real, non-`"null"`, non-empty number; otherwise `surcharge_percent_debit`. The surcharge
  amount and total are **recomputed** in both paths.
- **Unknown card type** → `0%`.
- Percent variables changed from `int` to `num`/`double`; parsing uses
  `num.tryParse(...)` / `double.tryParse(...)` so fractional rates survive.
- Surcharge and total **rounded to 2 decimals** before display and before sending.
- ACH left functionally unchanged (still `percent + flat`, override never applied);
  always-true `||` guards fixed to real truthiness, and the ACH total now **resets to 0
  when there is no fee or no amount** (previously a stale value could linger).
- All numeric reads from the surcharge settings JSON hardened with `num.tryParse` so a
  string-typed value from the backend cannot crash the screen (consistent with the
  project's `constant.dart` coercion helpers).

---

## 5. Verification

- `dart analyze` on all five files: **0 error-severity issues** (only pre-existing
  info/warning lint unrelated to this change).
- Each file independently reviewed against the web rule: credit never uses the override,
  debit is gated on the flag and recomputes, unknown types are 0%, percents are decimal,
  ACH behaviour unchanged.

---

## 6. Known limitations / out of scope

- **Admin edit-payment (`lib/screens/Leasing/RentalRoll/Edit_make_payment.dart`)** has its
  card-selector UI commented out (roughly lines 1722–1900), so `selectedcardindex` is
  always null and card surcharge is effectively 0 for that screen today. The surcharge
  **rule** is now correct, but it cannot be exercised until that selector is re-enabled.
  Re-enabling it was intentionally left out of this change.
- **Recompute timing on tenant switch:** on the edit screens, `fetchSurcharge()` is wired
  to card selection, not to re-selecting a different tenant after a card is chosen. The
  displayed/submitted **amount** is always recomputed live from the current input, so it is
  never stale; only the debit percent can lag until the card is re-selected. Left as-is to
  avoid re-architecting those screens.
- The tenant checkout screen (`checkout_screen.dart`, wallet payments) needed **no change**
  — it forwards the already-computed surcharge and does no calculation.

---

## 7. Round 2 — full payment-flow parity (HIGH fixes, 2026-07-03)

After the override work, a full mobile-vs-web parity audit of all 5 payment screens (plus
an end-to-end trace of `enable_override_fee`) was run. Verdicts:

- **Override wiring confirmed sound.** `enable_override_fee` is a **tenant-level** field
  (there is no rental-owner override in play). The tenant screen receives it from
  `token_check` + `tenant_due_amount`; admin/staff from `/leases/lease_tenant`. All return
  the real value with matching `snake_case` keys — **no null-flag regression.**

The audit surfaced further pre-existing divergences from web. The HIGH ones were fixed:

| # | Fix | Files |
|---|-----|-------|
| 1 | `charge_type` re-added to the immediate card/ACH/manual entry maps (was computed then dropped, breaking ledger attribution) | `lib/repository/payment/payment_service.dart` (admin create) + `lib/StaffModule/repository/payment/payment_service.dart` (staff create) |
| 2 | Manual tenders (Check/Cash/Money Order/Cashier's/Manual) no longer send a card-style % surcharge; they send `surcharge = 0` and the base amount | admin & staff `make_payment.dart`; admin & staff `Edit_make_payment.dart` |
| 3 | Debit cards now gated on `debitCardAccepted` (were always selectable) | tenant `make_payment.dart` |
| 4 | Edit no longer flips a payment to `PENDING` (`response`/`is_leaseAdded` removed from the manual-edit PUT); `entry.balance` now equals the paid amount | admin & staff `Edit_payment.dart` (manual body) + admin & staff `Edit_make_payment.dart` (balance) |
| 5 | Tenant card sales send the real `processor_id` (was `""`) | tenant `make_payment.dart` |

**Per-module repo note:** the create/edit repositories are **not** shared across modules —
admin uses `lib/repository/payment/*`, staff uses `lib/StaffModule/repository/payment/*`
(resolved via each screen's relative import). Both copies were fixed. The nested
`lib/StaffModule/repository/repository/payment/payment_service.dart` is dead (imported by
nothing) and was left untouched. Card/ACH **edit** goes through `storePaymentForEdit`
(which never sent `response`), so the card/ACH methods that still contain `response` are
not on the edit-PUT path and were intentionally not modified.

**Verification:** `dart analyze` on all touched files = **0 errors**; each fix had an
independent isolation review confirming no other flow/method/caller changed and the
surcharge/override logic was preserved.

### Deferred (NOT changed — need a decision or are larger)
- **#6** `is_web` / `user_active_recently` sent from mobile payloads — web does not send
  them; **confirm backend expectation before removing** (removal could affect server logic).
- **#7** future-vs-immediate uses the **device clock** instead of company timezone
  (web's CRM-4079 fix) — needs a timezone fetch + logic change.
- **#8** uploaded files silently dropped on manual/future payments.
- Full **edit-payload unification** (mobile splits edit into two payloads vs web's single
  PUT) — larger refactor.
- **Not yet audited:** other charge surfaces — `enterCharge`, `ScheduledCharge`,
  `RecurringChargeDialog`, `RenewLease`, `Financial`, `Tenant_payments`, and the
  Convenience-Fee report.

---

## 8. Round 3 — Add-Charge & Scheduled-Charge parity (2026-07-03)

Audited the add-charge and add-card screens against web. **Add-card / add-ACH is left
untouched by explicit decision** (mobile sends raw PAN/CVV/bank data to non-tokenized
routes while web tokenizes with NMI Collect.js — a large, security-sensitive change to be
handled separately). The add-charge / scheduled-charge divergences were fixed:

**Shared charge model — `lib/model/EnterChargeModel.dart`**
- `Charge.totalAmount`, `Entry.amount`, `Entry.dueAmount` changed from `int` to `num` so
  charge amounts are no longer truncated (e.g. $1,250.75 was posting as $1,250).
  Verified `dart analyze` clean across all 11 files that consume this model (including the
  payment screens from Rounds 1–2).

**Add-charge screens — admin `lib/screens/Leasing/RentalRoll/enterCharge.dart` + staff
`lib/StaffModule/.../enterCharge.dart` (create + edit paths)**
- Amounts parsed with `num.tryParse` (decimals preserved).
- `due_amount` now equals the amount (was hard-coded `0`; matches web).
- Amount bounds enforced before submit: `> 0.01` and `≤ 999,999.99` (matches web/server).
- `charge_type` now uses the account's real type when present, falling back to the old
  derivation (was always `"One Time Charge"` for custom accounts).
- **Honest scheduled-vs-posted confirmation:** `postCharge`/`EditCharge` in both lease
  repos (`lib/repository/lease.dart`, `lib/StaffModule/repository/lease.dart`) now return
  the full `http.Response`; the screens read the body and show the server's real message
  when a future-dated charge is *scheduled* (not posted), instead of a blind
  "Charge posted successfully". The one other caller (`lib/screens/test_table/make_payment.dart`)
  was adapted to the new return type.
- Each entry now preserves its own original date on edit; the date field is locked while
  editing.

**Scheduled-charge screens — admin + staff `.../scheduled_charges/ScheduledCharge.dart`**
- Deletion now requires a non-empty reason (web blocks empty).
- Edit rejects `amount ≤ 0`.
- Edit date picker blocks past dates (`firstDate = today`, matching web's `minDate`).

**Verification:** `dart analyze lib` = **0 errors project-wide**; diff confined to
charge/payment files; card/ACH and `is_web` untouched.

### Round 3 — `entry_id` on charge edit (DONE)
Verified the web server matches charge edits by `entry_id` (Charges.js:450–586, "compare
entries by entry_id first") and generates it on create (Charges.js:151). So mobile now:
- Adds an optional `entryId` to the shared `Entry` model, serialized **only when non-null**
  (`lib/model/EnterChargeModel.dart`) — create omits it (server generates), edit sends it.
- Populates `entry_id` from the loaded charge in each screen's edit-prefill and passes it on
  the `Entry` build (`lib/screens/.../enterCharge.dart` + `lib/StaffModule/.../enterCharge.dart`).
- Analyzer clean. This lets the server correctly match edited entries to existing ledger rows.
