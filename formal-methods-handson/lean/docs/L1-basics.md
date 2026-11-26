# L1. Lean の基本: 式・型・命題・タクティク

コード: `LeanHandson/L1_Basics.lean`

## 1. ただのプログラミング言語として

```lean
#eval 1 + 2                     -- 3
def double (n : Nat) : Nat := n * 2
#eval double 21                 -- 42
#check double                   -- double (n : Nat) : Nat
```

- `#eval` は実行、`#check` は型表示、`#print` は定義表示。**この 3 つが調べものの基本**。
- Haskell を知っていれば、関数定義やパターンマッチ、`List.map` などはほぼ同じ。

## 2. 命題を述べる

Lean では「命題(主張)」も型です。**命題の証明とは、その型の値を作ること**(Curry-Howard 対応)。

| 論理 | Lean の型 | 証明の作り方 |
|---|---|---|
| p かつ q | `p ∧ q` | `⟨hp, hq⟩`(ペア) |
| p または q | `p ∨ q` | `Or.inl hp` / `Or.inr hq` |
| p ならば q | `p → q` | `fun hp => ...`(関数) |
| すべての x で P | `∀ x, P x` | `fun x => ...` |
| ある x で P | `∃ x, P x` | `⟨証拠, 証明⟩` |
| p でない | `¬ p` (= `p → False`) | `fun hp => ...` |

```lean
theorem and_swap (p q : Prop) : p ∧ q → q ∧ p :=
  fun ⟨hp, hq⟩ => ⟨hq, hp⟩
```

## 3. タクティクで証明する

`by` 以降は「ゴールを小さくしていく」書き方です。

```lean
theorem and_swap (p q : Prop) : p ∧ q → q ∧ p := by
  intro ⟨hp, hq⟩      -- 仮定 p ∧ q を分解して hp, hq として使えるようにする
  exact ⟨hq, hp⟩      -- ゴール q ∧ p にぴったりの項を渡す
```

頻出タクティク:

| タクティク | 役割 |
|---|---|
| `intro x` | `→` や `∀` の前提を仮定に移す |
| `exact e` | ゴールにぴったりの項 `e` を与えて完了 |
| `constructor` | `∧` / `↔` / `∃` のゴールを部分ゴールに分ける |
| `cases h` | `∨`・`∃`・`∧` の仮定 `h` を場合分け/分解 |
| `rfl` | 両辺が計算で同じなら完了 |
| `unfold f` | 関数 `f` の定義を展開 |
| `simp` | 書き換えで簡約(自動) |
| `omega` | 自然数・整数の線形な等式・不等式を自動で解く |
| `decide` | 判定可能な命題を計算で決着(L5) |

> [!TIP]
> VS Code でカーソルを `by` の下の各行に置くと、**その時点のゴールと仮定** が見えます。
> 「次に何をすればよいか」は常にゴールの形から決まります。たとえばゴールが `A ∧ B` なら `constructor`、
> `A → B` なら `intro`。

## 4. 演習

`L1_Basics.lean` の末尾 4 問の `sorry` を埋めてください。

- 1-1 `(p ∧ q) ∧ r ↔ p ∧ (q ∧ r)`
- 1-2 `double n = n + n`
- 1-3 `∃ n, n * n = 49`
- 1-4 対偶 `(p → q) → (¬ q → ¬ p)`

> [!NOTE]
> <details><summary>解答(まず自力で)</summary>
>
> ```lean
> theorem ex1_and_assoc (p q r : Prop) : (p ∧ q) ∧ r ↔ p ∧ (q ∧ r) := by
>   constructor
>   · intro ⟨⟨hp, hq⟩, hr⟩
>     exact ⟨hp, hq, hr⟩
>   · intro ⟨hp, hq, hr⟩
>     exact ⟨⟨hp, hq⟩, hr⟩
>
> theorem ex2_double_eq (n : Nat) : double n = n + n := by
>   unfold double
>   omega
>
> theorem ex3_square : ∃ n : Nat, n * n = 49 := ⟨7, by decide⟩
>
> theorem ex4_contra (p q : Prop) : (p → q) → (¬ q → ¬ p) := by
>   intro hpq hnq hp
>   exact hnq (hpq hp)
> ```
>
> </details>

## まとめ

- Lean では **命題 = 型、証明 = 値**。タクティクは「値を組み立てる補助」。
- ゴールと仮定を見ながら、形に合ったタクティクを選ぶ。
- 次の L2 では、リスト・自然数のような **再帰的なデータ** に対する証明の中心技法「帰納法」を学びます。
