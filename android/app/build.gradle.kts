plugins {
    id("com.android.application")
    id("kotlin-android")
    // El Flutter Gradle Plugin debe aplicarse después de Android y Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
    // Activa Firebase para que funcione el SMS, Google y Facebook
    id("com.google.gms.google-services")
}

android {
    // El namespace permanece igual para no romper referencias internas
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
        // IDENTIDAD: Coincide con tu configuración en Firebase Console
        applicationId = "com.transtunja.app.v2" 
        
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        
        // Versión incrementada para asegurar que el sistema note el cambio
        versionCode = 3
        versionName = "1.0.2"
    }

    buildTypes {
        release {
            // Configuración de firma para depuración/release
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Librerías de Redes Sociales (Facebook y Google Auth)
    implementation("com.facebook.android:facebook-android-sdk:latest.release")
    implementation("com.google.android.gms:play-services-auth:20.7.0")
    
    // Importa el BoM de Firebase para gestionar versiones automáticamente
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-auth")
}