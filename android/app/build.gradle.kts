plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.adarshkumarverma.wishperlog"
    compileSdk = maxOf(flutter.compileSdkVersion, 35)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.adarshkumarverma.wishperlog"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = maxOf(flutter.targetSdkVersion, 35)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Values are read from gradle.properties (local, never committed to VCS).
            // See MANUAL CONFIGURATION section for setup instructions.
            val storeFilePath = System.getenv("WISHPERLOG_STORE_FILE")
                ?: project.findProperty("WISHPERLOG_STORE_FILE") as String?
            val storePassword = System.getenv("WISHPERLOG_STORE_PASSWORD")
                ?: project.findProperty("WISHPERLOG_STORE_PASSWORD") as String?
            val keyAlias = System.getenv("WISHPERLOG_KEY_ALIAS")
                ?: project.findProperty("WISHPERLOG_KEY_ALIAS") as String?
            val keyPassword = System.getenv("WISHPERLOG_KEY_PASSWORD")
                ?: project.findProperty("WISHPERLOG_KEY_PASSWORD") as String?

            if (storeFilePath != null) {
                storeFile     = file(storeFilePath)
                this.storePassword = storePassword ?: ""
                this.keyAlias     = keyAlias      ?: ""
                this.keyPassword  = keyPassword   ?: ""
            }
        }
    }

    buildTypes {
        release {
            // Use release signing when keys are available; fall back to debug for
            // local `flutter run --release` during development.
            val hasReleaseSigning = signingConfigs.findByName("release")
                ?.storeFile?.exists() == true
            signingConfig = if (hasReleaseSigning)
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.localbroadcastmanager:localbroadcastmanager:1.1.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
