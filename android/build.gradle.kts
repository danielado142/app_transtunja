<<<<<<< HEAD
// Archivo: android/build.gradle.kts (Raíz del proyecto)

=======
>>>>>>> d63953f72626fa4d3a30f4bde7cb2bdcc0a42f4d
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
<<<<<<< HEAD

=======
>>>>>>> d63953f72626fa4d3a30f4bde7cb2bdcc0a42f4d
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
<<<<<<< HEAD

// Usamos solo el plugin de Google sin forzar versiones de Android
plugins {
    id("com.google.gms.google-services") version "4.4.1" apply false
}
=======
>>>>>>> d63953f72626fa4d3a30f4bde7cb2bdcc0a42f4d
