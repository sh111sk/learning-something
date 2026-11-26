# コース B: TLA+ ハンズオン

並行・分散システムの **設計** を、実装の前に状態遷移モデルとして書き、
TLC(モデルチェッカー)で「悪いことが起きない」「いつかよいことが起きる」を網羅検査するコースです。

## レッスン

| # | テーマ | 解説 | 仕様 |
|---|---|---|---|
| T1 | 最初の仕様: Init / Next / Spec / 不変条件 | [T1](./docs/T1-first-spec.md) | `specs/HourClock.tla` |
| T2 | 相互排他: 安全性とバグの反例トレース | [T2](./docs/T2-mutex.md) | `specs/Mutex.tla`, `MutexBuggy.tla` |
| T3 | 活性と公平性(WF/SF)、`~>` | [T3](./docs/T3-liveness.md) | `specs/MutexLive.tla` |
| T4 | PlusCal: 擬似コードで書く(lost update を再現) | [T4](./docs/T4-pluscal.md) | `specs/Counter.tla` |
| T5 | 状態爆発と実務のコツ・次の一歩 | [T5](./docs/T5-practice.md) | (T2 の仕様を流用) |

## 実行方法(再掲)

```bash
export TLA_JAR=/path/to/formal-methods-handson/tools/tla2tools.jar
tlc()  { java -XX:+UseParallelGC -cp "$TLA_JAR" tlc2.TLC "$@"; }
pcal() { java -cp "$TLA_JAR" pcal.trans "$@"; }

cd formal-methods-handson/tla/specs
tlc -config Mutex.cfg Mutex.tla
```

## TLA+ の頭の切り替え

TLA+ は **プログラミング言語ではありません**。次の 3 点を最初に押さえてください。

1. **「状態」とは変数への値の割り当て**。仕様は「初期状態の集合 `Init`」と
   「状態から状態への遷移関係 `Next`」の 2 つで決まる。
2. **`x' = x + 1` は代入ではなく「次の状態の x は x + 1 である」という論理式**。
   式は真/偽を持つだけで、「実行」はされない。TLC が可能な遷移を全部たどる。
3. **`/\`(かつ)`\/`(または)`\E`(存在)`\A`(全称)** の論理式で書く。`\E p \in Procs : ...` は
   「どれかのプロセスが動く」という **非決定性** をそのまま表す。

## 用語

| 用語 | 意味 |
|---|---|
| 状態 | 全変数への値の割り当て |
| 振る舞い(behavior) | 状態の無限列 |
| `Spec` | `Init /\ [][Next]_vars`: 初期状態から `Next` か「変化なし」だけで進む振る舞いの集合 |
| 不変条件(invariant) | すべての到達可能状態で成り立つべき述語。`INVARIANT` で TLC に検査させる |
| 時相性質(property) | 振る舞い全体についての性質(活性など)。`PROPERTY` で検査させる |
| モデル値 | cfg で `{p1, p2}` のように与える、中身のない識別子 |

## 注意: TLC は「有限モデルを網羅」する

`Procs = {p1, p2}` と決めたら、**その 2 プロセスの世界では完全**に検査されますが、3 プロセスは別問題です。
小さなモデルで多くのバグが見つかる(小スコープ仮説)ものの、保証は **モデルの範囲内** です(→ T5)。
