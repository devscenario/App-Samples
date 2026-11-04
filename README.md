# Dev Scenario sample apps

https://github.com/user-attachments/assets/b765e4e2-22b0-40b5-8eeb-d0abeb5b2b80

The Compose Multiplatform sample's 18-unit regression in real time: one run, 15.2 s, on an Android emulator with
the in-app SDK and no mocked calls.

Three sample apps with the same core screens and test tags, and the [Dev Scenario](https://devscenario.com) `.ds`
flows that test them. Clone this repository, build a sample and run its flows on your own emulator or simulator.

| Folder | App | Platforms | App id |
|---|---|---|---|
| [`compose-multiplatform/`](compose-multiplatform) | Compose Multiplatform, one UI in `shared-ui` | Android, iOS | `ge.devtool.samples`, `ge.devtool.samples.ios` |
| [`swiftui/`](swiftui) | SwiftUI, with a UIKit home grid and Storyboard Login, Checkout and Profile screens | iOS | `ge.devtool.samples.ios.native` |
| [`flutter/`](flutter) | Flutter | Android, iOS | `ge.devtool.devtool_flutter_sample`, `ge.devtool.devtoolFlutterSample` |

Each folder has its own `flows/`, a Dev Scenario project whose **Sample regression** scenario launches the app
once and walks every screen. Also here:

- [`test-backend/`](test-backend): the small local server behind the **Backend** screen and its flow.
- [`benchmarks/maestro/`](benchmarks/maestro): the same regression as Maestro flows.
- The same regression as native tests: Espresso in `compose-multiplatform/android/src/androidTest`, XCUITest in
  `swiftui/UITests/Regression` and `compose-multiplatform/ios/UITests/Regression`.

The samples use the published Dev Scenario SDKs:
[`io.github.devscenario`](https://central.sonatype.com/namespace/io.github.devscenario) on Maven Central,
[app-instrumentation-ios](https://github.com/devscenario/app-instrumentation-ios) and
[httpinterceptor-ios](https://github.com/devscenario/httpinterceptor-ios) with SwiftPM,
[devscenario_app_instrumentation](https://pub.dev/packages/devscenario_app_instrumentation) and
[devscenario_httpinterceptor](https://pub.dev/packages/devscenario_httpinterceptor) on pub.dev.

## Get Dev Scenario

Download the desktop app or the `devscenario` CLI (JDK 17+) from
[the releases page](https://github.com/devscenario/releases/releases).

## Build a sample

### Compose Multiplatform

Needs JDK 17 and the Android SDK; iOS also needs Xcode on an Apple Silicon Mac and
[XcodeGen](https://github.com/yonaskolb/XcodeGen) if you change `project.yml`.

```bash
cd compose-multiplatform
./gradlew :android:installDebug
```

For iOS, build the Kotlin framework, then build the app for a specific simulator (the framework is arm64 only, so
a generic destination fails at the link step):

```bash
cd compose-multiplatform
./gradlew :shared-ui:linkDebugFrameworkIosSimulatorArm64
xcodebuild -project ios/DevToolSampleIos.xcodeproj -scheme DevToolSampleIos -destination "id=<simulator udid>" \
  -derivedDataPath build/ios CODE_SIGNING_ALLOWED=NO build
xcrun simctl install <simulator udid> build/ios/Build/Products/Debug-iphonesimulator/DevToolSampleIos.app
```

You can also open `ios/DevToolSampleIos.xcodeproj` in Xcode once the framework is built.

### SwiftUI

Needs Xcode. Open `swiftui/DevToolSampleIosNative.xcodeproj` and run it, or:

```bash
cd swiftui
xcodebuild -project DevToolSampleIosNative.xcodeproj -scheme DevToolSampleIosNative -destination "id=<simulator udid>" \
  -derivedDataPath build CODE_SIGNING_ALLOWED=NO build
xcrun simctl install <simulator udid> build/Build/Products/Debug-iphonesimulator/DevToolSampleIosNative.app
```

### Flutter

Needs the Flutter SDK (Dart 3.12 or newer).

```bash
cd flutter
flutter pub get
flutter run
```

The Flutter sample has no Files, App files, Dates or WebView screen and reads no launch arguments, so its `flows/`
leaves out the units for them: its Sample regression has 16 units instead of 18. **We haven't run this build or its flows
yet.**

## Run the flows

Install the sample on one emulator or simulator first. On iOS keep only one of the Compose and SwiftUI samples on
the simulator: both name their folder in the file picker "Dev Scenario Sample".

**In the app:** on the welcome screen choose **Import project › Folder…** and pick the sample's `flows` folder. Run
**Sample regression** from the project tree, or from Home › Regression builder.

**With the CLI**, from the repository root:

```bash
devscenario run compose-multiplatform/flows --platform android --pretty
devscenario run compose-multiplatform/flows --platform ios --pretty
devscenario run swiftui/flows --platform ios --pretty
devscenario run flutter/flows --platform android --pretty
```

The `files` unit needs an Android image with the system file picker (Google APIs or Play, Android 12+).

### Backend flow

The **Backend** scenario stays out of the regression because it needs the local server and a secret:

```bash
cd test-backend
./gradlew run
```

Set the `clientAuth` secret in **Profiles › Params**, for host `127.0.0.1`, to the Base64 of the sample's made-up
credentials `sample-client:sample-secret`. With the CLI, set `DS_SECRET_LOCAL_CLIENTAUTH` and
`DS_SECRET_LOCAL_CLIENTAUTH_HOSTS=127.0.0.1`, then add `--scenario Backend`. Everything in `test-backend/` is
test data for this local server. See its [README](test-backend/README.md).

## Run the native suites

Run them on the same device to compare with a Dev Scenario run.

```bash
cd compose-multiplatform
./gradlew :android:runAndroidTests -PtestClass=ge.devtool.samples.android.regression.SampleRegressionNativeTest
adb logcat -d -s NativeRegressionTiming:I
```

```bash
cd swiftui
xcodebuild test -project DevToolSampleIosNative.xcodeproj -scheme DevToolSampleIosNative -destination "id=<simulator udid>" \
  -only-testing:DevToolSampleIosNativeUITests/SampleRegressionUITests
```

The XCUITest run prints its timing as a `DEVSCENARIO_NATIVE_TIMING_JSON:` line. Maestro's steps and the differences
from the `.ds` flows are in [`benchmarks/maestro/README.md`](benchmarks/maestro/README.md). Published results are on
the [benchmark page](https://devscenario.com/benchmark/).

## Licence

The samples and flows in this repository are under the [MIT licence](LICENSE). The Dev Scenario SDKs they link are
separate packages under the [Dev Scenario SDK License](https://devscenario.com/legal/sdk-license/).
