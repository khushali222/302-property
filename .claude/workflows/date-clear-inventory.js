export const meta = {
  name: 'date-clear-inventory',
  description: 'Classify every date-picker field in the app as clearable (optional) or not (required) for the app-wide Clear-button rollout',
  phases: [
    { title: 'Inventory', detail: 'parallel agents read screens and classify each date field' },
  ],
}

const files = ["lib/screens/Leasing/RentalRoll/RenewLease.dart", "lib/StaffModule/screen/Leasing/RentalRoll/RenewLease.dart", "lib/screens/Leasing/RentalRoll/SummeryPageLease.dart", "lib/StaffModule/screen/Leasing/RentalRoll/SummeryPageLease.dart", "lib/screens/Leasing/RentalRoll/Move_out_lease/Moveout_lease.dart", "lib/StaffModule/screen/Leasing/RentalRoll/Move_out_lease/Moveout_lease.dart", "lib/screens/Leasing/RentalRoll/add_tenant_cosigner_screen.dart", "lib/screens/Leasing/RentalRoll/Renters Insurance/RentersInsuranceAdd.dart", "lib/screens/Leasing/RentalRoll/Renters Insurance/Edit_Renters_insurance.dart", "lib/StaffModule/screen/Leasing/RentalRoll/Renters Insurance/RentersInsuranceAdd.dart", "lib/StaffModule/screen/Leasing/RentalRoll/Renters Insurance/Edit_Renters_insurance.dart", "lib/screens/Leasing/RentalRoll/Financial.dart", "lib/StaffModule/screen/Leasing/RentalRoll/Financial.dart", "lib/screens/Leasing/RentalRoll/make_payment.dart", "lib/StaffModule/screen/Leasing/RentalRoll/make_payment.dart", "lib/screens/Leasing/RentalRoll/Edit_make_payment.dart", "lib/StaffModule/screen/Leasing/RentalRoll/Edit_make_payment.dart", "lib/screens/Leasing/RentalRoll/enterCharge.dart", "lib/StaffModule/screen/Leasing/RentalRoll/enterCharge.dart", "lib/screens/Leasing/RentalRoll/RecurringChargeDialog.dart", "lib/screens/Leasing/scheduled_charges/ScheduledCharge.dart", "lib/StaffModule/screen/Leasing/scheduled_charges/ScheduledCharge.dart", "lib/screens/Maintenance/Workorder/Add_workorder.dart", "lib/StaffModule/screen/Maintenance/Workorder/Add_workorder.dart", "lib/screens/Maintenance/Workorder/Edit_workorders.dart", "lib/StaffModule/screen/Maintenance/Workorder/Edit_workorders.dart", "lib/screens/Maintenance/Workorder/workorder_summery.dart", "lib/StaffModule/screen/Maintenance/Workorder/workorder_summery.dart", "lib/screens/Maintenance/Workorder/AddWorkOrderMobileWizard.dart", "lib/VendorModule/screen/work_order/Edit_workorders.dart", "lib/VendorModule/screen/work_order/update_workorder.dart", "lib/TenantsModule/screen/work_order/update_workorder.dart", "lib/screens/Rental/Properties/add_new_property.dart", "lib/StaffModule/screen/Rental/Properties/add_new_property.dart", "lib/screens/Rental/Properties/EditProperties.dart", "lib/StaffModule/screen/Rental/Properties/EditProperties.dart", "lib/screens/Rental/Properties/unit.dart", "lib/StaffModule/screen/Rental/Properties/unit.dart", "lib/screens/Rental/Properties/summery_page.dart", "lib/StaffModule/screen/Rental/Properties/summery_page.dart", "lib/screens/Rental/Properties/Additional Stats/AddEditAdditionalStat.dart", "lib/StaffModule/screen/Rental/Properties/Additional Stats/AddEditAdditionalStat.dart", "lib/screens/Rental/Properties/Insurance Premium/AddEditInsurancePolicy.dart", "lib/StaffModule/screen/Rental/Properties/Insurance Premium/AddEditInsurancePolicy.dart", "lib/screens/Rental/Properties/Property Tax/Add_property_Tax.dart", "lib/StaffModule/screen/Rental/Properties/Property Tax/Add_property_Tax.dart", "lib/screens/Rental/Properties/applience/Add_applience.dart", "lib/StaffModule/screen/Rental/Properties/applience/Add_applience.dart", "lib/screens/Rental/Properties/applience/edit_appliences.dart", "lib/StaffModule/screen/Rental/Properties/applience/edit_appliences.dart", "lib/screens/Rental/Properties/applience/Applience_parts.dart", "lib/StaffModule/screen/Rental/Properties/applience/Applience_parts.dart", "lib/screens/Rental/Properties/moveout/Moveout_properties.dart", "lib/StaffModule/screen/Rental/Properties/moveout/Moveout_properties.dart", "lib/screens/Rental/Rentalowner/Add_RentalOwners.dart", "lib/StaffModule/screen/Rental/Rentalowner/Add_RentalOwners.dart", "lib/screens/Rental/Rentalowner/Edit_RentalOwners.dart", "lib/StaffModule/screen/Rental/Rentalowner/Edit_RentalOwners.dart", "lib/screens/Rental/Tenants/add_tenants.dart", "lib/StaffModule/screen/Rental/Tenants/add_tenants.dart", "lib/screens/Rental/Tenants/AdminTenantInsurance/addAdminTenantInsurance.dart", "lib/StaffModule/screen/Rental/Tenants/AdminTenantInsurance/addAdminTenantInsurance.dart", "lib/screens/Rental/Tenants/AdminTenantInsurance/editAdminTenantInsurance.dart", "lib/StaffModule/screen/Rental/Tenants/AdminTenantInsurance/editAdminTenantInsurance.dart", "lib/screens/Rental/Tenants/Payments/Tenant_payments.dart", "lib/StaffModule/screen/Rental/Tenants/Payments/Tenant_payments.dart", "lib/screens/Rental/mortgage/Addmortgage.dart", "lib/StaffModule/screen/Rental/mortgage/Addmortgage.dart", "lib/screens/Rental/mortgage/mortgage_summery.dart", "lib/StaffModule/screen/Rental/mortgage/mortgage_summery.dart", "lib/TenantsModule/screen/documents/add_insurance.dart", "lib/TenantsModule/screen/documents/edit_insurance.dart", "lib/TenantsModule/screen/financial/payment/make_payment.dart", "lib/screens/BidRoom/create_bid_room.dart", "lib/widgets/application_edit_form.dart", "lib/widgets/payment_action_dialogs.dart", "lib/widgets/CustomDateField.dart"]
const CHUNK = 7
const chunks = []
for (let i = 0; i < files.length; i += CHUNK) chunks.push(files.slice(i, i + CHUNK))

