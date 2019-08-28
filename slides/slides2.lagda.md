
---
title: "Correct-by-construction programming in Agda"
subtitle: "Lecture 2: indexed datatypes and dependent pattern matching"
author: "Jesper Cockx"
date: "1 September 2019"

transition: "linear"
center: "false"
width: "1280"
height: "720"
margin: "0.2"
---



# Recap: correct-by-construction programming

## Indices capture invariants

The indices of a datatype capture important invariants of our programs:

* The length of a list
* The lower and upper bounds of a search tree
* The type of a syntax tree (!)

## Extrinsic vs intrinsic verification

Two styles of verification:

* **Extrinsic**: write a program and then prove its properties
* **Intrinsic**: define properties at the type-level and write programs that satisfy them *by construction*

Intrinsic verification is a good fit for **complex** programs with **simple** invariants

For small programs and/or complex invariants, extrinsic verification may work better

## Let the types guide you

By encoding invariants in the types, they can guide the construction of our programs:

* Rule out impossible cases (absurd patterns `()`)
* Automatic case splitting (C-c C-c)
* Program inference (C-c C-a)
* ...

# Prototype indexed datatype: length-indexed vectors

## What are vectors?

<!--
```
open import Data.Bool using (Bool; true; false)
open import Data.Nat using (ℕ; zero; suc)
open import Data.Integer using (ℤ)

postulate
  ⋯ : ∀ {ℓ} {A : Set ℓ} → A
```
-->

If `n : ℕ`, then `Vec A n` consists of vectors of `A`s of length `n`:
```
data Vec (A : Set) : ℕ → Set where
  []  : Vec A 0
  _∷_ : ∀ {n} → A → Vec A n → Vec A (suc n)
```

Compare to lists:
```
data List (A : Set) : Set where
  []  : List A
  _∷_ : A → List A → List A
```

## Functions on vectors

**Question**: what should be the type of `head` and `tail` functions on `Vec`?

How about `_++_` (append) and `map`?

## Indexing into vectors

An index into a vector of length `n` is a number between `0` and `n-1`:
```
data Fin : ℕ → Set where
  zero : ∀ {n} → Fin (suc n)
  suc  : ∀ {n} → Fin n → Fin (suc n)

lookup : ∀ {A} {n} → Vec A n → Fin n → A
lookup xs i = ⋯
```
`lookup` is a total function!

# Intrinsically well-typed syntax

## Well-typed syntax representation

Our correct-by-construction typechecker produces **intrinsically well-typed syntax**:

<!--
```
module V1 where
```
-->

```
  data Type : Set where
    int bool : Type

  data Exp : Type → Set
    -- ...
```

A term `e : Exp Γ t` is a *well-typed* WHILE expression in context `Γ`.

## Well-typed syntax

```agda
  data Op : (dom codom : Type) → Set where
    plus  : Op int  int
    gt    : Op int  bool
    and   : Op bool bool

  data Exp where
    eInt  : (i : ℤ)            → Exp int
    eBool : (b : Bool)         → Exp bool
    eOp   : ∀{t t'} (op : Op t t')
          → (e e' : Exp t)     → Exp t'
```

See
[WellTypedSyntax.agda](https://jespercockx.github.io/ohrid19-agda/src/V1/html/V1.WellTypedSyntax.html).

## Evaluating well-typed syntax

We can interpret `C` types as Agda types:
```
  Val : Type → Set
  Val int  = ℤ
  Val bool = Bool
```

We can now define `eval` for well-typed expressions:

```

  eval : ∀ {t} → Exp t → Val t
  eval = ⋯
```
that **always** returns a value (bye bye `Maybe`!)

See definition of `eval` in
[Interpreter.agda](https://jespercockx.github.io/ohrid19-agda/src/V1/html/V1.Interpreter.html).

# Dealing with variables

## Extending well-typed syntax with variables

A **context** is a list containing the types of variables in scope
```
data Type : Set where int bool : Type

Cxt = List Type
```

A **variable** is an index into the context
```
data Var : (Γ : Cxt) (t : Type) → Set where
  here  : ∀ {Γ t}    → Var (t ∷ Γ) t
  there : ∀ {Γ t t'} → Var Γ t → Var (t' ∷ Γ) t
```
(compare this to the definition of `Fin`)

## Well-typed syntax with variables

The type `Exp` is now parametrized by a context `Γ`:

```agda
data Exp (Γ : Cxt) : Type → Set where
  -- ...
  eVar  : ∀{t} (x : Var Γ t) → Exp Γ t
```
See [WellTypedSyntax.agda](https://jespercockx.github.io/ohrid19-agda/src/V2/html/V2.WellTypedSyntax.html).

## The `All` type

`All P xs` contains an element of `P x` for each `x` in the list `xs`:

```
data All {A : Set} (P : A → Set) : List A → Set where
  []  : All P []
  _∷_ : ∀ {x xs} → P x → All P xs → All P (x ∷ xs)
```

## Evaluation environments

During evaluation we need a value for `All` variables
```
Val : Type → Set
Val int  = ℤ
Val bool = Bool

Env : Cxt → Set
Env Γ = All Val Γ
```

We can now extend `eval` to expressions with variables:

```
eval : ∀ {Γ} {t} → Env Γ → Exp Γ t → Val t
eval = ⋯
```

See definition of `eval` in [Interpreter.agda](https://jespercockx.github.io/ohrid19-agda/src/V2/html/V2.Interpreter.html).

## Exercises

Extend the well-typed syntax and interpreter with the syntactic
constructions you added before.
