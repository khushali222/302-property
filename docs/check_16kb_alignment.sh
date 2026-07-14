#!/usr/bin/env bash
#
# check_16kb_alignment.sh
# -----------------------------------------------------------------------------
# Diagnose Android 16 KB page-size compliance for a Flutter app bundle / APK.
# Works on macOS (and Linux). READ-ONLY: it never modifies your project.
#
# Usage:
#   bash docs/check_16kb_alignment.sh [path-to-.aab-or-.apk]
#
# Default artifact (run from the repo root):
#   build/app/outputs/bundle/release/app-release.aab
#
# What it does:
#   1) Prints your build environment (Flutter, NDK, git commit) so you can
#      compare the Mac against the known-good Windows machine.
#   2) Extracts the native .so libraries from the artifact and reports the
#      ELF LOAD-segment alignment of each. For 16 KB support every 64-bit
#      library (arm64-v8a, x86_64) must align to 0x4000 (16384) or higher.
# -----------------------------------------------------------------------------
set -uo pipefail

ART="${1:-build/app/outputs/bundle/release/app-release.aab}"

bold(){ printf "\033[1m"; printf "%b" "$1"; printf "\033[0m\n"; }

bold "==================================================================="
bold " 16 KB PAGE SIZE  -  BUILD ENVIRONMENT + ARTIFACT CHECK"
bold "==================================================================="

# ---------- 1. Build environment ----------
bold "\n[1] Build environment (compare with the known-good Windows machine)"
echo "--- Flutter ---"
flutter --version 2>/dev/null || echo "  flutter not on PATH"
echo "--- Dart ---"
dart --version 2>/dev/null || true

SDK="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
if [ -z "$SDK" ]; then
  # auto-detect: macOS, Windows (Git Bash), Linux default locations
  for c in "$HOME/Library/Android/sdk" "$HOME/AppData/Local/Android/Sdk" "${LOCALAPPDATA:-/nonexistent}/Android/Sdk" "$HOME/Android/Sdk"; do
    if [ -d "$c" ]; then SDK="$c"; break; fi
  done
  SDK="${SDK:-$HOME/Library/Android/sdk}"
fi
echo "--- Android SDK: $SDK ---"
echo "--- Installed NDK versions ---"
if [ -d "$SDK/ndk" ]; then ls -1 "$SDK/ndk"; else echo "  (no NDK folder at $SDK/ndk)"; fi

echo "--- Git checkout ---"
git rev-parse --short HEAD 2>/dev/null && git log -1 --oneline 2>/dev/null || echo "  (not a git repo)"
DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
echo "  uncommitted changes: ${DIRTY:-?}"

bold "\n  Expected (known-good) values:"
echo "    Flutter : 3.35.7   (must be >= 3.29 so libflutter.so / libapp.so are aligned)"
echo "    NDK     : 29.0.14206865   (must be >= r27; pinned in android/app/build.gradle)"
echo "    Commit  : the same commit you verified on Windows"

# ---------- 2. Locate readelf (from the NDK, or PATH) ----------
# Matches the macOS/Linux binary (llvm-readelf) and the Windows one (.exe),
# so this script also runs under Git Bash on Windows.
READELF=""
if [ -d "$SDK/ndk" ]; then
  for d in $(ls -1 "$SDK/ndk" 2>/dev/null | sort -r); do
    for b in "$SDK/ndk/$d"/toolchains/llvm/prebuilt/*/bin; do
      if   [ -x "$b/llvm-readelf" ];     then READELF="$b/llvm-readelf";     break 2
      elif [ -x "$b/llvm-readelf.exe" ]; then READELF="$b/llvm-readelf.exe"; break 2
      fi
    done
  done
fi
[ -z "$READELF" ] && command -v llvm-readelf >/dev/null 2>&1 && READELF="llvm-readelf"
[ -z "$READELF" ] && command -v greadelf     >/dev/null 2>&1 && READELF="greadelf"
[ -z "$READELF" ] && command -v readelf      >/dev/null 2>&1 && READELF="readelf"

# ---------- 3. Artifact alignment ----------
bold "\n[2] Artifact: $ART"
if [ ! -f "$ART" ]; then
  echo "  ERROR: artifact not found. Build it first, or pass the path as an argument."
  exit 1
fi
if [ -z "$READELF" ]; then
  echo "  ERROR: no readelf found. Install the Android NDK, or 'brew install binutils', then re-run."
  exit 1
fi
echo "  Using readelf: $READELF"

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
overall=1
found_any=0

check_abi() {
  abi="$1"; required="$2"
  rm -rf "$TMP/$abi"; mkdir -p "$TMP/$abi"
  unzip -o -j "$ART" "*/lib/$abi/*.so" "lib/$abi/*.so" -d "$TMP/$abi" >/dev/null 2>&1
  shopt -s nullglob; libs=("$TMP/$abi"/*.so); shopt -u nullglob
  [ ${#libs[@]} -eq 0 ] && { echo "  ($abi: no libraries)"; return; }
  found_any=1
  if [ -n "$required" ]; then
    bold "\n  --- $abi  (64-bit -> REQUIRED for 16 KB) ---"
  else
    bold "\n  --- $abi  (32-bit -> informational; 16 KB devices are 64-bit only) ---"
  fi
  printf "    %-40s %-10s %s\n" "LIBRARY" "ALIGN" "RESULT"
  for f in "${libs[@]}"; do
    name=$(basename "$f"); maxdec=0; maxhex="0x0"
    while read -r a; do
      [ -z "$a" ] && continue
      d=$(( a ))
      if [ "$d" -gt "$maxdec" ]; then maxdec=$d; maxhex=$a; fi
    done < <("$READELF" -l "$f" 2>/dev/null | awk '/LOAD/{print $NF}')
    if [ "$maxdec" -ge 16384 ]; then
      printf "    %-40s %-10s OK  (16 KB+)\n" "$name" "$maxhex"
    else
      printf "    %-40s %-10s FAIL (4 KB)\n" "$name" "$maxhex"
      [ -n "$required" ] && overall=0
    fi
  done
}

check_abi "arm64-v8a"   "yes"
check_abi "x86_64"      "yes"
check_abi "armeabi-v7a" ""
check_abi "x86"         ""

echo
bold "==================================================================="
if [ "$found_any" -eq 0 ]; then
  echo " WARNING: no native libraries found - is the path correct?"
elif [ "$overall" -eq 1 ]; then
  echo " RESULT: PASS - all 64-bit libraries are 16 KB-aligned. This artifact is compliant."
else
  echo " RESULT: FAIL - some 64-bit libraries are NOT 16 KB-aligned. Play will flag this."
  echo "         Fix the build environment (Flutter/NDK above) and rebuild,"
  echo "         or drop 32-bit ABIs. See docs/16KB_PAGE_SIZE_CHECK.md."
fi
bold "==================================================================="
