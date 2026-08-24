# Network Retry Plan — no app restart needed

**Project:** `302-property` (Flutter, v1.0.199+202)
**Goal:** when internet drops, the user presses **Retry** on the same screen and the data loads. No app restart, no going back.
**Status of this document:** plan only. No code was changed.

---

## 1. Short version

The retry system you want is **already built in this project**. It is wired into `main.dart`. It is just **not finished** — one connection is missing, and 95 old screens are fighting it.

That is why you still have to restart the app.

This is not a big rebuild. It is finishing something that is 80% done.

---

## 2. What already exists (good news)

| File | What it does | Wired up? |
|---|---|---|
| `lib/provider/NetworkProvider.dart` (`CheckConnection`) | One app-wide "are we online?" flag. Goes offline only when a real request fails. Auto-lifts every 15s to re-try. | Yes — `main.dart:142` |
| `lib/widgets/network_guard.dart` (`NetworkGuard`) | Full-screen offline overlay with a **Retry** button. Sits **on top** of the screen as a `Stack`, so the screen underneath **stays alive** — same scroll, same filters, same page number. | Yes — `main.dart:184` |
| `lib/widgets/no_internet_view.dart` (`NoInternetView`) | Offline widget, optionally with a Retry button. | Yes — used in 113 places |
| `lib/services/api_helpers.dart` | `apiGet` / `apiPost` / etc. Reports socket failures to `CheckConnection`. Used at **1058 call sites**. | Yes |
| `lib/provider/network_aware_state.dart` (`NetworkAwareState` mixin) | The piece that makes a screen reload itself when internet returns. | **NO — 0 screens use it** |

So the architecture is right. The last row is the problem.

---

## 3. Why you still have to restart the app — the 3 real causes

### Cause A — Retry hides the overlay but nobody reloads the data ⚠️ **this is the main one**

Trace what happens today when the user taps **Retry**:

```
NetworkGuard._retry()
  → CheckConnection.recheck()
  → _apply(true)              // flag goes back to online
  → _notifyRestored()         // asks registered screens to reload
  → _reloadStack is EMPTY     // ← nothing is registered
```

`registerReload()` has **zero real callers**. The only reference is inside the mixin itself, and the mixin is used by **0 screens**.

So: overlay disappears, screen is still showing the old empty state, no API call fires. **The user's only option is to restart the app.** Exactly what you described.

### Cause B — 95 screens still replace their own body with an offline widget

112 files still have their own `checkInternet()` / `checkConnectivity()`, and 95 of them do this:

```dart
body: _connectivityResult != ConnectivityResult.none
    ? _content()
    : NoInternetView(),
```

Two problems with this pattern:

1. `? :` **replaces** the widget. The content is destroyed. Even when the flag flips back, the data is gone and nothing refetches it.
2. `connectivity_plus` `checkConnectivity()` returns a **cached** result that can stay `none` after the network is back. Each of the 112 screens asks the plugin separately, so one screen recovering never helps the next. There are already manual patches in the code working around this (`if (connectiondata == none && ...) connectiondata = wifi;` in several files) — a sign the flag is not trustworthy.

Result: screen gets permanently stuck on "No Internet" until the process is killed.

### Cause C — 83 of those offline widgets have no Retry button at all

- `NoInternetView(...)` with `onRetry`: **29** places
- `NoInternetView()` bare, no button: **83** places

So on most screens there is literally nothing to tap. This is what your QA raised the Jira about, and they are correct.

---

## 4. Secondary gap — some failures never reach `CheckConnection`

`api_helpers.dart` only reports two exception types:

```dart
} on SocketException {      // reported
} on http.ClientException { // reported
```

Not covered:

| Gap | Count | Effect |
|---|---|---|
| `TimeoutException` — thrown by the `.timeout(Duration(seconds: 30))` on every call | all 1058 | A request that times out (weak signal, captive Wi-Fi) never marks the app offline. User sees a dead spinner, not the retry screen. |
| Dio calls via `ApiClient.instance` | 5 | `DioException` on connection error is never reported. |
| Raw `http.get/post/...` (not migrated to `apiGet`) | 11 | Bypass reporting entirely. |

The `TimeoutException` one is the most important — timeout is the *most common* symptom of bad mobile internet, more common than a clean socket error.

---

## 5. The plan

### Phase 1 — Make Retry actually reload (highest value, smallest change)

Connect the mixin that already exists. Per screen it is 3 lines:

```dart
class _MyScreenState extends State<MyScreen> with NetworkAwareState {
  @override
  Future<void> reloadOnNetworkRestored() async {
    await _loadMyData();   // the screen's existing load function
  }
  ...
}
```

That is it. `initState` / `dispose` are handled inside the mixin.

Effect: tap Retry → overlay closes → **that screen's own API call fires again** → data loads. No navigation, no restart. And it also fires automatically when the internet returns on its own, so often the user never has to tap anything.

Do not do all 95 at once. Start with the ~10 screens QA hits most:

