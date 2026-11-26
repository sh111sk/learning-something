# T4. PlusCal: 擬似コードで書く

仕様: `specs/Counter.tla` / `specs/Counter.cfg`

PlusCal は TLA+ の上に載った **手続き型風の記法** です。コメントの中にアルゴリズムを書くと、
トランスレータが TLA+ の仕様(`Init` / `Next` / `Spec`)を生成します。
並行アルゴリズムを「コードのように」書きたいときに便利です。

## 1. 題材: lost update(更新の取りこぼし)

2 つのプロセスが共有カウンタ `x` を「読む → +1 して書く」で更新します。

```
(*--algorithm Counter
variables x = 0;

process (Inc \in 1..2)
variables tmp = 0;
begin
  Read:  tmp := x;
  Write: x := tmp + 1;
end process;

end algorithm; *)
```

- **ラベル(`Read:` `Write:`)が 1 ステップ(不可分な単位)の区切り** です。ラベルとラベルの間で
  他のプロセスに割り込まれうる。これが並行性のモデル化のすべて。
- `process (Inc \in 1..2)` は 2 個のプロセス(`self` が 1 か 2)。`tmp` はプロセスごとのローカル変数。

## 2. 翻訳して実行する

```bash
cd formal-methods-handson/tla/specs
pcal Counter.tla                 # BEGIN TRANSLATION ... END TRANSLATION が挿入される
tlc -config Counter.cfg Counter.tla
```

`Counter.tla` の末尾に自分で定義した不変条件があります。

```tla
Correct == (\A self \in ProcSet : pc[self] = "Done") => x = 2
```

「全プロセスが終了したら `x = 2`」。`pc` や `ProcSet` は翻訳が生成する名前です(`pc` = 各プロセスの「今どのラベルか」)。

期待される出力(予想): `Invariant Correct is violated.` と次のトレース。

```
State 1: x = 0, tmp = (1 :> 0 @@ 2 :> 0), pc = (1 :> "Read" @@ 2 :> "Read")
State 2: Read(1)   tmp[1] = 0
State 3: Read(2)   tmp[2] = 0       ← 2 人とも 0 を読む
State 4: Write(1)  x = 1
State 5: Write(2)  x = 1            ← p2 も 0+1 を書く → 2 になるはずが 1
```

> [!IMPORTANT]
> `x := x + 1` が 1 行に見えても、実機では「読む → 足す → 書く」の複数ステップです。
> **PlusCal は、どこまでが不可分かをラベルで明示させる** ことで、こうした競合に気付かせてくれます。

## 3. 直す

(a) 読み書きを **1 つのラベル(= 不可分)** にする。

```
process (Inc \in 1..2)
begin
  Incr: x := x + 1;
end process;
```

(b) アルゴリズムとして直す(実機では CAS やロックを使う)。ロックなら `await` で待たせる。

```
variables x = 0, lock = FALSE;
process (Inc \in 1..2)
variables tmp = 0;
begin
  Acquire: await ~lock; lock := TRUE;
  Read:    tmp := x;
  Write:   x := tmp + 1;
  Release: lock := FALSE;
end process;
```

`await ~lock; lock := TRUE;` が同じラベル内なので「確認と取得」が不可分(T2 の `Enter` と同じ発想)。
(`Acquire` を `await` のラベルと `lock := TRUE` に分けたらどうなるか → 演習 1)

## 4. PlusCal のよく使う構文

| 構文 | 意味 |
|---|---|
| `variables x = 0;` | グローバル変数(アルゴリズム先頭) |
| `process (P \in Set)` | `Set` の要素ごとに 1 プロセス。`self` で自分を参照 |
| `Label: ...` | ここから次のラベルまでが 1 ステップ |
| `await cond;` | `cond` が真になるまでそのプロセスは進めない |
| `either ... or ...` | 非決定的な選択 |
| `with (v \in S) ...` | `S` から非決定的に選ぶ |
| `while (cond) do ... end while;` | ループ(ループ先頭にもラベルが必要) |
| `define ... end define;` | 仕様側の補助定義(不変条件など) |

> [!NOTE]
> 2 種類の構文(`p-syntax` と `c-syntax`)がありますが、このコースは `begin ... end process;` の p-syntax です。
> 翻訳後の TLA+ を **読んで** みてください。`pc[self] = "Read"` を条件に遷移していて、
> PlusCal が単なる TLA+ の糖衣構文であることが分かります。

## 演習

1. 上の (b) で、`Acquire` を `Test: await ~lock;` と `Set: lock := TRUE;` の 2 ラベルに分けるとどうなる?
   `x = 2` の不変条件と、`lock` に関する相互排他(2 プロセスが同時に `Read` と `Write` の間にいない)を検査。
2. (b) のロック版で `Correct` が成り立つことを TLC で確認。
3. プロセスを 3 つにして、`Correct` を `x = 3` に直す。lost update は何通りで起きる?

> [!NOTE]
> <details><summary>ヒント</summary>
>
> 1. `Test` と `Set` の間に他のプロセスが `Test` を通ってしまい、両方が `lock := TRUE` でクリティカル領域に入る。
>    `Correct` が再び破れる(T2 のバグ版と同じ構造)。
>    相互排他の不変条件は `define` の中に
>    `MutEx == ~(pc[1] \in {"Read","Write"} /\ pc[2] \in {"Read","Write"})` のように書ける。
> 3. `Correct` の定数を 3 にし、`1..3` に変更するだけ。TLC の出力で状態数が増える様子も観察する。
>
> </details>

## まとめ

- PlusCal = TLA+ の擬似コード記法。**ラベル = 不可分な 1 ステップ**。
- 「`x := x + 1` が安全か」は、ラベルの切り方(= どこで割り込まれうるか)で決まる。
- 生成された TLA+ を読むと、PlusCal の正体が分かる。
