import java.util.Properties
import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.github.sidharthbabani03_bot.companion" // Make sure this matches your app's namespace
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        applicationId = "com.github.sidharthbabani03_bot.companion" // Make sure this matches your app's ID
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // This section loads your key.properties file
    // Ensure key.properties is in your android/ directory
    val keystorePropertiesFile = rootProject.file("key.properties") // rootProject here refers to the 'android' dir
    val keystoreProperties = Properties() // CORRECT: Uses the imported java.util.Properties

    if (keystorePropertiesFile.exists() && keystorePropertiesFile.isFile) {
        keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
        println("Successfully loaded key.properties from: ${keystorePropertiesFile.absolutePath}")
    } else {
        println("WARNING: key.properties file not found at ${keystorePropertiesFile.absolutePath}. Signing will likely fail. Please ensure it exists and contains the correct signing information.")
    }

    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties.getProperty("storeFile")
            val storePasswordValue = keystoreProperties.getProperty("storePassword")
            val keyAliasValue = keystoreProperties.getProperty("keyAlias")
            val keyPasswordValue = keystoreProperties.getProperty("keyPassword")

            if (storeFilePath == null) {
                throw GradleException("ERROR: Missing 'storeFile' property in key.properties. Please ensure it is defined in ${keystorePropertiesFile.absolutePath}")
            }
            if (storePasswordValue == null) {
                throw GradleException("ERROR: Missing 'storePassword' property in key.properties. Please ensure it is defined in ${keystorePropertiesFile.absolutePath}")
            }
            if (keyAliasValue == null) {
                throw GradleException("ERROR: Missing 'keyAlias' property in key.properties. Please ensure it is defined in ${keystorePropertiesFile.absolutePath}")
            }
            if (keyPasswordValue == null) {
                throw GradleException("ERROR: Missing 'keyPassword' property in key.properties. Please ensure it is defined in ${keystorePropertiesFile.absolutePath}")
            }

            // keystorePropertiesFile is a File object (due to rootProject.file(...))
            // storeFilePath should be a non-null String here (due to the check above)
            // resolveSibling takes a String and returns a File
            val actualKeystoreFile = keystorePropertiesFile.resolveSibling(storeFilePath!!) // Use non-null assertion
            if (!actualKeystoreFile.exists()) {
                throw GradleException("ERROR: Keystore file not found at path resolved from storeFile: ${actualKeystoreFile.absolutePath}. Check storeFile in ${keystorePropertiesFile.absolutePath} (it should be relative to the android/ directory, e.g., ../app/your-keystore.jks if key.properties is in android/ and keystore is in app/).")
            }

            println("Using keystore file: ${actualKeystoreFile.absolutePath}")
            storeFile = actualKeystoreFile // This actualKeystoreFile is a File object
            storePassword = storePasswordValue
            keyAlias = keyAliasValue
            keyPassword = keyPasswordValue
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        // debug {
        //     // Your debug configurations, if any
        // }
    }
    packagingOptions {
        // Add any existing packagingOptions here if you have them
    }
}

flutter {
    source = "../.."
}

dependencies {
    // You might have other dependencies here, leave them if they exist.
    // Example: implementation("androidx.core:core-ktx:1.9.0")
}
