# コース C: Alloy 6 ハンズオン

小さな **構造モデル** を書き、「この制約から本当にこの性質が従うか?」を
ソルバが自動で検査して、**反例を図で見せてくれる** 体験をするコースです。

## レッスン

| # | テーマ | 解説 | モデル |
|---|---|---|---|
| A1 | sig / field / fact / run / check の基本 | [A1](./docs/A1-basics.md) | `01_filesystem.als` |
| A2 | 関係論理(join・閉包・集合演算)で権限モデルを検査 | [A2](./docs/A2-relations.md) | `02_permissions.als` |
| A3 | スコープと反例の読み方、不変条件(古典スタイル) | [A3](./docs/A3-scope-counterexample.md) | `03_library.als` |
| A4 | Alloy 6 の時相論理: 相互排他 | [A4](./docs/A4-temporal-mutex.md) | `04_mutex.als`, `04b_mutex_buggy.als` |
| A5 | まとめ演習と Alloy の限界・他ツールとの対比 | [A5](./docs/A5-wrapup.md) | (自作) |

## 実行方法

GUI を起動して `.als` を開きます。

```bash
java -jar tools/org.alloytools.alloy.dist.jar
```

- **Execute → Execute All**: ファイル内の全 `run` / `check` を実行。
- 結果行の **Instance / Counterexample** リンクで図を表示。**Next** で別の解、**Theme** で見た目を変更。
- 画面下部の **Tree / Text / Table** で解の中身を表形式でも見られる(図で分かりにくいときは Table)。

## Alloy の考え方(3 行)

1. **`sig`(集合)と field(関係)** でデータ構造を宣言する。すべてが **関係**(集合・関数・リスト全部)。
2. **`fact`(常に成り立つ制約)** で世界を絞り込む。
3. **`run`(この条件を満たす世界を見せて)/ `check`(この主張が破れる世界を探して)** で問い合わせる。

## 用語

| 用語 | 意味 |
|---|---|
| sig | 原子の集合の宣言(型のようなもの) |
| field | sig に付く関係(例: `parent: lone Dir`) |
| fact | 常に成り立つ制約 |
| pred / fun | 再利用できる述語 / 関数 |
| assert | 検査したい主張(`check` で反例探索) |
| scope | 各 sig の要素数の上限(`for 4`)。**検査はスコープ内でのみ完全** |
| インスタンス | 制約を満たす具体的な世界(原子と関係の割り当て) |

## 注意: 保証は「スコープ内」

`check ... for 5` で反例なし = 「各 sig が 5 個以下の世界に反例はない」。
6 個必要な反例は見つかりません(小スコープ仮説: 実務では多くの欠陥は小さな反例で見つかる)。
スコープを広げて試す習慣を持ってください(A3)。
