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
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val configureAndroid = { proj: Project ->
        if (proj.hasProperty("android")) {
            val android = proj.extensions.findByName("android")
            if (android != null) {
                proj.configure<com.android.build.gradle.BaseExtension> {
                    compileOptions {
                        sourceCompatibility = JavaVersion.VERSION_17
                        targetCompatibility = JavaVersion.VERSION_17
                    }
                }
            }
            val hasKotlin = proj.plugins.hasPlugin("kotlin-android") || proj.plugins.hasPlugin("org.jetbrains.kotlin.android")
            if (hasKotlin) {
                proj.tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
                    kotlinOptions {
                        jvmTarget = "17"
                    }
                }
            }
        }
    }
    if (project.state.executed) {
        configureAndroid(project)
    } else {
        project.afterEvaluate {
            configureAndroid(project)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
