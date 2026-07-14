# 16 KB Page Size — Verification Report & Mac Check Guide

_Generated 2026-06-11. This is a **read-only diagnostic** — no app code was changed._

---

## TL;DR

- ✅ The build produced **on Windows** is **16 KB-compliant** for the ABIs that matter (verified — see §2).
- ❌ The AAB you **built on your Mac and published** got the Play Console 16 KB warning.
- 👉 The alignment of the published `.aab` depends on **the machine that built it** — its Flutter SDK and its NDK. So the Mac toolchain (or an older artifact still live in Play) is the cause, **not the repo config**.
- 🛠️ On your Mac: run `bash docs/check_16kb_alignment.sh`. It prints your Mac's Flutter/NDK versions **and** checks the AAB's native libraries. Compare against the known-good values below, fix the environment, rebuild, re-check, then upload.

---

## 1. What "16 KB compliant" actually means

- Android devices with a **16 KB memory page size are 64-bit only**. So Google Play's 16 KB check looks **only at the 64-bit native libraries** in your app: `arm64-v8a` and `x86_64`.
- A library passes when every `LOAD` segment in the `.so` is aligned to **`0x4000` (16384 = 16 KB)** or higher. `0x1000` (4 KB) **fails**.
- 32-bit libraries (`armeabi-v7a`, `x86`) are **not** evaluated for 16 KB — those devices don't have 16 KB pages.

---

## 2. Known-good reference (verified on Windows, versionCode 145)

Every 64-bit library in the Windows-built `app-release.aab` is aligned:

| Library (source)                         | arm64-v8a | x86_64  | armeabi-v7a (32-bit) |
|------------------------------------------|-----------|---------|----------------------|
| libapp.so (Flutter/Dart)                 | ✅ 0x10000 | ✅ 0x10000 | ✅ 0x4000 |
| libflutter.so (Flutter engine)           | ✅ 0x10000 | ✅ 0x10000 | ✅ 0x10000 |
| libc++_shared.so (NDK runtime)           | ✅ 0x4000  | ✅ 0x4000  | ❌ 0x1000 |
| libdatastore_shared_counter.so           | ✅ 0x4000  | ✅ 0x4000  | ✅ 0x4000 |
| libimage_processing_util_jni.so (CameraX)| ✅ 0x4000  | ✅ 0x4000  | ✅ 0x4000 |
| libsurface_util_jni.so (CameraX)         | ✅ 0x4000  | ✅ 0x4000  | ✅ 0x4000 |
| libjniPdfium.so (flutter_pdfview)        | ✅ 0x4000  | ✅ 0x4000  | ❌ 0x1000 |
| libmodft2.so (flutter_pdfview)           | ✅ 0x4000  | ✅ 0x4000  | ❌ 0x1000 |
| libmodpdfium.so (flutter_pdfview)        | ✅ 0x4000  | ✅ 0x4000  | ❌ 0x1000 |
| libmodpng.so (flutter_pdfview)           | ✅ 0x4000  | ✅ 0x4000  | ❌ 0x1000 |

**64-bit = 100% aligned → compliant.** The only unaligned libs are 32-bit (the NDK runtime + the pdfium libs from `flutter_pdfview 1.4.3`, pulled in by `flutter_cached_pdfview 0.4.3`), which 16 KB devices never load.

**Known-good build environment (Windows):**

| Thing   | Value                                  | Why it matters |
|---------|----------------------------------------|----------------|
| Flutter | **3.35.7** (stable)                    | `libflutter.so` & `libapp.so` are only 16 KB-aligned on Flutter **≥ 3.29** |
| NDK     | **29.0.14206865** (pinned in `android/app/build.gradle`) | Must be **≥ r27** so NDK-built libs are aligned |
| AGP     | 8.6 / 8.7                              | Handles 16 KB zip-alignment when packaging |

---

## 3. Run the checker on your Mac

From the project root:

```bash
bash docs/check_16kb_alignment.sh
```

Check a specific file instead of the default:

```bash
bash docs/check_16kb_alignment.sh build/app/outputs/bundle/release/app-release.aab
# or the exact .aab you uploaded to Play, or an .apk
```

The script needs `llvm-readelf`, which ships with the Android NDK (it auto-detects it under `~/Library/Android/sdk/ndk/...`). If you don't have the NDK, `brew install binutils` also works.

> **Get the script onto the Mac first.** Either commit & push these two files from Windows and `git pull` on the Mac, or just copy `docs/check_16kb_alignment.sh` and `docs/16KB_PAGE_SIZE_CHECK.md` over.

---

## 4. How to read the result

