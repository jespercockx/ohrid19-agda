
---
title: "Correct-by-construction programming in Agda"
subtitle: "Lecture 3: Side effects, type classes, and monads"
author: "Jesper Cockx"
date: "2 September 2019"

transition: "linear"
center: "false"
width: "1280"
height: "720"
margin: "0.2"
---


# Type classes

## What is a type class?

A type class offers one or more functions for a **generic** type. **Examples**:

- `Print A`:
  * `print : A → String`
- `Monoid M` type class:
  * `∅ : M`
  * `_+_ : M → M → M`
- `Eq A`:
  * `_==_ : A → A → Bool` and/or `_≟_ : (x y : A) -> Dec (x ≡ y)`
- `Functor F`:
  * `fmap : {A B : Set} → F A → F B`

## Parametric vs ad-hoc overloading

Why not have `print : {A : Set} -> A -> String`?

. . .

Because of *parametricity*, `print` would have to be a constant function.

Type classes allow a *different* implementation at each type!

## Type classes in Agda

A type class is implemented by using a **record type** + **instance arguments**

- Record type: a **dictionary** holding implementation of each function for a specific type
- Instance arguments: *automatically* pick the 'right' dictionary for the given type

## Instance arguments

*Instance arguments* are Agda's builtin mechanism for
 ad-hoc overloading (~ type classes in Haskell).

Syntax:

- Using an instance: `{{x : A}} → ...`
- Defining new instances: `instance ...`

When using a function of type `{{x : A}} → B`, Agda will automatically
resolve the argument if there is a **unique** instance of the
right type in scope.


## Defining a typeclass with instance arguments

<!--
```agda
module _ where
open import Data.Bool.Base
open import Data.String.Base
```
-->

```agda
record Print {ℓ} (A : Set ℓ) : Set ℓ where
  field
    print : A → String
open Print {{...}}  -- print : {{r : Print A}} → A → String

instance
  PrintBool : Print Bool
  print {{PrintBool}} true  = "true"
  print {{PrintBool}} false = "false"

  PrintString : Print String
  print {{PrintString}} x = x

testPrint : String
testPrint = (print true) ++ (print "a string")
```

# Monads

##

"To be is to do" --Socrates

"To do is to be" --Sartre

"Do be do be do" --Sinatra.

## Side effects in a pure language

Agda is a **pure** language: functions have no side effects

But a typechecker has many side effects:

- raise error messages
- read or write files
- maintain a state for declared variables

## Monads

`Monad` is a typeclass with two fields `return` and `_>>=_`.

`M A` ~ "computations that may have some side-effects (depending on M) and return an A"

Examples: `Maybe`, `Reader`, `Error`, `State`, ...

