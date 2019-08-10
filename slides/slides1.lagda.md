
---
title: "Correct-by-construction programming in Agda"
subtitle: "Lecture 1: Getting started with Agda"
author: "Jesper Cockx"
date: "31 August 2019"

transition: "linear"
center: "false"
width: "1280"
height: "720"
margin: "0.2"
---

# Correct-by-construction programming

##

“Program testing can be used to show the presence of bugs, but never to show their absence!” --Edsger Dijkstra

“A computer will do what you tell it to do, but that may be much different from what you had in mind.” --Joseph Weizenbaum

## Why use dependent types?

With dependent types, we can **statically verify** that a program
satisfies a given correctness property.

Verification is **built into** the language itself.

## Two approaches to verification with dependent types:

- **Extrinsic approach**: first write the program and then prove
    correctness
- **Intrinsic approach**: first define the *type* of programs that
  satisfy the correctness property and then write the program that
  inhabits this type

The intrinsic approach is also called **correct-by-construction** programming.

## Example of extrinsic verification
<!--
```agda
open import Data.Bool.Base using (Bool; true; false)
open import Data.Char.Base using (Char)
open import Data.Integer.Base using (ℤ)
open import Data.List.Base using (List; []; _∷_)
open import Data.Maybe.Base using (Maybe; nothing; just)
open import Data.Nat.Base using (ℕ; zero; suc; _+_; _*_; _<_)
open import Data.Product using (_×_; _,_)
open import Agda.Builtin.Equality using (_≡_; refl)

postulate
  ⋯ : ∀ {ℓ} {A : Set ℓ} → A

module Intro where
```
-->

```agda
  module Extrinsic where
    sort : List ℕ → List ℕ
    sort = ⋯

    IsSorted : List ℕ → Set
    IsSorted = ⋯

    sort-is-sorted : ∀ xs → IsSorted (sort xs)
    sort-is-sorted = ⋯
```

## Example of intrinsic verification

```agda
  module Intrinsic where
    SortedList : Set
    SortedList = ⋯

    sort : List ℕ → SortedList
    sort = ⋯
```

## Correct-by-construction programming

Building invariants into the *types* of our program, to make it
**impossible** to write an incorrect program in the first place.

. . .

No proving allowed!

## Running example

Implementation of a correct-by-construction **typechecker** + **interpreter** for a C-like language (WHILE)

```c
int main () {
  int n   = 100;
  int sum = 0;
  int k   = 0;
  while (n > k) {
    k   = k   + 1;
    sum = sum + k;
  }
  printInt(sum);
}
```

## Overview of this course

* **Lecture 1**: Getting started with Agda
* **Lecture 2**: Indexed datatypes and dependent pattern matching
* **Lecture 3**: Practical programming: instance arguments, do notation, Haskell FFI
* **Lecture 4**: (Non-)termination: termination checker, coinduction, sized types

# Introduction to Agda

## What is Agda?

Agda is...

1. A strongly typed functional programming language in the tradition
   of Haskell
2. An interactive theorem prover in the tradition of Martin-Löf

We will mostly use 1. in this course.

## Installation

For this tutorial, you will need to install **Agda**, the **Agda standard library**, and the **BNFC** tool.

- Agda: [github.com/agda/agda](https://github.com/agda/agda)
- Agda standard library: [github.com/agda/agda-stdlib](https://github.com/agda/agda-stdlib)
- BNFC: [github.com/BNFC/bnfc](https://github.com/BNFC/bnfc)

Installation instructions:
```bash
git clone https://github.com/jespercockx/ohrid19-agda
cd ohrid19-agda
./setup.sh
```

## Main features of Agda

- Dependent types
- Indexed datatypes and dependent pattern matching
- Termination checking and productivity checking
- A universe hierachy with universe polymorphism
- Implicit arguments
- Parametrized modules (~ ML functors)

## Other lesser well-known features of Agda

- Record types with copattern matching
- Coinductive datatypes
- Sized types
- Instance arguments (~ Haskell's typeclasses)
- A FFI to Haskell

We will use many of these in the course of this tutorial!

## Emacs mode for Agda

Basic commands:

- **C-c C-l**: typecheck and highlight the current file
- **C-c C-d**: deduce the type of an expression
- **C-c C-n**: evaluate an expression to normal form

Programs may contain **holes** (? or {! !}).

- **C-c C-,**: get information about the hole under the cursor
- **C-c C-space**: give a solution
- **C-c C-r**: *refine* the hole
  * Introduce a lambda or constructor
  * Apply given function to some new holes
- **C-c C-c**: case split on a variable

# Demo time!

## Testing functions using the identity type

The identity type `x ≡ y` is inhabited by `refl` iff `x` and `y` are
(definitionally) equal.

We can use this to write *checked* tests for our Agda functions!

```
testPlus : 1 + 1 ≡ 2
testPlus = refl
```

## Abstract syntax tree of WHILE

```
data Id : Set where
  mkId : List Char → Id

data Exp : Set where
  eId       : (x : Id)      → Exp
  eInt      : (i : ℤ)       → Exp
  eBool     : (b : Bool)    → Exp
  ePlus     : (e e' : Exp)  → Exp
  eGt       : (e e' : Exp)  → Exp
  eAnd      : (e e' : Exp)  → Exp
```

## Consistency checks

To maintain logical consistency, Agda does:

* Coverage checking
* Termination checking
* Positivity checking
* Universe checking

## Exercise

Implement an evaluation function for expressions.

```
data Value : Set where
  valInt   : (i : ℤ) → Value
  valBool  : (b : Bool) → Value
  valError : Value

eval : Exp → Value
eval = ⋯
```
