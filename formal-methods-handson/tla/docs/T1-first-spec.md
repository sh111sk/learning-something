# T1. 最初の仕様: HourClock

仕様: `specs/HourClock.tla` / `specs/HourClock.cfg`

## 1. 仕様を読む

```tla
EXTENDS Naturals
VARIABLE hr

Init == hr \in 1..12
Next == hr' = IF hr = 12 THEN 1 ELSE hr + 1
Spec == Init /\ [][Next]_hr
TypeOK == hr \in 1..12
```

| 記法 | 意味 |
|---|---|
| `VARIABLE hr` | 状態変数。状態 = `hr` の値 |
| `Init` | 初期状態の条件。`\in 1..12` なので初期値は **12 通り**(非決定的) |
| `Next` | 遷移関係。`hr'` が次の状態の値。`hr' = ...` は代入ではなく **制約** |
| `[][Next]_hr` | 「常に(`[]`)、`Next` が成り立つか `hr` が変わらない」(= **stuttering 許容**) |
| `Spec` | 振る舞い全体の仕様 |
| `TypeOK` | 型の代わりの不変条件(TLA+ は型なし言語。型の整合性は **検査する** もの) |

> [!NOTE]
> `\in`, `\E`, `\A`, `/\`, `\/` などの ASCII 記法は PDF や Toolbox では `∈ ∃ ∀ ∧ ∨` に整形されます。

## 2. TLC で実行する

```bash
tlc -config HourClock.cfg HourClock.tla
```

`HourClock.cfg`:

```
SPECIFICATION Spec
INVARIANT TypeOK
```

期待される出力(予想):

```
...
Model checking completed. No error has been found.
  ...
12 distinct states found, ...
```

「12 通りの到達可能状態を全部調べて `TypeOK` が常に成り立った」という意味です。

## 3. わざと壊して反例を見る

`HourClock.tla` の `Next` を次のように壊してみます。

```tla
Next == hr' = hr + 1
```

TLC は `hr = 13` に到達した時点で **`TypeOK` 違反** と **そこに至るトレース** を出します。

```
Error: Invariant TypeOK is violated.
State 1: hr = 12   (初期状態の 1 つ)
State 2: hr = 13
```

> [!TIP]
> **TLC の出力はトレースを読むのが全て**です。「どの状態からどのアクションでこうなったか」の
> 連鎖が、そのままバグの再現手順になります。

元に戻して、次の「**デッドロック**」も体験します。

```tla
Next == hr < 12 /\ hr' = hr + 1
```

`hr = 12` で `Next` が不可能になります。TLC は既定で **デッドロック(遷移できない状態)も検出** します
(`Error: Deadlock reached.`)。意図的に止まる仕様なら `-deadlock` オプションで無効化できます。

## 演習

1. `Next` を「毎回 +2 時間」に変えて、`TypeOK` が保たれるように `12` の折り返しを直す。
2. 分も持つ 24 時間時計(`hr \in 0..23`, `min \in 0..59`)を書き、`TypeOK` を検査する。
   1 ステップ = 1 分進む。到達可能な状態数は何個になるか(予想して TLC の出力と比べる)。
3. 「時計が 13 時を指さない」を、`TypeOK` とは別の不変条件 `NeverThirteen` として書く。

> [!NOTE]
> <details><summary>解答(まず自力で)</summary>
>
> ```tla
> ---- MODULE Clock24 ----
> EXTENDS Naturals
> VARIABLES hr, min
> vars == <<hr, min>>
> Init == hr = 0 /\ min = 0
> Next == /\ min' = IF min = 59 THEN 0 ELSE min + 1
>         /\ hr'  = IF min = 59 THEN (IF hr = 23 THEN 0 ELSE hr + 1) ELSE hr
> Spec == Init /\ [][Next]_vars
> TypeOK == hr \in 0..23 /\ min \in 0..59
> ====
> ```
>
> 24 × 60 = 1440 状態。
>
> </details>

## まとめ

- 仕様 = `Init` + `Next`。`'` は「次の状態」。
- TLC は到達可能な状態を全て列挙し、不変条件を検査、破れればトレースを出す。
- 型は検査するもの(`TypeOK`)。デッドロックも既定で検出される。
