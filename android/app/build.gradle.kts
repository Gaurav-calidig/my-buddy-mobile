plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.calidig.mybuddy"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
        }
    }

    // Helper to read .env file
    fun getEnvValue(key: String): String {
        val envFile = file("../../.env")
        if (envFile.exists()) {
            val lines = envFile.readLines()
            for (line in lines) {
                if (line.trim().startsWith("$key=")) {
                    return line.substringAfter("=").trim().removeSurrounding("\"").removeSurrounding("'")
                }
            }
        }
        return ""
    }
    val googleMapsApiKey = getEnvValue("GOOGLE_MAPS_API_KEY")

    defaultConfig {
        applicationId = "com.calidig.mybuddy"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["appLabel"] = "My Buddy"

        // Pass the API key to AndroidManifest
        manifestPlaceholders["googleMapsApiKey"] = googleMapsApiKey
    }

    // flavorDimensions += "brand"

    // productFlavors {
    //     create("mybuddy") {
    //         dimension = "brand"
    //         applicationId = "com.calidig.mybuddy"
    //         manifestPlaceholders["appLabel"] = "My Buddy"
    //     }
    //     create("brandA") {
    //         dimension = "brand"
    //         applicationId = "com.example.branda"
    //         manifestPlaceholders["appLabel"] = "Brand A"
    //     }
    //     create("brandB") {
    //         dimension = "brand"
    //         applicationId = "com.example.brandb"
    //         manifestPlaceholders["appLabel"] = "Brand B"
    //     }
    // }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false

            ndk {
                abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64")
            }
        }

    }
    lint {
        checkReleaseBuilds = false
        abortOnError = false
    }
}

dependencies {
    // Required for core library desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // Add any other dependencies here later
}

flutter {
    source = "../.."
}
