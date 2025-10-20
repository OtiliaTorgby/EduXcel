plugins {
    id("com.android.application") apply false
    id("com.android.library") apply false
    id("dev.flutter.flutter-gradle-plugin") apply false

    // FIXED: Match the required version (4.3.15)
    id("com.google.gms.google-services") version "4.3.15" apply false
}

allprojects {
    repositories {

        google()
        mavenCentral()
    }
}

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    // ... repositories
    dependencies {
        // Check for the latest version if needed, but this is standard
        classpath("com.google.gms:google-services:4.4.0") // <--- MUST BE PRESENT
        // ... other classpath dependencies
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
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
