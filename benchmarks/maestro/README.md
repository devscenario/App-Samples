# Sample regression in Maestro (benchmark)

The **Sample regression** (`../../compose-multiplatform/flows/samples/scenarios/Sample regression.scenario.json`, 18 units) as
Maestro flows, for the Maestro column of the `/benchmark/` page. Each flow mirrors one `.ds` unit: the same
screens, actions, checks and order, with the unit's Android or iOS path where it has `if (platform == …)` blocks.
Like the Dev Scenario run and the native suites, it launches the app once and
times screens 2–18.

| File | Unit |
|---|---|
| `launch.yaml` | `launch.ds`: `launchApp` with `clearState`, run on its own before the timer |
| `regression/01-login.yaml` … `17-webview.yaml` | the 17 timed units, in scenario order (`regression/config.yaml`) |
| `regression/subflows/` | per-platform parts: drag coordinates, the iOS file picker |
| `run-benchmark.sh` | one timed run: launch, seed the file, the 17 flows, per-unit seconds |

## Running

Needs the Maestro CLI (`curl -Ls "https://get.maestro.mobile.dev" | bash`, Java 17+); measured with **Maestro
2.12.0**. One device, the sample installed, and on iOS only one of the two iOS samples (both name their picker
folder "Dev Scenario Sample"). Maestro's iOS driver listens on port 22087, as Dev Scenario's WDA runner does:
stop that runner first.

```bash
benchmarks/maestro/run-benchmark.sh android emulator-5554 ge.devtool.samples /tmp/maestro-android
benchmarks/maestro/run-benchmark.sh ios <udid> ge.devtool.samples.ios /tmp/maestro-compose      # Compose MP
benchmarks/maestro/run-benchmark.sh ios <udid> ge.devtool.samples.ios.native /tmp/maestro-swiftui
```

The flows take the app id from `APP_ID` and the Compose MP iOS switch from `COMPOSE_IOS` (`true` for
`ge.devtool.samples.ios`, `false` otherwise): a run by hand passes both (`maestro test -e APP_ID=… -e COMPOSE_IOS=false
launch.yaml`, then `… regression`). The script also:

- Android: sets the three animation scales to 0, as Dev Scenario's driver session does (the Espresso run had them
  off too). It doesn't restore them.
- iOS: resets the system file picker's remembered place before the run, as for the other suites
  (`defaults delete com.apple.DocumentManager.defaults "<bundle id>-com.apple.DocumentManager.Role.Picker-…"`).
- Seeds `devtool-sample.txt` after the launch (see *Differences*) and adds that time to the `files` unit.

Per-unit time is each flow's `time` in Maestro's JUnit report (`--format junit`): the flows run back to back in
one `maestro test` call, in the app `launch.yaml` left open (no flow launches or stops the app). The total adds
up the comparable units. Maestro's own logs and `commands.json` per flow land in `<out>/artifacts/`.

## Differences from the Dev Scenario flows

Maestro selectors are regexes matched against the whole text, so texts with `$ . ( )` are escaped and
`contains("…")` is `.*…*`. Otherwise:

- **pinch: not comparable.** Maestro has no pinch (multi-touch) command. The flow opens the screen and goes back;
  the two pinches and their checks are left out, and the unit is left out of the total.
- **drag-drop:** Maestro can't drag one element onto another; each drag is a `swipe` between fixed points (the two
  elements' centres on the benchmark devices: 1080×2400 Android, 402×874 pt iPhone 17 Pro). Android: 150 ms per
  drag, as a 40 ms Maestro swipe isn't picked up as a drag there; iOS: 40 ms, as in the flow.
- **files:** `pushFile` has no Maestro command. `run-benchmark.sh` makes the same copy right after the launch:
  Android `adb shell` writing into Downloads plus MediaProvider's `scan_file`; iOS a copy into the app's Documents
  folder (`simctl get_app_container`). Its time is added to the `files` unit.
- **modals-back on the Compose MP iOS app: not comparable.** No Maestro swipe from the left edge (start at 0–2%
  of the width, 50–300 ms) triggers that app's back gesture, which Compose handles itself. The flow taps the Back
  button there instead (so the next units start on the home screen) and the unit is left out of that app's total.
