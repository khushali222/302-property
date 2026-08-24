# Network retry pilot — proven 2026-08-22 (5/5 device tests)

Reapply with:

    git apply docs/network-retry-pilot.patch

## What it does

A screen shows "No Internet" only when **its own request failed** — no screen
asks `connectivity_plus`, which reports `none` on a working iOS network and only
updates on OS events the simulator often never sends. That was why a screen
could sit showing raw errors with no offline state, and why it stayed stuck
until the app was restarted.

Recovery is shared, blocking is not. `CheckConnection` carries two counters —
`successGeneration` and `failureGeneration` — that only ever go up. They are
announcements, not verdicts: they cannot block anything, so a wrong value costs
one needless reload instead of locking all ~300 screens. A shared "we are
offline" flag was rejected for exactly that blast radius.

All the logic lives in `lib/provider/network_retry_state.dart`. A screen supplies
only `reloadData()` and gates its body on `isOffline`. A later change to the
design edits that one file, not every screen.

## Screens wired (3)

- `lib/screens/Profile/Settings_screen.dart`
- `lib/screens/Rental/Properties/Properties_table.dart`
- `lib/screens/Reports/ReportScreens/RentRollReport.dart`

## Guards that must not be removed

- The generation is recorded **before** a reload is issued, so a reload that
  fails can never retrigger itself.
- Silent reloads happen only on `didPopNext` (the screen became visible), so
  stacked screens cannot all fire requests at once.
- Only `ModalRoute.isCurrent` screens react, so a background failure cannot
  fight the Retry on the page the user is looking at.
- An 800ms settle pause before the recovery reload. The announcement fires on
  the *first* success after a failure — the raggedest possible moment — and a
  reload issued there came back non-200. Without the pause the same off/on test
  showed rows one run and "No Data Available" the next.

## Before shipping this

`main.dart` **bypasses `NetworkGuard`** — deliberately, since that overlay is the
one thing that can lock every screen at once. But with it off, any screen not yet
wired shows raw `ClientException` text and no Retry. Either finish the rollout
first, or restore the wrapper.

## Remaining scope (measured 2026-08-22)

| Item | Count |
|---|---|
| Screens with no Retry button | ~83 |
| Screens rendering raw errors or a fake "No Data Available" | 128 |
| Toasts printing raw `$e` (use `friendlyErrorMessage()` / `isNetworkError()`) | 92 |
| Repos returning empty on non-200 | 3 |
| Repos swallowing exceptions entirely | 9 |
