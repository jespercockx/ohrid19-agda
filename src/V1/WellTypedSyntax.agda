-- Intrinsically well-typed WHILE syntax.

module V1.WellTypedSyntax where

open import Library
open import V1.AST public using (Type; bool; int; Boolean; true; false; PrintBoolean)

-- Binary Operators.

data Op : (dom codom : Type) → Set where
  plus  : Op int  int
  gt    : Op int  bool
  and   : Op bool bool

-- Well-typed expressions: context is fixed.

data Exp : Type → Set where
  -- Literals:
  eInt  : (i : ℤ)                               → Exp int
  eBool : (b : Boolean)                         → Exp bool
  -- Operators:
  eOp   : ∀{t t'} (op : Op t t') (e e' : Exp t) → Exp t'
  -- Conditionals:
  eCond : ∀{t} (e : Exp bool) (e' e'' : Exp t)  → Exp t

-- For now, a program is just a final expression.

record Program : Set where
  constructor program
  field
    theMain  : Exp int

open Program public


-- -}
