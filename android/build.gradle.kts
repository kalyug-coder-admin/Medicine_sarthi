// android/build.gradle.kts
import org.gradle.api.tasks.Delete

// Keep project-level repositories for older Gradle plugin compatibility
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: relocate build outputs (remove if you don't want this)
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)
subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
