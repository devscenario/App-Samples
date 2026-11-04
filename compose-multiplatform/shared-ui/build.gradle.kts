plugins {
    alias(libs.plugins.kotlinMultiplatform)
    alias(libs.plugins.composeMultiplatform)
    alias(libs.plugins.composeCompiler)
    alias(libs.plugins.androidKotlinMultiplatformLibrary)
}

kotlin {
    jvmToolchain(17)

    // AGP 9: KMP modules declare their Android target here instead of applying
    // `com.android.library` plus a top-level `android { }` block.
    androidLibrary {
        namespace = "ge.devtool.samples.sharedui"
        // 37.1: the androidx Compose libraries behind Compose Multiplatform's material3 require it in
        // their AAR metadata (okhttp-android requires 37).
        compileSdk {
            version = release(37) { minorApiLevel = 1 }
        }
        minSdk = 24
        // The login screen's texts are Android string resources (src/androidMain/res).
        androidResources.enable = true
        // Runs commonTest on the JVM (`testAndroidHostTest`): the iOS test binaries need an Xcode
        // toolchain that not every machine has.
        withHostTest {}
    }

    // No iosX64: Compose Multiplatform stopped publishing that target as of 1.11,
    // so the Intel iOS simulator can no longer be built. Apple Silicon simulators
    // use iosSimulatorArm64.
    listOf(
        iosArm64(),
        iosSimulatorArm64()
    ).forEach { target ->
        target.binaries.framework {
            baseName = "SampleSharedUi"
            isStatic = true
        }
    }

    sourceSets {
        commonMain.dependencies {
            implementation(libs.compose.runtime)
            implementation(libs.compose.foundation)
            implementation(libs.compose.material3)
            implementation(libs.compose.materialIconsExtended)
            implementation(libs.compose.ui)
            implementation(libs.compose.uiToolingPreview)
            implementation(libs.kotlinx.coroutinesCore)
        }
        // The Android `actual` of `demoHttpCall` (see DemoHttp.android.kt) is
        // built on OkHttp specifically so the consuming android-app's
        // `io.github.devscenario.httpinterceptor.auto` plugin can ASM-instrument the
        // `OkHttpClient.Builder.build()` call inside this module too. The iOS
        // `actual` (DemoHttp.ios.kt) uses NSURLSession directly so no extra
        // iosMain dep is needed.
        androidMain.dependencies {
            implementation(libs.okhttp)
            // The Network screen's SSE demo (DemoStreams.android.kt) reads its stream with
            // okhttp-sse's EventSources, on the same interceptor-wired OkHttpClient.
            implementation(libs.okhttp.sse)
            // SampleLocaleController (Android actual) drives the AndroidX
            // per-app locale via AppCompatDelegate.setApplicationLocales — the
            // platform-recommended in-app language switch, and exactly what the
            // devtool reads back via `cmd locale get-app-locales`. The OS
            // persists the choice (no custom preference key needed) and brings
            // in androidx.core (LocaleListCompat) transitively. Requires the
            // host Activity to be an AppCompatActivity (see compose-multiplatform/android).
            implementation(libs.androidx.appcompat)
            // FilesScreen's picker: rememberLauncherForActivityResult(OpenDocument).
            implementation(libs.androidx.activity.compose)
        }
        commonTest.dependencies {
            implementation(libs.kotlin.test)
            implementation(libs.kotlinx.coroutinesTest)
        }
    }
}