const SITES_SCHEMA = {
  type: 'object',
  properties: {
    sites: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          file: { type: 'string' },
          screen: { type: 'string', description: 'human name of the screen, e.g. "Add Work Order (Staff)"' },
          field: { type: 'string', description: 'field label, e.g. "Due Date"' },
          controller: { type: 'string', description: 'TextEditingController variable name' },
          backingDateVar: { type: 'string', description: 'DateTime state var set on pick, empty string if none' },
          pickSites: { type: 'string', description: 'approx line numbers of every showDatePicker/pick function feeding this field' },
          requiredOnMobile: { type: 'string', enum: ['required', 'optional', 'unknown'] },
          emptyPayloadSafe: { type: 'string', enum: ['safe', 'unsafe', 'unknown'], description: 'what happens at save when controller is empty' },
          recommendation: { type: 'string', enum: ['CONVERT', 'SKIP', 'REVIEW'] },
          reason: { type: 'string' },
        },
        required: ['file', 'screen', 'field', 'controller', 'requiredOnMobile', 'emptyPayloadSafe', 'recommendation', 'reason'],
      },
    },
  },
  required: ['sites'],
}

phase('Inventory')
const results = await parallel(chunks.map((chunk, idx) => () =>
  agent(`You are auditing a Flutter property-management app for a "clear date" feature rollout.
Repo root: /Users/sparrow_softtech/Documents/flutter_project/302-property

TASK: For EACH of these files, find EVERY date-picker field (showDatePicker call sites and CustomDateField usages) and classify whether the field may safely get a "clear/X" option. One entry per FIELD (a field may have several duplicated pick call sites — list them together in pickSites).

Files (repo-relative):
${chunk.join('\n')}

HOW TO CLASSIFY requiredOnMobile:
- The app has TWO CustomTextField widgets. The flag-based one (defined in lib/screens/Rental/Tenants/add_tenants.dart and Staff copy) IGNORES the validator: param entirely and validates via flags: optional: true means NOT required; no optional flag means REQUIRED-by-flag. The other (lib/widgets/custom_textfield.dart) honors validator:.
- Signals for required: label with red asterisk '*', enforced validator "Please select ...", form blocks save when empty.
- Signals for optional: optional: true flag, no asterisk, save proceeds with empty value.

HOW TO CLASSIFY emptyPayloadSafe (CRITICAL): trace the controller to the save/payload code.
- safe: payload uses \`x.text.isNotEmpty ? ... : ""\` (or null), or converters like reverseFormatDate/convertToApiDate that return the input/empty string on parse failure.
- unsafe: unguarded DateTime.parse(controller.text) / DateFormat().parse(...) at save or load, or the API param is appended unconditionally and the endpoint needs a real date.
- unknown: cannot tell.

RECOMMENDATION RULES (be conservative — when in doubt REVIEW, never CONVERT):
- CONVERT only when: requiredOnMobile=optional AND emptyPayloadSafe=safe AND it is an add/edit FORM field.
- SKIP when: required; OR it is a report/table filter date, payment date, charge date, scheduled/recurring charge date, move-out action date, insurance effective/expiration date (business rule: those stay required); OR the file/class is dead code (note that).
- REVIEW: anything ambiguous (e.g. optional on mobile but payload unknown, or required on mobile but looks optional on the web app).
- Insurance screens: effective/expiration dates are required by contract -> SKIP.
- DOB on ADD-tenant forms is required by contract -> SKIP. DOB on rental-owner forms: classify by the rules above.

Read each file (use Grep to find 'showDatePicker' and 'CustomDateField' line numbers first, then Read those regions and the save/payload regions). Do not modify anything. Return via StructuredOutput. If a file has zero date fields (e.g. only commented-out code), return no entries for it.`,
    { label: `inv:${idx}`, phase: 'Inventory', schema: SITES_SCHEMA })
))

const sites = results.filter(Boolean).flatMap(r => r.sites)
log(`Inventory complete: ${sites.length} date fields classified`)
return { totalFields: sites.length, sites }
