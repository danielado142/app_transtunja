plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // El namespace debe permanecer igual para no romper las referencias de Java/Kotlin
    namespace = "com.transtunja.transtunja"
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
        // NUEVA IDENTIDAD: Esto soluciona el error "No se ha instalado la aplicación"
        applicationId = "com.transtunja.app.v2" 
        
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        
        // Versión incrementada para asegurar que el sistema note el cambio
        versionCode = 3
        versionName = "1.0.2"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// Activa Firebase para que funcione el SMS y desaparezca la pantalla negra
apply(plugin = "com.google.gms.google-services")