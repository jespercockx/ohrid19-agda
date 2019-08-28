---
title: "Correct-by-construction programming in Agda"
subtitle: "Lecture 4: (Non-)termination"
author: "Jesper Cockx"
date: "3 September 2019"

transition: "linear"
center: "false"
width: "1280"
height: "720"
margin: "0.2"
---

##

"I'll save the world...

tomorrow."

-- unknown

# Totality checking

## Partial functions in type theory

<!--
```
open import Library
```
-->

What happens if we have a partial function in Agda?

- Theory would become inconsistent!
```unchecked
absurd : ⊥
absurd = absurd
```
- Typechecker would crash or loop!
```unchecked
f : ℕ → ℕ
f zero = 42

test : Vec ℕ (f 1)
test = []
```

⇒ Partial functions must be ruled out!

## Checking totality

1. **Completeness** of pattern matching
2. **Structural recursion** of recursive functions
3. **Strict positivity** of inductive datatypes
4. **Consistency** of universe levels

2-4 together ensure normalization of well-typed terms

## Primitive recursion

```
plus : ℕ → ℕ → ℕ
plus zero    m = m
plus (suc n) m = suc (plus n m)

natEq : ℕ → ℕ → Bool
natEq zero    zero    = true
natEq zero    (suc m) = false
natEq (suc n) zero    = false
natEq (suc n) (suc m) = natEq n m
```

## Structural recursion

```
fib : ℕ → ℕ
fib zero          = zero
fib (suc zero)    = suc zero
fib (suc (suc n)) = plus (fib n) (fib (suc n))
```

```
ack : ℕ → ℕ → ℕ
ack zero    m       = suc m
ack (suc n) zero    = ack n (suc zero)
ack (suc n) (suc m) = ack n (ack (suc n) m)
```

# Coinduction

## A frequently asked question

"If all functions in Agda are total, doesn't that mean Agda is not Turing-complete?"

. . .

*Answer*: **NO!** Agda just forces you to be *honest* about when a function is non-terminating.

## Coinduction in Agda

A **coinductive type** = a type with possibly infinitely deep values.

<!--
```agda
module Coinduction where
  module GuardedStream where
```
-->

```agda
    record Stream (A : Set) : Set where
      coinductive
      field
        head : A
        tail : Stream A
    open Stream

    repeat : {A : Set} → A → Stream A
    repeat x .head = x
    repeat x .tail = repeat x
```

## Mixing induction and coinduction (1/2)



```
  mutual
    record Coℕ′ : Set where
      coinductive
      field
        .force : Coℕ

    data Coℕ : Set where
      zero : Coℕ
      suc  : Coℕ′ → Coℕ
  open Coℕ′ public
```

## Mixing induction and coinduction (2/2)

```
  fromℕ : ℕ → Coℕ
  fromℕ′ : ℕ → Coℕ′

  fromℕ zero = zero
  fromℕ (suc x) = suc (fromℕ′ x)

  fromℕ′ x .force = fromℕ x

  infty  : Coℕ
  infty′ : Coℕ′

  infty = suc infty′
  infty′ .force = infty
```

## Dealing with infinite computations

Remember: all Agda functions must be **total**

One way to work around this is by adding 'fuel':

<!--
```
  postulate
    ⋯ : {A : Set} → A
    Term Val : Set
```
-->

```
  step : Term → Term ⊎ Val
  step = ⋯

  eval : ℕ → Term → Maybe Val
  eval (suc n) t = case (step t) of λ where
    (inj₁ t') → eval n t
    (inj₂ v)  → just v
  eval zero t = nothing
```

Can we do better?

## Going carbon-free with the `Delay` monad


A value of type `Delay A` is

- either a value of type `A` produced **now**
- or a computation of type `Delay A` producing a value **later**

The `Delay` monad captures the effect of *non-termination*

## The Delay monad: definition

```agda
  mutual
    record Delay (A : Set) : Set where
      coinductive
      field force : Delay' A

    data Delay' (A : Set) : Set where
      now   : A       → Delay' A
      later : Delay A → Delay' A

  open Delay public

  never : {A : Set} → Delay A
  never .force = later never
```

## Unrolling a `Delay`ed value

```
  unroll : {A : Set} → ℕ → Delay A → Maybe A
  unroll zero    x = nothing
  unroll (suc n) x = case (x .force) of λ where
    (now v  ) → just v
    (later d) → unroll n d
```

# Sized types

## Using sizes to prove termination

Totality requirement: coinductive definitions should be **productive**:
computing each observation should be terminating.

To ensure this, Agda checks that corecursive calls are **guarded by constructors**, but this is often quite limiting.

A more flexible and modular approach is to use **sized types**.

## The type `Size`

`Size` ≃ abstract version of the natural numbers extended with `∞`

For each `i : Size`, we have a type `Size< i` of sizes **smaller than `i`**.

**Note**: pattern matching on `Size` is not allowed!

## The sized delay monad

<!--
```agda
module SizedTypes where
  open import Size
```
-->

```agda
  mutual
    record Delay (i : Size) (A : Set) : Set where
      coinductive
      constructor delay
      field
        force : {j : Size< i} → Delay' j A

    data Delay' (i : Size) (A : Set) : Set where
      return' : A         → Delay' i A
      later'  : Delay i A → Delay' i A
```
`i` ≃ how many more steps are we allowed to observe.

`Delay ∞ A` is the type of computations that can take *any* number of steps.

## Interpreting well-typed WHILE programs

WHILE statements can have two effects:

- Modify the environment   ⇒ `State` monad
- Go into a loop           ⇒ `Delay` monad

We combine both effects in the `Exec` monad.

## The `Exec` monad

<!--
```agda
  open import Library
  postulate
    ⋯ : {A : Set} → A
    Cxt : Set
    Stm : Cxt → Set
    Env : Cxt → Set
    Program : Set
```
-->

```agda
  record Exec {Γ : Cxt} (i : Size) (A : Set) : Set where
    field
      runExec : (ρ : Env Γ) → Delay i (A × Env Γ)
  open Exec public

  execStm : ∀ {Γ} {i} (s : Stm Γ) → Exec {Γ} i ⊤
  execStm = ⋯

  execPrg : ∀ {i} (prg : Program) → Delay i ℤ
  execPrg prg = ⋯
```
See [V3/Interpreter.agda](https://jespercockx.github.io/ohrid19-agda/src/V3/html/V3.Interpreter.html) for full code.

## Exercise

Now you should be ready to add a bigger new feature:

* A new control operator: `if` statements, `do/while` loops, `for`, `switch`, ...
* New types: `char`, `bool`, ...
* New programming concepts: function calls, pointers, ...

Extend the syntax, the typechecker, and the interpreter with rules for
your new feature.
