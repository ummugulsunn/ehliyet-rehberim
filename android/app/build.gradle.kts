import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Add Google Services plugin
    id("com.google.gms.google-services")
}

// Load keystore properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    println("Warning: key.properties file not found!")
}

android {
    namespace = "com.ehliyetrehberim.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Auto versioning helpers
    val autoVersionCode: Int = System.getenv("BUILD_NUMBER")?.toIntOrNull()
        ?: (System.currentTimeMillis() / 1000L).toInt()
    val autoVersionName: String = System.getenv("BUILD_NAME") ?: flutter.versionName

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.ehliyetrehberim.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Use a conservative minSdk to maximize device support
        minSdk = flutter.minSdkVersion
        // Ensure both 32-bit and 64-bit ABIs are supported for wider device coverage
        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a")
        }
        targetSdk = flutter.targetSdkVersion
        versionCode = autoVersionCode
        versionName = autoVersionName
    }
    
    // Custom launcher icon configuration
    sourceSets {
        getByName("main") {
            res.srcDirs("src/main/res")
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String? ?: "ehliyet-rehberim"
            keyPassword = keystoreProperties["keyPassword"] as String? ?: "ehliyet123"
            storeFile = keystoreProperties["storeFile"]?.let { file(it) } ?: file("ehliyet-rehberim-key.jks")
            storePassword = keystoreProperties["storePassword"] as String? ?: "ehliyet123"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring for flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

