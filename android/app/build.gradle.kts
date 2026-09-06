import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

android {
    namespace = "com.domai_tb.openplants"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Flag to enable support for the new language APIs
        isCoreLibraryDesugaringEnabled = true
        // Sets Java compatibility to Java 11
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Application ID: https://developer.android.com/studio/build/application-id.html
        applicationId = "com.domai_tb.openplants"
        
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Add the Dart define flag for Cronet HTTP without Play Services
        applicationVariants.all { 
            mergedFlavor.manifestPlaceholders["cronetHttpNoPlay"] = "true"
        }
    }

    if (keystorePropertiesFile.exists()) {
        signingConfigs {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as? String
                keyPassword = keystoreProperties["keyPassword"] as? String
                storeFile = keystoreProperties["storeFile"]?.toString()?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as? String
            }
        }
    }

    buildTypes {
        release {
            // Use signing config only when key.properties is present (local dev).
            // F-Droid and CI builds produce an unsigned APK without signing material.
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }

            isMinifyEnabled = true
            isShrinkResources = true

            // preserve entire Flutter wrapper code
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:2.2.10")
    implementation("androidx.appcompat:appcompat:1.7.1")
    implementation("androidx.appcompat:appcompat-resources:1.7.1")

    // `desugar_jdk_libs` is a core Android development library that 
    // enables you to use modern Java features and APIs in your app 
    // even on older Android devices with lower API levels. 
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")

    // Keep Android config minimal; avoid unnecessary Play Services requirements.
    //
    // The Dio packages uses [cronet_http] libary to perform network requests. 
    // At default, this libary depends on Google Play services instead of 
    // of the embedded version of Cronet. Setting the embedded version (based on
    // native libaries) here will remove the dependency on Google Play services.
    //
    // Note: https://github.com/cfug/dio/issues/2042
    // Note: https://github.com/dart-lang/http/blob/master/pkgs/cronet_http/android/build.gradle
    // Note: https://mvnrepository.com/artifact/org.chromium.net/cronet-embedded
    //
    implementation("org.chromium.net:cronet-embedded:119.6045.31")
}
