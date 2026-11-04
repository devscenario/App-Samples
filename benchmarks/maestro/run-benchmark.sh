#!/usr/bin/env bash
# One timed Maestro run of the sample regression: launch (untimed), seed the Files unit's file
# (timed, added to that unit), then screens 2-18 in one `maestro test` over regression/.
#
#   run-benchmark.sh android emulator-5554 ge.devtool.samples <out-dir>
#   run-benchmark.sh ios <simulator udid> ge.devtool.samples.ios.native <out-dir>
#
# Writes <out-dir>/junit.xml, <out-dir>/maestro.log (console), <out-dir>/artifacts/ (Maestro's own logs
# and commands.json per flow) and prints per-unit seconds plus the total.
set -euo pipefail

[ $# -eq 4 ] || { echo "usage: run-benchmark.sh android|ios <device> <app id> <out-dir>" >&2; exit 2; }
platform=$1 device=$2 app_id=$3 out=$4
here=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$out"
export MAESTRO_CLI_NO_ANALYTICS=1 MAESTRO_CLI_ANALYSIS_NOTIFICATION_DISABLED=true
export PATH="$PATH:$HOME/.maestro/bin"
adb_bin="${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools/adb"
file_name=dev-scenario-sample.txt
file_content="Dev Scenario sample file"

now_ms() { python3 -c 'import time; print(int(time.time() * 1000))'; }

if [ "$platform" = ios ]; then
  # The file picker opens where it was last left: reset it before every run, as for the other suites.
  for key in DOCUserDefaultsSceneState DOCUserDefaultsMostRecentSceneState; do
    xcrun simctl spawn "$device" defaults delete com.apple.DocumentManager.defaults \
      "$app_id-com.apple.DocumentManager.Role.Picker-$key" 2>/dev/null || true
  done
else
  # Animations off, as for the Dev Scenario and Espresso runs.
  for key in window_animation_scale transition_animation_scale animator_duration_scale; do
    "$adb_bin" -s "$device" shell settings put global "$key" 0
  done
fi

# Untimed. On the Android emulator Maestro now and then sees no app window right after a clearState
# launch (the screen shows the app): one more launch then.
maestro --device "$device" test -e APP_ID="$app_id" "$here/launch.yaml" > "$out/launch.log" 2>&1 ||
  maestro --device "$device" test -e APP_ID="$app_id" "$here/launch.yaml" > "$out/launch-retry.log" 2>&1

# pushFile (files.ds) has no Maestro command: the same copy Dev Scenario makes, timed here.
push_start=$(now_ms)
if [ "$platform" = ios ]; then
  container=$(xcrun simctl get_app_container "$device" "$app_id" data)
  mkdir -p "$container/Documents"
  printf '%s' "$file_content" > "$container/Documents/$file_name"
else
  "$adb_bin" -s "$device" shell "printf '%s' '$file_content' > /sdcard/Download/$file_name && \
    content call --uri content://media --method scan_file --arg /storage/emulated/0/Download/$file_name" > /dev/null
fi
push_ms=$(( $(now_ms) - push_start ))

# Compose Multiplatform on iOS: re-tap a tile the scroll fling swallowed, flick the sheet handle (see the README).
compose_ios=false
[ "$app_id" = ge.devtool.samples.ios ] && compose_ios=true
maestro --device "$device" test -e APP_ID="$app_id" -e COMPOSE_IOS="$compose_ios" --format junit --output "$out/junit.xml" \
  --test-output-dir "$out/artifacts" "$here/regression" > "$out/maestro.log" 2>&1 || true
[ -f "$out/junit.xml" ] || { echo "no junit.xml: see $out/maestro.log" >&2; exit 1; }

python3 - "$out/junit.xml" "$push_ms" "$platform" "$compose_ios" <<'EOF'
import sys, xml.etree.ElementTree as ET
junit, push_ms, platform, compose_ios = sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4]
cases = ET.parse(junit).getroot().iter("testcase")
units = {c.get("name"): (float(c.get("time")), c.get("status", "SUCCESS"), c.find("failure") is None) for c in cases}
# Not comparable: pinch (no pinch gesture in Maestro); on Android, the code sheet isn't in the other totals.
# On the Compose MP iOS app, modals-back too (Maestro's edge swipe doesn't trigger its back gesture).
excluded = {"pinch"} | ({"modals-code-sheet"} if platform == "android" else set()) | \
    ({"modals-back"} if compose_ios == "true" else set())
total = 0.0
for name, (secs, _, ok) in units.items():
    if name == "files":
        secs += push_ms / 1000
    mark = "" if ok else "  FAILED"
    note = "  (excluded from total)" if name in excluded else ""
    print(f"{name:20s} {secs:7.2f}{mark}{note}")
    if name not in excluded:
        total += secs
print(f"pushFile ms: {push_ms} (in files)")
print(f"passed: {sum(1 for v in units.values() if v[2])}/{len(units)}")
print(f"total (comparable units): {total:.2f}")
EOF