- **modals-back on iOS:** Maestro's `back` is Android only. iOS uses the same left-edge swipe Dev Scenario's `back`
  makes (edge to 60% of the width, 100 ms).
- **Back buttons:** `tap("Back")` is `tapOn: {id: "BackButton"}`: the text "Back" also matches the Android
  keyboard's Back key, which Maestro picked while the keyboard was up. Both samples tag the back button
  `BackButton` (UIKit's own identifier on iOS).
- **registration:** Maestro sees on-screen elements only. On Android the success line sits under the keyboard and
  the form fits the screen, so it can't be scrolled into view: a `hideKeyboard` comes before that check
  (Android only; on iOS the line is on screen, and Maestro's `hideKeyboard` fails on these fields).
- **modals-code-sheet:** the flow targets the code field and the button by test tag. On Android the sheet is its
  own window, without the activity's `testTagsAsResourceId`, so Maestro has no ids there: it taps their labels
  ("SMS code", "Verify") on both platforms.
- **Scrolls and swipes** use Maestro's defaults (`scrollUntilVisible` speed 40, 400 ms swipes). The flows'
  `maxScrolls`/`duration` options have no Maestro equivalent; `scrollUntilVisible` stops on its own timeout.
- **Compose Multiplatform on iOS** (`COMPOSE_IOS=true`, set by `run-benchmark.sh` for `ge.devtool.samples.ios`):
  - a home tile's tap that didn't open its screen within 1.5 s is repeated once (`subflows/retap-tile.yaml`): the
    grid's scroll flings on outside XCTest's idle wait, and a tap during the fling only stops it. A
    `waitForAnimationToEnd` after the scroll, also with slower scrolls (speed 15 and 5), still lost a tap in full
    runs. When the first tap lands this costs nothing; a lost tap costs Maestro the 1.5 s and the second tap,
    and most are lost (8 of 9 in a warm-up run). The native XCUITest suite waits for the target to stop moving
    there instead.
  - the full sheet's drag-handle swipe is a 50 ms flick between fixed points (the handle at 10% of the height to
    95%): Maestro's swipe from the handle element left the sheet half open, at its default 400 ms and at 100 ms.
    The native suite flicks this drag too (0.1 s). Android and the SwiftUI app keep Maestro's default swipe from
    the handle, which dismissed the sheet there.
- **Taps** use Maestro's defaults. `retryTapIfNoChange: false` with `waitToSettleTimeoutMs: 0` on every tap gave
  no steady gain on Android (login 17.2 / 20.7 s vs 21.1 / 21.3 s), so the flows don't set them.

## Measured (October 2026)

Maestro 2.12.0, Apple M4 Pro; Android emulator `bench34` (API 34, host GPU), iPhone 17 Pro simulator (iOS 26.2).
Seconds per flow in the faster measured run (Files includes the seeded file's copy). Totals leave out Pinch, and on
Android the modal code sheet, as the page's Android totals do.

| Unit | Android | iOS SwiftUI |
|---|---|---|
| login | 19.6 | 14.7 |
| registration | 23.3 | 15.5 |
| checkout | 13.2 | 10.4 |
| grid | 5.4 | 7.0 |
| list | 5.4 | 9.3 |
| search | 11.2 | 10.1 |
| profile | 11.0 | 10.8 |
| showcase | 7.6 | 11.7 |
| pinch (not comparable) | 3.3 | 5.4 |
| drag-drop | 8.3 | 11.5 |
| modals | 23.5 | 21.1 |
| modals-swipes | 12.2 | 12.0 |
| modals-back | 11.3 | 5.3 |
| modals-code-sheet | 10.6 (not in total) | 11.1 |
| network | 9.3 | 8.2 |
| files | 11.8 | 21.8 |
| webview | 45.4 | 26.5 |
| **Total** | **218.5** (other run 222.2) | **206.8** (other run 214.7) |

The Compose Multiplatform iOS app isn't measured yet: its flows pass (warm-up 17/17), but the host stayed under
heavy outside load (load average 12–95) for the rest of the session.
