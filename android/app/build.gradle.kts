plugins {
    id("com.android.application")
    id("kotlin-android")
<<<<<<< HEAD
    // El Flutter Gradle Plugin debe aplicarse después de Android y Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
    // Activa Firebase para que funcione el SMS, Google y Facebook
    id("com.google.gms.google-services")
}

android {
    // El namespace permanece igual para no romper referencias internas
    namespace = "com.transtunja.transtunja"
=======
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.app_transtunja"
>>>>>>> d63953f72626fa4d3a30f4bde7cb2bdcc0a42f4d
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
<<<<<<< HEAD
        // IDENTIDAD: Coincide con tu configuración en Firebase Console
        applicationId = "com.transtunja.app.v2" 
        
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        
        // Versión incrementada para asegurar que el sistema note el cambio
        versionCode = 3
        versionName = "1.0.2"
=======
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.app_transtunja"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
>>>>>>> d63953f72626fa4d3a30f4bde7cb2bdcc0a42f4d
    }

    buildTypes {
        release {
<<<<<<< HEAD
            // Configuración de firma para depuración/release
=======
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
>>>>>>> d63953f72626fa4d3a30f4bde7cb2bdcc0a42f4d
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
<<<<<<< HEAD

dependencies {
    // Librerías de Redes Sociales (Facebook y Google Auth)
    implementation("com.facebook.android:facebook-android-sdk:latest.release")
    implementation("com.google.android.gms:play-services-auth:20.7.0")
    
    // Importa el BoM de Firebase para gestionar versiones automáticamente
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-auth")
}
=======
>>>>>>> d63953f72626fa4d3a30f4bde7cb2bdcc0a42f4d
