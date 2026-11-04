import com.android.build.api.variant.HostTestBuilder
import javax.inject.Inject
import org.gradle.process.ExecOperations

plugins {
    alias(libs.plugins.androidApplication)
    alias(libs.plugins.composeCompiler)
    // Dev Scenario network interceptor, the published plugin. It attaches to debug build types only
    // (its default), so the release APK ships without the interceptor.
    alias(libs.plugins.devscenarioHttpInterceptorAuto)
}

// Show the Network screen's server-sent events and WebSocket messages live in Dev Scenario, where
// the interceptor plugin's version has these switches.
extensions.findByName("scenarioHttpInterceptor")?.let { ext ->
    listOf("setServerSentEvents", "setWebSockets").forEach { setter ->
        ext.javaClass.methods.firstOrNull { it.name == setter }?.invoke(ext, true)
    }
}

android {
    namespace = "ge.devtool.samples.android"
    // 37.1: the androidx Compose libraries behind Compose Multiplatform's material3 require it in
    // their AAR metadata (okhttp-android requires 37). Only what the app compiles against: targetSdk stays.
    compileSdk {
        version = release(37) { minorApiLevel = 1 }
    }

    defaultConfig {
        applicationId = "ge.devtool.samples"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }

    buildFeatures {
        compose = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // AGP's Compose Preview tasks refuse to be created without compiled resources in unit tests
    // (see also the release variant's unit tests below).
    testOptions.unitTests.isIncludeAndroidResources = true

    // Debug only: declares the in-app SDK's accessibility service, as an app adding the SDK by
    // hand does (the Gradle plugin generates the same declaration), and registers the sample's app
    // actions. Without the service the SDK can't read WebView pages, and every step on one falls
    // back to a `uiautomator dump`. The published SDK carries both since 1.0.0.
    sourceSets.getByName("debug").manifest.srcFile("sdk-debug/AndroidManifest.xml")
    sourceSets.getByName("debug").kotlin.srcDir("sdk-debug/kotlin")
}

// AGP registers Compose Preview tasks for every variant and refuses to create them for one without
// unit tests, which fails any build that realizes all tasks (`gradlew tasks`, CI's module checks).
androidComponents {
    beforeVariants(selector().withBuildType("release")) { variant ->
        variant.hostTests[HostTestBuilder.UNIT_TEST_TYPE]?.enable = true
    }
}

kotlin {
    jvmToolchain(17)
}

dependencies {
    implementation(projects.sharedUi)
    implementation(libs.androidx.activity.compose)
    // MainActivity's root Box, which turns test tags into resource ids.
    implementation(libs.compose.foundation)
    // MainActivity is an AppCompatActivity so the shared-ui language chooser's
    // AppCompatDelegate.setApplicationLocales() applies on API 24+.
    implementation(libs.androidx.appcompat)

    // Dev Scenario in-app instrumentation (F2): linked into debug builds so the
    // Dev Scenario desktop can drive the sample via the SDK's in-process WS server
    // instead of installing a UIAutomator-based driver APK. Switch the
    // inspector's "Android automation backend" to "In-app SDK" to see it in
    // action; the sample app keeps working with the other modes since
    // `releaseImplementation` does not include the SDK.
    debugImplementation(libs.devscenario.appInstrumentation)

    // OkHttp is brought in unconditionally so the SampleApplication can fire
    // the demo API calls in both debug and release variants. The auto-wire
    // plugin only attaches the devscenario interceptor to the `debug` variant
    // (the interceptor plugin's default), so release builds
    // run the same OkHttpClient unchanged.
    implementation(libs.okhttp)

    // The local WebSocket echo / SSE test server behind the Network screen's stream demos
    // (src/debug/.../streams). Debug only: release builds ship neither the server nor the library.
    debugImplementation(libs.javaWebsocket)

    // The androidTest classpath is resolved against the tested app's runtime versions (strictly).
    // The app pulls concurrent-futures 1.1.0 transitively while androidx.test.ext:junit needs
    // 1.2.0, so align the debug (tested) variant on 1.2.0; release keeps what it resolves to.
    constraints {
        debugImplementation(libs.androidx.concurrent.futures)
    }

    androidTestImplementation(libs.androidx.test.runner)
    androidTestImplementation(libs.androidx.test.extJunit)
    androidTestImplementation(libs.androidx.test.espressoCore)
    // The WebView unit's page steps (WebSteps).
    androidTestImplementation(libs.androidx.test.espressoWeb)
    androidTestImplementation(libs.androidx.test.uiautomator)
    androidTestImplementation(libs.androidx.compose.uiTestJunit4)
    debugImplementation(libs.androidx.compose.uiTestManifest)
    androidTestImplementation(libs.junit)
}

/**
 * Run instrumented tests without `connectedDebugAndroidTest`'s automatic
 * uninstall. The standard task installs both APKs, runs `am instrument`, then
 * uninstalls — that wipes the sample app between runs and forces a fresh
 * install for any subsequent manual session. This wrapper just installs and
 * invokes `am instrument` directly, leaving both APKs on the device.
 *
 *   ./gradlew :android:runAndroidTests
 *   ./gradlew :android:runAndroidTests \
 *       -PtestClass=ge.devtool.samples.android.LoginEspressoTest
 *   ./gradlew :android:runAndroidTests \
 *       -PtestClass=ge.devtool.samples.android.regression.SampleRegressionNativeTest \
 *       -PregressionUnits=launch.ds,pinch.ds
 */
abstract class RunInstrumentationTask : DefaultTask() {
    @get:Inject abstract val execOps: ExecOperations

    @get:org.gradle.api.tasks.Input abstract val target: org.gradle.api.provider.Property<String>

    @get:org.gradle.api.tasks.Input @get:org.gradle.api.tasks.Optional
    abstract val testClass: org.gradle.api.provider.Property<String>

    @get:org.gradle.api.tasks.Input @get:org.gradle.api.tasks.Optional
    abstract val regressionUnits: org.gradle.api.provider.Property<String>

    @org.gradle.api.tasks.TaskAction
    fun run() {
        val args = buildList {
            add("shell"); add("am"); add("instrument"); add("-w"); add("-r")
            if (testClass.isPresent) {
                add("-e"); add("class"); add(testClass.get())
            }
            if (regressionUnits.isPresent) {
                add("-e"); add("regressionUnits"); add(regressionUnits.get())
            }
            add(target.get())
        }
        execOps.exec {
            commandLine("adb", *args.toTypedArray())
        }
    }
}

tasks.register<RunInstrumentationTask>("runAndroidTests") {
    group = "verification"
    description = "Run Espresso tests on the connected device WITHOUT uninstalling the sample app afterwards."
    dependsOn("installDebug", "installDebugAndroidTest")
    target.set("${android.defaultConfig.applicationId}.test/${android.defaultConfig.testInstrumentationRunner}")
    (project.findProperty("testClass") as String?)?.let { testClass.set(it) }
    (project.findProperty("regressionUnits") as String?)?.let { regressionUnits.set(it) }
}
