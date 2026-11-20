plugins {
    kotlin("jvm") version "2.3.21"
    // PIT(Pitest)を Gradle から実行するプラグイン。`./gradlew pitest` タスクが追加される
    id("info.solidsoft.pitest") version "1.19.0"
}

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(kotlin("test"))
    testImplementation(platform("org.junit:junit-bom:5.11.4"))
    testImplementation("org.junit.jupiter:junit-jupiter")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

kotlin {
    jvmToolchain(21)
}

tasks.test {
    useJUnitPlatform()
}

pitest {
    pitestVersion.set("1.17.4")
    junit5PluginVersion.set("1.2.1")
    targetClasses.set(setOf("grade.*"))
    outputFormats.set(setOf("HTML", "XML"))
    timestampedReports.set(false)
    threads.set(2)

    // --- Step2 で追加した設定 ---
    // 使うミューテーター群。DEFAULTS < STRONGER < ALL の順に変異の種類が増える
    mutators.set(setOf("STRONGER"))
    // 殺せたミュータントの割合(mutation score)がこれ未満なら pitest タスクを失敗させる(CIゲート用)
    mutationThreshold.set(80)
    // 変異させたくないクラス(ログ出力だけのクラス等)
    excludedClasses.set(setOf("grade.Debug*"))
}
