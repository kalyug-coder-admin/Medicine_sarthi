plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

import org.gradle.api.JavaVersion

        android {
            namespace = "com.example.medi_kit"
            compileSdk = 36 // Supported max for AGP 8.13; bump to 37+ if Android 17 previews emerge

            defaultConfig {
                applicationId = "com.example.medi_kit"
                minSdk = (project.findProperty("flutter.minSdkVersion")?.toString()?.toInt() ?: 24)
                targetSdk = 36
                versionCode = (project.findProperty("flutter.versionCode")?.toString()?.toInt() ?: 1)
                versionName = project.findProperty("flutter.versionName")?.toString() ?: "1.0.0"
                multiDexEnabled = true

                // Enable exact alarms (MIUI + Android 13)
                manifestPlaceholders["androidAppUseExactAlarm"] = true
            }



            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_11
                targetCompatibility = JavaVersion.VERSION_11
                isCoreLibraryDesugaringEnabled = true
            }

            kotlinOptions {
                jvmTarget = "11"
            }

            buildTypes {
                getByName("debug") {
                    isMinifyEnabled = false
                    isShrinkResources = false
                }
                getByName("release") {
                    // Off by default to avoid the "Removing unused resources requires unused code shrinking to be turned on" error.
                    isMinifyEnabled = false
                    isShrinkResources = false
                    isDebuggable = false
                    // If you later enable shrinking/minify, set both to true and provide proguard rules.
                    // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
                }
            }

            packagingOptions {
                resources {
                    excludes += setOf("META-INF/LICENSE", "META-INF/LICENSE.txt", "META-INF/NOTICE")
                }
            }
        }

dependencies {
    // Required when isCoreLibraryDesugaringEnabled = true
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")

    implementation("androidx.multidex:multidex:2.0.1")

    // Align Kotlin stdlib versions (optional)
    implementation(platform("org.jetbrains.kotlin:kotlin-bom:2.2.20"))
}

// Flutter module root
flutter {
    source = "../.."
}