1. `screens/dashboard.dart` (Admin dashboard)
2. `TenantsModule/screen/dashboard.dart`
3. `VendorModule/screen/mainScreen.dart`
4. Property list / summary
5. Work order table + summary
6. Rent roll / lease tables
7. Financial / payment tables
8. Notifications
9. Profile
10. Reports

Ship these, let QA verify the behaviour, then roll out to the rest.

### Phase 2 — Delete the per-screen offline branches

For each screen already migrated in Phase 1, remove:

- the `ConnectivityResult? _connectivityResult` field
- the `StreamSubscription` and its `initState` / `dispose` wiring
- the `checkInternet()` method and its stale-`none` workaround
- the `? _content() : NoInternetView()` ternary — **the body just becomes `_content()`**

`NetworkGuard` already paints the offline state over every route. The per-screen copies are redundant *and* actively harmful (Cause B). This phase is mostly **deleting** code, ~40 lines per file.

Do it in the same PR as Phase 1 per screen, so a screen is never half-migrated.

### Phase 3 — Close the reporting gaps

In `api_helpers.dart`, `_reportingNetworkFailures`:

- add `on TimeoutException` → `reportNetworkFailure()` — **do this first, it is one line**
- add `DioException` reporting in `ApiClient`'s interceptor `onError` (for `connectionError` / `connectionTimeout` / `receiveTimeout` types only, not 4xx/5xx)
- migrate the 11 remaining raw `http.*` calls to `apiGet` / `apiPost`

**Important:** only report *transport* failures. A 401 (session expired) or 500 (server error) must NOT show "No Internet" — those are different problems with different fixes. Session-expired should still go to login.

### Phase 4 — Quiet retry before showing anything (optional, later)

In `api_helpers.dart`, retry **GET only** 2× with backoff (400ms, 1200ms + jitter) before giving up. Most drops last under 2 seconds, so the user never sees the offline screen at all.

Never auto-retry POST / PUT / DELETE without an idempotency key — you have `uuid: ^4.5.1` already, so a key per submit is easy, but treat that as separate work.

### Phase 5 — Nice-to-have, later

- **Cache last-loaded lists** (`shared_preferences` is already there) so offline shows old data with "last updated 2:14 PM" instead of a blank overlay.
- **Outbox for submits** — if a work order / payment form was submitted when internet died, hold it and send on reconnect instead of losing what the user typed.

---

## 6. Suggested reply on the QA Jira

> Agreed — app restart is being removed. The retry infrastructure is already in the codebase (`NetworkGuard` + `CheckConnection`); the missing piece is that no screen registers a reload, so Retry closed the overlay without refetching. Wiring the existing `NetworkAwareState` mixin into screens fixes it. Screen keeps its scroll position, filters and page number. Rolling out to the top 10 screens first, then the remaining ~85.

---

## 7. QA acceptance criteria

| # | Test | Expected |
|---|---|---|
| 1 | Turn off Wi-Fi + data mid-list | Offline overlay appears. App does **not** close. |
| 2 | Turn internet back on, tap **Retry** | Same screen reloads its data. No navigation. No restart. |
| 3 | Turn internet back on, **wait, do not tap** | Screen reloads by itself within ~15s. |
| 4 | Tap Retry while still offline | Button greys out, shows "Checking…", then "Still no connection." No crash, no spam. |
| 5 | Go offline on page 3 of a paginated table with filters applied | After recovery: still page 3, filters still applied, scroll position kept. |
| 6 | Tap Retry 10 times fast | Only one request goes out. |
| 7 | Airplane mode, open a fresh screen | Offline overlay, not a dead spinner. |
| 8 | Hotel-style Wi-Fi (connected but no internet) | Overlay appears via timeout — must not hang forever. (This is Phase 3.) |
| 9 | Let session expire (401), internet fine | Goes to login. Must **not** say "No Internet". |
| 10 | Type into a form, drop internet, recover | Typed text is still there. |

---

## 8. Rough effort

| Phase | Work | Effort |
|---|---|---|
| 3 (TimeoutException line) | 1 line | 15 min |
| 1 + 2, top 10 screens | mixin in, legacy out | 1–2 days |
| 3 (Dio + raw http) | 16 call sites | half day |
| 1 + 2, remaining ~85 screens | mechanical, batch by module | 4–6 days, can be split across devs by module |
| 4 (quiet retry) | one helper function | half day |
| 5 (cache + outbox) | new work | separate ticket |

Suggested order: **Phase 3 one-liner → Phase 1+2 on top 10 → QA verifies → roll out the rest.**

---

## 9. One thing to decide

`CheckConnection` blocks the **whole screen** with an overlay when offline. Facebook/Zillow style is gentler: keep the content visible, show a thin "No internet" bar on top, and only the failing section shows retry.

The current full-screen overlay is simpler and QA-friendly, and it is already working — recommend keeping it for now. Revisit in Phase 5 once caching exists, because a gentle bar only makes sense when there is cached content to show underneath it.
