# Play Console "For your next release" Warnings — Full Analysis

_Generated 2026-06-11. Read-only diagnostic — no app code was changed._
_Companion doc: [16KB_PAGE_SIZE_CHECK.md](16KB_PAGE_SIZE_CHECK.md) (deep-dive + Mac checker script for warning #3)._

---

## The single most important fact

All three warnings are tagged **`Release name: 143 (1.0.140)`** — they describe the **old AAB built on the Mac**, not the current code. The current build on the verified Windows machine is **145 (1.0.142)**.

Version `1.0.140+143` does **not exist anywhere in git history** (`git log -S "1.0.140" -- pubspec.yaml` finds nothing) → release 143 was built from **uncommitted/older state on the Mac**. This is exactly why the two machines disagree.

| # | Warning | Type | Blocking? | Status |
|---|---------|------|-----------|--------|
| 1 | Edge-to-edge may not display for all users | User experience | No (advisory) | Informational for every app targeting SDK 35+; Flutter 3.35 handles insets; visual QA recommended |
| 2 | Deprecated APIs or parameters for edge-to-edge | User experience | No (advisory) | Caused by Flutter engine references (verified in dex) + 1 theme attribute; harmless at runtime |
| 3 | **Recompile with 16 KB native library alignment** | **Technical quality** | **YES (Play policy for Android 15+ targeting)** | **Already fixed in the Windows build 145 — verified PASS. Upload it.** |

---

## Warning 3 — 16 KB alignment (the one that matters)

- Release 143's native libs were built with an old toolchain (old Flutter and/or NDK on the Mac) → 4 KB-aligned → flagged.
- The Windows-built `app-release.aab` **145 (1.0.142)** was extracted and every 64-bit library checked with `llvm-readelf`: **all `arm64-v8a` and `x86_64` libs aligned `0x4000`+ → compliant** (full table in [16KB_PAGE_SIZE_CHECK.md](16KB_PAGE_SIZE_CHECK.md)).
- **Action:** upload build ≥145 produced by a compliant environment (Flutter 3.35.7 + NDK 29.0.14206865 + this repo's committed config) and roll it out. The warning clears with the new release.
- On the Mac, before building: `bash docs/check_16kb_alignment.sh` must print `RESULT: PASS` on the produced AAB.

---

## Warning 2 — "Deprecated APIs or parameters for edge-to-edge"

This is a **static scan**: Play flags the *presence* of references to APIs deprecated in Android 15, even if they are never called on Android 15 at runtime.

### What is actually referenced (verified by scanning `base/dex/classes.dex` of the current AAB)

| Deprecated API | References | Where from |
|---|---|---|
| `Window.setStatusBarColor` | 1 | **Flutter engine** (`PlatformPlugin` — implements `SystemChrome.setSystemUIOverlayStyle`) |
| `Window.setNavigationBarColor` | 1 | Flutter engine (same) |
| `Window.setNavigationBarDividerColor` | 1 | Flutter engine (same) |
| `setDecorFitsSystemWindows`, `FLAG_TRANSLUCENT_*`, `getStatusBarColor`, … | 0 | not present |

Notes:

- This is the well-known Flutter issue (flutter/flutter#155922). The engine keeps these references for older Android versions; on Android 15+ they are not used to draw bars. **Every Flutter app currently gets this warning.** It is advisory and does not block release. It will disappear when a future Flutter release removes the references — nothing app-side removes it today.
- Our own Dart code is clean: the only `SystemChrome` call in `lib/` is `setPreferredOrientations` ([main.dart:100](../lib/main.dart)) — unrelated.
- **One app-side item we DO control:** the launch themes set `android:windowDrawsSystemBarBackgrounds` (deprecated window parameter in API 35) in:
  - `android/app/src/main/res/values/styles.xml`
  - `android/app/src/main/res/values-v31/styles.xml`
  - `android/app/src/main/res/values-night/styles.xml` (and night-v31)
  These lines (`forceDarkAllowed`, `windowFullscreen`, `windowDrawsSystemBarBackgrounds`, `windowLayoutInDisplayCutoutMode`) are **not** part of the stock Flutter template — someone added them. Removing `android:windowDrawsSystemBarBackgrounds` is safe (it only affected pre-15 splash rendering; default is fine for Flutter). _Not changed — read-only review; ask if you want it applied._

### Action
- Optional cleanup: delete the `windowDrawsSystemBarBackgrounds` items from the styles files.
- Otherwise: **accept the warning** for now (engine-caused, non-blocking), and it goes away with a future Flutter upgrade.

---

## Warning 1 — "Edge-to-edge may not display for all users"

- Appears for apps targeting **SDK 35+** (we target 36): Android 15 draws the app behind status/navigation bars by default, and Play warns you to verify the UI handles insets.
- Flutter **3.35.7 handles this automatically**: `MediaQuery`/`Scaffold`/`AppBar` consume insets. The codebase uses the standard structure everywhere — 297 files with `Scaffold`, 280 with `AppBar`, plus 9 explicit `SafeArea`s — so the framework manages the system bars on virtually every screen.
- Like #2, it is **advisory** — no deadline, no block.

### Action — quick visual QA on Android 15 (API 35/36) emulator or device
Check the handful of screens most likely to misbehave:
1. Screens **without an AppBar** (content could slide under the status bar).
2. Screens with **bottom-anchored buttons/inputs** (could sit under the gesture/navigation bar) — e.g. login, signature pad, chat/comment inputs, bottom sheets.
3. Full-screen viewers: PDF viewer, camera, video player.
If something overlaps a system bar, wrap that screen's body in `SafeArea` (or pad with `MediaQuery.viewPaddingOf(context)`). Fix per-screen as found; no global change needed.

---

## Recommended sequence

1. **Now:** upload the compliant AAB (145 / 1.0.142, built on Windows — or rebuild on the Mac after it passes the env check) → clears the only blocking warning (#3).
2. **Next release:** optionally remove `windowDrawsSystemBarBackgrounds` from the styles files (#2 partial) and do the 10-minute Android 15 visual pass (#1).
3. **Ongoing:** #1/#2 banners may keep appearing while the Flutter engine retains deprecated references — expected, non-blocking, gone with a future Flutter upgrade.

## Build discipline (prevents recurrence)

- Always build releases from a **committed** state — release 143's version (1.0.140) doesn't exist in git, so nobody can reproduce that build today.
- Before every Play upload, run `bash docs/check_16kb_alignment.sh <the .aab>` and require `RESULT: PASS`.
- Keep the Mac and Windows toolchains pinned to the same versions: Flutter **3.35.7**, NDK **29.0.14206865** (already pinned in `android/app/build.gradle`).
