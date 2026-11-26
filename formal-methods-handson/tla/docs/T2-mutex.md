# T2. 相互排他: 安全性とバグの反例トレース

仕様: `specs/Mutex.tla`, `specs/MutexBuggy.tla`

L4(Lean)・A4(Alloy)と **同じ題材** です。

## 1. 仕様

```tla
CONSTANT Procs
VARIABLES pc, lock

Init == /\ pc = [p \in Procs |-> "idle"]
        /\ lock = FALSE

Enter(p) == /\ pc[p] = "idle"
            /\ ~lock                     \* ガード: ロックが空いている
            /\ lock' = TRUE              \* ロックを取る(確認と取得が 1 ステップ)
            /\ pc' = [pc EXCEPT ![p] = "crit"]

Leave(p) == /\ pc[p] = "crit"
            /\ lock' = FALSE
            /\ pc' = [pc EXCEPT ![p] = "idle"]

Next == \E p \in Procs : Enter(p) \/ Leave(p)
```

読み方のポイント:

- `pc` は **関数**(プロセス → 状態)。`pc[p]` が参照、`[pc EXCEPT ![p] = "crit"]` が「p だけ更新した関数」。
- `Enter(p)` の前半 `pc[p] = "idle" /\ ~lock` は **ガード**(実行条件)、後半が **更新**。
  ガードが偽のアクションは「その状態では起こりえない」だけ。
- 全てのアクションで、**更新しない変数も書く** 必要がある(`UNCHANGED lock` 等)。書き忘れると
  論理的には「次の状態のその変数は何でもよい」という意味になる。TLC は次状態を計算できず
  `Successor state is not completely specified` のようなエラーで止まる(TLA+ 初心者最頻出のミス)。
- `\E p \in Procs : ...` が「どのプロセスが動くかは非決定的」を表す。

性質:

```tla
MutualExclusion ==
    \A p, q \in Procs : (p # q) => ~(pc[p] = "crit" /\ pc[q] = "crit")
```

## 2. 実行

```bash
tlc -config Mutex.cfg Mutex.tla
```

`Mutex.cfg`:

```
SPECIFICATION Spec
CONSTANT Procs = {p1, p2}
INVARIANT TypeOK
INVARIANT MutualExclusion
INVARIANT LockHeld
```

`CONSTANT Procs = {p1, p2}` は **モデル値**(中身を持たない 2 つの識別子)で、2 プロセスのモデルを意味します。
期待: `No error has been found`(状態数は数個程度)。

## 3. バグ版を検査する

```bash
tlc -config MutexBuggy.cfg MutexBuggy.tla
```

`MutexBuggy.tla` は「確認(`Test`)」と「取得(`SetLock`)」を **別ステップ** に分けたものです。
期待される出力(予想):

```
Error: Invariant MutualExclusion is violated.
State 1: pc = (p1 :> "idle" @@ p2 :> "idle"), lock = FALSE
State 2: Test(p1)    pc = (p1 :> "ready" @@ p2 :> "idle"), lock = FALSE
State 3: Test(p2)    pc = (p1 :> "ready" @@ p2 :> "ready"), lock = FALSE
State 4: SetLock(p1) pc = (p1 :> "crit"  @@ p2 :> "ready"), lock = TRUE
State 5: SetLock(p2) pc = (p1 :> "crit"  @@ p2 :> "crit"),  lock = TRUE
```

> [!IMPORTANT]
> これが **TLA+ の価値の核心**です。「確認してから取る」という一見正しい手順が、
> 2 プロセスが交互に動くと破れる(check-then-act の競合)ことを、**最短の再現手順つきで** 機械が見つけます。
> 人間のレビューや単体テストでは見落としやすい種類のバグです。

## 4. 不変条件の設計

| 不変条件 | 役割 |
|---|---|
| `TypeOK` | 変数の値の範囲が正しいか(仕様自体の書き間違い検出) |
| `MutualExclusion` | 本命の安全性 |
| `LockHeld` | 「crit にいるなら lock が立っている」。補助。Lean では **これを足さないと帰納法が通らなかった** が、TLC では不要(到達可能な状態しか見ないので)。必須ではないが、仕様の理解の確認になる |

## 演習

1. `Procs = {p1, p2, p3}` で `Mutex.cfg` を実行。状態数(`distinct states`)はどう変わる?
2. `Mutex.tla` の `Leave` の `lock' = FALSE` を `UNCHANGED lock`(ロックを解放しない)に変える。
   どの不変条件が破れる? TLC は何を報告する?
3. `UNCHANGED` を書き忘れる実験: `Leave` から `lock' = FALSE` を **消すだけ**(`UNCHANGED lock` も書かない)にして、
   TLC のエラーメッセージを読む。**書き忘れの典型エラー** を体験する。
4. 「プロセスは idle→crit→idle を繰り返す」以外に、`Fail(p)`(crit 中にクラッシュ。lock を放さない)を追加。
   何が破れる?(何が破れないことが分かった?)

> [!NOTE]
> <details><summary>ヒント / 解答の方針</summary>
>
> 1. 3 プロセスなら状態数が増えるが、これでも数十状態。プロセス数が増えると指数的に増える(→ T5)。
> 2. ロックが解放されないので `Leave` 後も `lock = TRUE` のまま。`MutualExclusion` も `LockHeld` も保たれる。
>    代わりに誰も `Enter` できなくなり、TLC は **デッドロック**(`Error: Deadlock reached.`)を報告する。
>    「安全性は満たすが前に進まない」ことを機械が検出する例。仕様が **何を保証していて何を保証していないか** に注意。
> 3. `lock'` が決まらないため、TLC は「次状態が完全に指定されていない」旨のエラーで止まる。
> 4. `Fail(p)`: `pc[p] = "crit" /\ pc' = [pc EXCEPT ![p] = "dead"] /\ UNCHANGED lock`。
>    相互排他は保たれるが、`lock` が永久に取られたまま = 他のプロセスが進めないデッドロック(安全性は OK、活性が NG)。
>
> </details>

## まとめ

- アクション = ガード + 更新。更新しない変数は `UNCHANGED` を明記する。
- 並行システムのバグ(競合状態)は、TLC が **最短の反例トレース** として見つけてくれる。
- `INVARIANT` = 安全性(悪いことは起きない)。次は活性(良いことがいつか起きる)。
