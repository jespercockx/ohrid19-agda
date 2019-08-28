-- Intrinsically well-typed WHILE syntax.

module V2.WellTypedSyntax where

open import Library
open import V2.AST public using (Type; bool; int; Boolean; true; false; PrintBoolean)

-- Variables are de Bruijn indices into the context, a list of types.

Cxt = List Type

data Var : (Γ : Cxt) (t : Type) → Set where
  here  : ∀ {Γ t} → Var (t ∷ Γ) t
  there : ∀ {Γ t t'} → Var Γ t → Var (t' ∷ Γ) t

-- Binary Operators.

data Op : (dom codom : Type) → Set where
  plus  : Op int  int
  gt    : Op int  bool
  and   : Op bool bool

-- Well-typed expressions: context is fixed.

data Exp (Γ : Cxt) : Type → Set where
  -- Literals:
  eInt  : (i : ℤ)                                  → Exp Γ int
  eBool : (b : Boolean)                            → Exp Γ bool
  -- Operators:
  eOp   : ∀{t t'} (op : Op t t') (e e' : Exp Γ t)  → Exp Γ t'
  -- Conditionals:
  eCond : ∀{t} (e : Exp Γ bool) (e' e'' : Exp Γ t) → Exp Γ t
  -- Variables:
  eVar  : ∀{t}    (x : Var Γ t)                    → Exp Γ t
-- Well-typed declarations (extending the context).

data Decl (Γ : Cxt) (t : Type) : Set where
  dInit : (e : Exp Γ t) → Decl Γ t

data Decls (Γ : Cxt) : Cxt → Set where
  []  : Decls Γ Γ
  _∷_ : ∀{t Γ′} (s : Decl Γ t) (ss : Decls (t ∷ Γ) Γ′) → Decls Γ Γ′

-- A program is a list of statements and a final expression.

record Program : Set where
  constructor program
  field
    {Γ}      : Cxt
    theDecls : Decls [] Γ
    theMain  : Exp Γ int

open Program public


-- -}
