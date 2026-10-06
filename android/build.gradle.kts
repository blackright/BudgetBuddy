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
    afterEvaluate {
        if (project.hasProperty("android")) {
            val androidExt = project.extensions.findByName("android")
            if (androidExt != null) {
                try {
                    val namespaceProp = androidExt.javaClass.getMethod("getNamespace").invoke(androidExt)
                    if (namespaceProp == null) {
                        androidExt.javaClass.getMethod("setNamespace", String::class.java).invoke(androidExt, project.group.toString())
                    }
                } catch (e: Exception) {}
                try {
                    androidExt.javaClass.getMethod("setCompileSdk", Int::class.java).invoke(androidExt, 37)
                } catch (e: Exception) {
                    try {
                        androidExt.javaClass.getMethod("setCompileSdkVersion", Int::class.java).invoke(androidExt, 37)
                    } catch (e2: Exception) {}
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
