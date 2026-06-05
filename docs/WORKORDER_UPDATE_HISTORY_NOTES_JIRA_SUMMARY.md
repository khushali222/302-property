# Jira Summary: Work Order – Update History (Public/Private Notes + Update 500)

> Two items below: **STORY** (mobile app feature) and **BUG** (backend API 500). Split into two Jira tickets if needed.

---

# STORY — Work Order Update History: Public/Private Notes (Vendor & Tenant)

## Epic / Story
**Mobile app: Bring the Work Order "Update History" in line with the web/admin — add Public & Private notes, an Assigned dropdown, and Due Date validation, in both the Vendor and Tenant modules.**

---

## Overview (for Jira description)
On the web/admin the Work Order "Update Work Order" dialog and "Update History" support **Public notes** and **Private notes**, an **Assigned** person, **Due Date**, and **Status**. The Flutter app only had Status + Due Date + a single "Message" field, and the history showed a placeholder line ("… updated this work order") instead of real notes.

This story redesigns the "Update Work Order" dialog and the "Update History" cards to match the web:
- **Vendor module** now captures and displays **Public notes + Private notes** (both).
- **Tenant module** is redesigned the same way but with a **single "Notes" field** (no public/private split, by request).
- Both modules add an **Assigned** dropdown and **Due Date validation**.
- The update now **refreshes the history even when the API returns the known 500** (see BUG below), so the new entry still appears — same behaviour as the web.

---

## Objective
- Match the web/admin design for the Work Order update flow on mobile.
- Vendor: add **Public notes** and **Private notes** to the update dialog and the Update History.
- Tenant: same redesign (Assigned, Status, Due Date validation) but a **single Notes** field — **no** public/private split.
- Add **Due Date required validation** to the update dialog.
- Pre-select current Status and Assignee when opening the dialog.

---

## Scope
- **Vendor:**
  - `lib/VendorModule/screen/work_order/workorder_summery.dart` (update dialog + 2 history layouts + assignee loader)
  - `lib/VendorModule/model/workorder_summery_model.dart` (`WorkorderUpdates` model)
- **Tenant:**
  - `lib/TenantsModule/screen/work_order/workorder_summery.dart` (update dialog + 2 history layouts + assignee loader)
  - `lib/TenantsModule/model/workorder_summery_model.dart` (`WorkorderUpdates` model)
- **API (consumed):** `PUT /api/work-order/work-order/{workorderId}`, `GET /api/work-order/workorder_details/{workorderId}`, `GET /api/staffmember/staff_member/{id}` (Assigned dropdown).

---

## Changes Implemented

### 1. Data model (`WorkorderUpdates`)
- **Vendor:** added `publicNotes` (`public_notes`), `privateNotes` (`private_notes`), `staffmemberId` (`staffmember_id`) to fromJson/toJson.
- **Tenant:** added `publicNotes` (`public_notes`) and `staffmemberId` (`staffmember_id`). (No private notes.)

### 2. "Update Work Order" dialog — redesign
- Wrapped content in a `Form` + scroll view; added **Due Date required** validation.
- Added an **Assigned** dropdown (staff list loaded on screen open):
  - Vendor: staff fetched with `vendor_id`.
  - Tenant: staff fetched with `adminId`.
- **Status** pre-selected from the work order; options guarded (`New / In Progress / On Hold / Completed / Closed`) so a `Closed` work order can't crash the dropdown.
- **Due Date** pre-formatted; vendor saves `yyyy-MM-dd`; tenant keeps its existing `reverseFormatDate` + `notificationTime`.
- **Notes:**
  - Vendor: two fields — **Public notes** ("Notes visible to all users") + **Private notes** ("Notes visible to staff only").
  - Tenant: one field — **Notes** ("Notes visible to all users").
- Fixed Vendor "Updated By" tag from `"(Tenant)"` → **`"(Vendor)"`**.

### 3. Update History cards (mobile + wide layouts)
- Replaced the placeholder "… updated this work order" line with the real notes:
  - Vendor: **Public notes** and **Private notes** (shows `-` when empty).
  - Tenant: **Notes** (shows `-` when empty).

### 4. Save / refresh behaviour
- On Save: validate form → close dialog → call `updateworkorderSummary(...)` → **refresh the summary regardless of success or the 500** (`.catchError(...).whenComplete(...)`), so the newly added history entry appears immediately.

---

## Acceptance Criteria
- Vendor update dialog shows **Assigned, Status, Due Date (required), Public notes, Private notes**.
- Tenant update dialog shows **Assigned, Status, Due Date (required), Notes** (no private).
- Saving with an empty Due Date shows a validation error and blocks submit.
- After saving, the new entry appears in **Update History** with its notes (Public/Private for vendor, Notes for tenant).
- Closed work orders open the dialog without crashing.

---

## Notes / Dependencies
- Assumes the per-update history entries are stored under keys **`public_notes`** / **`private_notes`** (matching the work-order `public_notes` field). If the backend uses different keys, notes save but display blank — confirm against the API.
- Blocked from a clean response by the backend 500 below (data still saves; UI refreshes anyway).

---
---

# BUG — Work Order Update returns 500: "Cannot read properties of null (reading 'rentalOwner_name')"

## Summary
`PUT /api/work-order/work-order/{id}` returns **500 Internal Server Error** on every Work Order update (both Tenant and Vendor history updates).

## Environment
- Staging API: `https://staging.cloudrentalmanager.com`
- Endpoint: `PUT /api/work-order/work-order/{workorderId}` (e.g. `…/1764864573245`)
- Seen on **both web and mobile** (same endpoint).

## Response
```json
{ "statusCode": 500, "message": "Cannot read properties of null (reading 'rentalOwner_name')" }
```

## Steps to Reproduce
1. Open a Work Order (e.g. property "frescono court").
2. Click **Update**, fill the fields, **Save**.
3. Network tab → the PUT returns **500**.

## Expected
- API returns **200** with the updated work order.

## Actual
- API returns **500**. **The update is still saved** (the new entry appears in Update History), but the response is an error.

## Root Cause (server-side)
- Node/JS error: the update handler reads `rentalOwner_name` from a **null** object — i.e. the work order's property has **no rental owner** (or the owner lookup returns null), and the code accesses `owner.rentalOwner_name` without a null check.
- The crash happens **after** the record is persisted, which is why the entry still shows in history.
- **Not** a mobile/web client issue and **not** related to the notes fields — the client never sends `rentalOwner_name`.

## Suggested Fix (backend)
- Add a null guard before reading the name, e.g. `rentalOwner?.rentalOwner_name`, and/or ensure the property has a rental owner assigned.

## Severity
- Medium: data saves, but the 500 breaks success handling / can show error states and block follow-up steps.
