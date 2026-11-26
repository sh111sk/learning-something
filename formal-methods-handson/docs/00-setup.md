# 00. 環境構築

3 つとも無料で、Linux / macOS / Windows(WSL 推奨)で動きます。

## 共通: Java

TLA+ と Alloy は Java で動きます。**Java 17 以上**を推奨します。

```bash
java -version
```

## A. Lean 4

Lean 自体のバージョン管理ツール **elan** を入れ、あとはプロジェクトの `lean-toolchain` に任せます。

```bash
curl https://elan.lean-lang.org/elan-init.sh -sSf | sh
# シェルを開き直す
lean --version
lake --version
```

エディタは **VS Code + 拡張機能「Lean 4」** を推奨します(証明の途中状態=「ゴール」が右ペインに出ます。
Lean は **ゴールを見ながら書く言語** なので、エディタなしの学習はおすすめしません)。

動作確認:

```bash
cd formal-methods-handson/lean
lake build                                  # 全レッスンをビルド(sorry の警告が出るのは正常)
lake env lean LeanHandson/L1_Basics.lean    # 1 ファイルだけ検査
```

- 初回は Lean 本体のダウンロードで数分かかります。
- このコースは **Mathlib を使いません**(ダウンロードが巨大になるため)。標準の `omega` / `simp` / `decide` だけで進めます。
- `lean-toolchain` は `leanprover/lean4:stable` にしてあります。バージョン差で動かないときは、
  その時点の具体的なバージョン(例 `leanprover/lean4:v4.xx.0`)に書き換えてください。

## B. TLA+

TLC(モデルチェッカー)は `tla2tools.jar` 1 つです。

```bash
mkdir -p formal-methods-handson/tools && cd formal-methods-handson/tools
curl -L -O https://github.com/tlaplus/tlaplus/releases/latest/download/tla2tools.jar
```

(`tools/*.jar` は `.gitignore` 済みです。)

以降のレッスンでは次のシェル関数を使います。`~/.bashrc` 等に入れておくと楽です。

```bash
export TLA_JAR=$HOME/path/to/formal-methods-handson/tools/tla2tools.jar
tlc()  { java -XX:+UseParallelGC -cp "$TLA_JAR" tlc2.TLC "$@"; }
pcal() { java -cp "$TLA_JAR" pcal.trans "$@"; }
```

動作確認:

```bash
cd formal-methods-handson/tla/specs
tlc -config HourClock.cfg HourClock.tla
# 末尾に "Model checking completed. No error has been found." が出れば成功
```

エディタは **VS Code 拡張「TLA+」**(構文ハイライト・TLC 実行・トレース表示)または公式の **TLA+ Toolbox**(GUI)。
このコースはコマンドライン前提で書いています。

> [!NOTE]
> TLC は実行ディレクトリに `states/` ディレクトリを作ります(`.gitignore` 済み)。

## C. Alloy 6

```bash
cd formal-methods-handson/tools
curl -L -O https://github.com/AlloyTools/org.alloytools.alloy/releases/download/v6.2.0/org.alloytools.alloy.dist.jar
java -jar org.alloytools.alloy.dist.jar          # GUI が開く
```

- GUI で `.als` を開き、メニュー **Execute → Execute All** で `run` / `check` を全部実行できます。
  反例は **Show** ボタンで可視化(Theme で見た目を調整、Alloy 6 は時間軸のステップを辿れます)。
- 上のバージョン `v6.2.0` が古い/無い場合は
  <https://github.com/AlloyTools/org.alloytools.alloy/releases> で最新を選んでください。
- コマンドライン実行も可能です(オプションは版により違うので `help exec` を確認):

```bash
java -jar org.alloytools.alloy.dist.jar help
java -jar org.alloytools.alloy.dist.jar exec -f -t text -o - alloy/01_filesystem.als
```

> [!TIP]
> Alloy は GUI が主役のツールです。反例の図を見るのが学習の中心なので、最初は GUI を使いましょう。

## 動作確認チェックリスト

- [ ] `lean --version` が表示され、`lake build` が通る
- [ ] `tlc -config HourClock.cfg HourClock.tla` が "No error has been found"
- [ ] Alloy GUI が開き、`alloy/01_filesystem.als` の `run show for 4` で図が出る
