plugins {
    id("com.android.application")
    id("kotlin-android")
    // El plugin de Flutter
    id("dev.flutter.flutter-gradle-plugin")
    // --- ESTA ES LA LÍNEA QUE FALTABA PARA FIREBASE ---
    id("com.google.gms.google-services")
}

android {
    // Coincide con tu JSON: com.transtunja.app.v2
    namespace = "com.transtunja.app.v2"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Coincide con tu JSON: com.transtunja.app.v2
        applicationId = "com.transtunja.app.v2"
        
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}