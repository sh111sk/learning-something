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
    // PIT 本体のバージョン
    pitestVersion.set("1.17.4")
    // JUnit 5 を使うときは必須(PIT は標準では JUnit 4 しか認識しない)
    junit5PluginVersion.set("1.2.1")
    // 変異を入れる対象クラス(パッケージ指定)
    targetClasses.set(setOf("shop.*"))
    // 出力形式: HTML(ブラウザで見る) と XML
    outputFormats.set(setOf("HTML", "XML"))
    // タイムスタンプ付きディレクトリを作らず、毎回 build/reports/pitest に上書きする
    timestampedReports.set(false)
    // 並列実行数
    threads.set(2)
}