- The script prints your Mac's **Flutter / NDK / git commit**, then a per-library table for each ABI.
- Final line:
  - `RESULT: PASS` → the artifact is 16 KB-compliant; safe to upload.
  - `RESULT: FAIL` → at least one **64-bit** lib is 4 KB-aligned; Play will flag it. Look at which library failed and at the environment section to see why.

---

## 5. Root-cause checklist — why the Mac build was flagged

Go down this list on the Mac:

| # | Check | Bad sign | Fix |
|---|-------|----------|-----|
| 1 | `flutter --version` | **< 3.29** (e.g. 3.24, 3.22) → `libflutter.so` / `libapp.so` are 4 KB-aligned | `flutter upgrade` to **3.35.7** (match Windows) |
| 2 | Installed NDK (`ls ~/Library/Android/sdk/ndk`) | **29.0.14206865 missing**, or an old `< r27` NDK was used | Install NDK `29.0.14206865` via Android Studio → SDK Manager → SDK Tools → "Show Package Details" |
| 3 | `git log -1 --oneline` | Mac is on an **older commit** than Windows (built before the alignment was in place) | `git pull` so the Mac matches the verified commit |
| 4 | `git status` | Local edits to `android/app/build.gradle` / `gradle.properties` changing NDK | Reset to the committed config |
| 5 | Stale build cache | An old artifact got re-zipped | `flutter clean` before building (see §6) |
| 6 | **Play Console** | The flagged release is an **older versionCode** than your fixed build | Just upload the new compliant AAB and roll it out — the warning is tied to the live artifact, not your code |

> The single most common cause of "compliant on one machine, flagged on another" is **#1 — a different Flutter version**. If the Mac is on Flutter < 3.29, the engine libraries themselves are 4 KB-aligned no matter what the plugins do.

---

## 6. The fix (on the Mac)

```bash
# 1. Match the known-good environment
flutter --version          # want 3.35.x; if older:
flutter upgrade
#   Android Studio > SDK Manager > SDK Tools > NDK (Side by side) > 29.0.14206865

# 2. Make sure you're on the same commit as Windows
git pull

# 3. Clean rebuild
flutter clean
flutter pub get
flutter build appbundle --release

# 4. Verify BEFORE uploading
bash docs/check_16kb_alignment.sh
#   -> must print RESULT: PASS

# 5. Upload the new AAB to Play Console and roll it out.
```

### Optional belt-and-suspenders — drop 32-bit ABIs

If you want zero ambiguity (or the Play warning explicitly lists `armeabi-v7a`/32-bit `.so` files), stop shipping 32-bit libraries. The pdfium 32-bit prebuilts can't be re-aligned by us, and 16 KB devices never use them. In `android/app/build.gradle` → `defaultConfig`:

```gradle
ndk {
    abiFilters 'arm64-v8a', 'x86_64'
}
```

This removes the only unaligned libraries entirely and shrinks the app. Trade-off: drops the last 32-bit-only devices — negligible today given `minSdk 26`. _(Not applied here — this guide is read-only. Ask if you want it done.)_

---

## 7. Manual checks (no script)

**Easiest (GUI):** Android Studio → **Build → Analyze APK…** → pick the `.aab`/`.apk`. Recent versions show 16 KB alignment status per library.

**One library at a time (CLI):**

```bash
# extract a 64-bit lib from the AAB
unzip -o -j build/app/outputs/bundle/release/app-release.aab \
  "base/lib/arm64-v8a/libmodpdfium.so" -d /tmp/so

# read its program headers; the LOAD "Align" column must be 0x4000 or higher
"$HOME/Library/Android/sdk/ndk/29.0.14206865/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-readelf" \
  -l /tmp/so/libmodpdfium.so | grep LOAD
```

**Google's official script** (also checks zip-alignment for APKs):

```bash
curl -O https://android.googlesource.com/platform/system/extras/+/refs/heads/main/tools/check_elf_alignment.sh?format=TEXT
# decode/save it, then: bash check_elf_alignment.sh path/to/app.apk
```

> Note: an `.aab` stores libs compressed and Play re-packages them into APKs, so for an AAB the **ELF segment alignment** (what this guide checks) is the meaningful signal. The zip-alignment check applies to the final APK, which Play generates for you.

---

## 8. Side note — minor config inconsistencies (not the cause)

- **NDK declared twice:** `android/app/build.gradle` pins `29.0.14206865` (this one wins); `android/gradle.properties` has `android.ndkVersion=28.0.12433566`. Both are ≥ r27, so output is fine — but it's confusing and worth reconciling.
- **AGP declared twice:** `android/build.gradle` buildscript uses `8.7.0`; `android/settings.gradle` plugins block uses `8.6.0`. Both ≥ 8.5.1, so 16 KB zip-alignment is handled either way.