See [Library/Error.agda](https://jespercockx.github.io/ohrid19-agda/src/html/Library.Error.html)

## `do` notation

`do` is syntactic sugar for repeated binds: instead of

<!--
```
open import Data.Vec using (Vec)
open import Library hiding (All; IMonad; return; _>>=_)
module _ where
  open import Library hiding (All; IMonad)
```
-->

```
  _ : Maybe ℤ
  _ = (just (-[1+ 3 ])) >>= λ x →
      (just (+ 5)     ) >>= λ y →
      return (x + y)
```
you can write:
```
  _ : Maybe ℤ
  _ = do
    x ← just (-[1+ 3 ])
    y ← just (+ 5)
    return (x + y)
```

## Pattern matching with `do`

There can be a *pattern* to the left of a `←`, alternative cases can be handled in a local `where`

```
  pred : ℕ → Maybe ℕ
  pred n = do
    suc m ← just n
      where zero → nothing
    return m
```

## Dependent pattern matching with `do`

```
  postulate
    test : (m n : ℕ) → Maybe (m ≡ n)

  cast : (m n : ℕ) → Vec ℤ m → Maybe (Vec ℤ n)
  cast m n xs = do
    refl ← test m n
    return xs
```
Pattern matching allows typechecker to learn new facts!

## Type-checking expressions

See [V1/TypeChecker.agda](https://jespercockx.github.io/ohrid19-agda/src/html/V1/V1.TypeChecker.html).

Exercise: extend the typechecker with rules for the new syntactic constructions you added before


# Indexed monads

## Typechecking variable declarations

For type-checking variables, we need the following side-effects:

* For checking *expressions*: find variable with given name (⇒ read-only access)
* For checking *declarations*: add new variable with given name (⇒ read-write access)

How to ensure **statically** that each variable in scope has a name?

## The `All` type

For `P : A → Set` and `xs : List A`, `All P xs` associates an element of `P x` to each `x ∈ xs`:
```
data All {A : Set} (P : A → Set) : List A → Set where
  []  : All P []
  _∷_ : ∀ {x xs} → P x → All P xs → All P (x ∷ xs)
```

Name for each variable: `TCCxt Γ = All (\_ → Name) Γ`
Value for each variable: `Env Γ = All Val Γ`

## Adding new variables to the typechecking context

We need to *modify* both `Γ : Cxt` and `ρ : TCCxt Γ`!

Possible solutions:

- decouple names from the context?
- use state of type `Σ Cxt TCCxt`?
- **index** the monad by the context Γ!

## Indexed monads

An **indexed monad** = a monad with two extra parameters for the (static) *input* and *output* states

```
record IMonad {I : Set} (M : I → I → Set → Set) : Set₁ where
  field
    return : ∀ {A i} → A → M i i A
    _>>=_  : ∀ {A B i j k}
           → M i j A → (A → M j k B) → M i k B
```

Examples:

- `TCDecl` monad (see [V2/TypeChecker.agda](https://jespercockx.github.io/ohrid19-agda/src/html/V2/V2.TypeChecker.html)).
- `Exec` monad (see [V3/Interpreter.agda](https://jespercockx.github.io/ohrid19-agda/src/html/V3/V3.TypeChecker.html)).

# Haskell FFI

##

"Beware of bugs in the above code; I have only proved it correct, not tried it." -- Donald Knuth

<!--
```agda
module _ where

module FFI where
```
-->

## Why use an FFI?

## Haskell FFI example:

```haskell
  -- In file `While/V1/Abs.hs`:
  data Type = TBool | TInt
```
```agda
  -- In file `AST.agda`:
  {-# FOREIGN GHC import While.Abs #-}
  data Type : Set where
    bool int : Type

  {-# COMPILE GHC Type = data Type
    ( TBool
    | TInt
    ) #-}
```

## Haskell FFI: basics

Import a Haskell module:

```agda
  {-# FOREIGN GHC import HaskellModule.hs #-}
```

Bind Haskell function to Agda name:

<!--
```
  postulate AgdaType : Set
```
-->

```agda
  postulate agdaName : AgdaType
  {-# COMPILE GHC agdaName = haskellCode #-}
```

Bind Haskell datatype to Agda datatype:

```
  data D : Set where c₁ c₂ : D
  {-# COMPILE GHC D = data hsData (hsCon₁ | hsCon₂) #-}
```

## BNFC: the Backus-Naur Form Compiler

BNFC is a Haskell library for generating Haskell code from a grammar:

- Datatypes for abstract syntax
- Parser
- Pretty-printer

See [While.cf](https://jespercockx.github.io/ohrid19-agda/src/V1/While.cf) for the grammar of WHILE.

## Exercise

Extend the BNFC grammar with the new syntactic constructions you added.

Don't forget to update the Haskell bindings in [AST.agda](https://jespercockx.github.io/ohrid19-agda/src/V1/html/V1.AST.html)!

Testing the grammar: `make parser` will compile the parser and run it on [/test/gcd.c](https://jespercockx.github.io/ohrid19-agda/test/gcd.c).
