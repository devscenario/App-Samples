// Sample test backend: a small in-memory HTTP server the sample apps sign in against and that
// flows query for test data (tokens, user search, order status). A test tool, not shipped.
plugins {
    alias(libs.plugins.kotlinJvm)
    alias(libs.plugins.kotlinSerialization)
    application
}

application {
    mainClass.set("ge.devtool.samples.backend.MainKt")
}

kotlin {
    jvmToolchain(17)
}

dependencies {
    implementation(libs.logback)
    implementation(libs.ktor.serverCore)
    implementation(platform(libs.netty.bom))
    implementation(libs.ktor.serverNetty) { exclude(group = "io.netty", module = "netty-codec-native-quic") } // no HTTP/3
    implementation(libs.ktor.serverContentNegotiation)
    implementation(libs.ktor.serializationKotlinxJson)
    implementation(libs.kotlinx.serializationJson)
    testImplementation(libs.ktor.serverTestHost)
    testImplementation(libs.kotlin.testJunit)
}
