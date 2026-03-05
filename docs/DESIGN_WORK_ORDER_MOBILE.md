# Mobile-Friendly Work Order — Design & How It Matches Web

This document describes the **mobile-first work order flow** and how it **stays in sync with the web** (same backend, same data).

---

## 1. Design: 4-Step Wizard (Mobile)

Instead of one long scrolling form (web-style), the mobile flow is a **stepped wizard**:

| Step | Screen name   | Fields | Purpose |
|------|---------------|--------|---------|
| **1** | Where & What  | Property*, Unit*, Subject*, Category | Start the work order quickly (location + type). |
| **2** | Details       | Assigned To*, Entry allowed, Vendor, Work to be performed | Assignment and description. |
| **3** | Photos        | Take photo / Choose from gallery (max 10) | Photos as a dedicated step, not buried in the form. |
| **4** | Cost & Finish | Parts & labor (rows), Vendor notes, Billable to tenant, Priority, Status*, Due date | Finalize and submit. |

- **Next / Back** at bottom of each step.
- **Progress indicator** at top (e.g. 1–2–3–4 dots or “Step 1 of 4”).
- **Same required validations** as web (e.g. Property, Unit, Subject, Assigned To, Status).

---

## 2. How Mobile and Web Match (Combine)

- **One backend, one API**  
  Both web and mobile use the **same** work order API (e.g. `POST .../api/work-order/work-order`).

- **Same repository in code**  
  Both call **`WorkOrderRepository().addWorkOrder(...)`** with the same parameters. No separate “mobile API.”

- **Same payload shape**  
  The payload sent to the server is identical:
  - `admin_id`, `work_subject`, `staffmember_id`, `work_category`, `category_id`, `work_performed`, `status`, `rental_address`, `rental_unit`, `entry_allowed`, `tenant_id`, `rental_id`, `unit_id`, `workOrder_images`, `vendor_id`, `vendor_notes`, `priority`, `work_charge_to`, `date`, `is_billable`, `notificationTime`, and `parts` (same structure as web).

- **Same data everywhere**  
  Work orders created on mobile appear on web (and vice versa) because they go to the same database.

- **How to “combine” in the app**  
  - **Option A:** Use **responsive layout**:  
    - Screen width &lt; 500 → show **AddWorkOrderMobileWizard** (4 steps).  
    - Screen width ≥ 500 → show existing **Add_workorder** (full form).  
  - **Option B:** Always show the wizard on phones and the full form on tablet/desktop (same `WorkOrderRepository` and API for both).

---

## 3. Mobile-Friendly UI (vs Web)

| Web (current)           | Mobile (this design)        |
|-------------------------|----------------------------|
| One long scroll         | 4 short steps              |
| Dropdown for Entry      | Yes/No toggle              |
| Dropdown for Priority   | Chips: High / Normal / Low |
| Dropdown for Status     | Chips or bottom sheet      |
| Small tap targets       | 44–48 pt buttons/controls  |
| Quantity: type number   | Stepper (+ / −)            |
| Photos one field among many | Dedicated Photo step   |
| Many dropdowns          | Full-screen or bottom-sheet pickers with search where needed |

---

## 4. Flow Diagram (High Level)

```
[Work order list]
       │
       ▼
[Tap "Add Work Order"]
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│  Step 1: Where & What                                     │
│  Property* │ Unit* │ Subject* │ Category                   │
│                                    [ Next ]               │
└──────────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│  Step 2: Details                                          │
│  Assigned To* │ Entry (Yes/No) │ Vendor │ Work to perform │
│                                    [ Next ]               │
└──────────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│  Step 3: Photos (max 10)                                  │
│  [Take photo]  [Choose from gallery]   [thumbnails]      │
│                                    [ Next ]               │
└──────────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│  Step 4: Cost & Finish                                    │
│  Parts & labor (+ Add row) │ Vendor notes │ Billable     │
│  Priority (chips) │ Status* │ Due date                   │
│              [ Cancel ]  [ Add Work Order ]               │
└──────────────────────────────────────────────────────────┘
       │
       ▼
  WorkOrderRepository().addWorkOrder(...)  ← same as web
       │
       ▼
  Navigator.pop(context, true) → refresh list
```

---

## 5. Code Mapping: Web vs Mobile

| What                | Web (Add_workorder)           | Mobile (AddWorkOrderMobileWizard)   |
|---------------------|--------------------------------|-------------------------------------|
| Submit              | `WorkOrderRepository().addWorkOrder(...)` | Same `WorkOrderRepository().addWorkOrder(...)` |
| Load properties     | `_loadProperties()` → API       | Same API (e.g. rentals list)        |
| Load units          | `_loadUnits(rentalId)`          | Same API                            |
| Load staff/vendors  | `_loadStaff()`, `_loadVendor()` | Same APIs                           |
| Categories          | `FetchAllcategories().fetchAllCategories()` | Same                                |
| Image upload        | `uploadImage(File)` → `_uploadedFileNames` | Same upload, same list of filenames |
| Parts payload       | `parts_quantity`, `account`, `description`, `charge_type`, `parts_price`, `amount` | Same structure |

So: **one design (wizard) for mobile, one code path to the backend** — no separate “mobile API” and no duplicate business logic for “how to create a work order.”

---

## 6. File to Use

- **Design + flow (this doc):** `docs/DESIGN_WORK_ORDER_MOBILE.md`
- **Implementation (one screen):** `lib/screens/Maintenance/Workorder/AddWorkOrderMobileWizard.dart`

**Integration:** In `Workorder_table.dart`, when the user taps "+ Add" and the screen width is under 500px, the app opens `AddWorkOrderMobileWizard`; otherwise it opens the existing `ResponsiveAddWorkOrder` form. So narrow screens (phones) get the 4-step wizard; tablets and web keep the full form. Both use the same `WorkOrderRepository.addWorkOrder()` and API.
