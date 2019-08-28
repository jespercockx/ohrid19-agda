-- Untyped interpreter for the WHILE language.
--
-- * Runs directly on the unchecked abstract syntax tree.
-- * May fail due to scope and other runtime errors.
-- * while loops may not terminate.

module V2.UntypedInterpreter where

open import Library
open import V2.AST

-- Untyped values.

data Val : Set where
  intV  : ℤ       → Val
  boolV : Boolean → Val

instance
  PrintVal : Print Val
  print {{PrintVal}} = λ where
    (intV i)  → print i
    (boolV b) → print b

-- Poor man's environments (association list).

Env : Set
Env = List (Id × Val)

-- Looking up the value bound to a variable in an environment.

lookupId : Env → Id → Maybe Val
lookupId []             y = nothing
lookupId ((x , v) ∷ xs) y =
  if x == y
  then just v
  else lookupId xs y

-- Adding or updating a binding in the environment.

updateEnv : Id → Val → Env → Env
updateEnv x v []            = (x , v) ∷ []
updateEnv x v ((y , w) ∷ ρ) =
  if x == y
  then (x , v) ∷ ρ
  else (y , w) ∷ updateEnv x v ρ

-- -- Poor man's version, keeps history of bindings.
-- updateEnv x v ρ = (x , v) ∷ ρ
-- updateEnv : Id → Val → Env → Env

-- Semantics of operations.

-- Boolean negation.

bNot : Boolean → Boolean
bNot true = false
bNot false = true

-- Boolean conjunction.

bAnd : Boolean → Boolean → Boolean
bAnd true  b = b
bAnd false _ = false

-- Boolean conditional

bIf : {A : Set} → Boolean → A → A → A
bIf true  x y = x
bIf false x y = y

-- Greater-than on integers.

iGt : (i j : ℤ) → Boolean
iGt i j = case i Integer.<= j of λ where
  false → true
  true  → false

-- Evaluation of expressions.  The environment is fixed.

module EvalExp (ρ : Env) where

  -- Evaluation may fail due to scope or type errors, thus eval is partial.
  -- E.g. eval (eNot (eInt zero)) ≡ nothing.

  eval : Exp → Maybe Val
  eval (eId x)   = lookupId ρ x
  eval (eInt i)  = just (intV i)
  eval (eBool b) = just (boolV b)
  eval (ePlus e₁ e₂) = case (eval e₁ , eval e₂) of λ where
    (just (intV i) , just (intV j)) → just (intV (i + j))
    _ → nothing
  eval (eGt e₁ e₂) = case (eval e₁ , eval e₂) of λ where
    (just (intV i) , just (intV j)) → just (boolV (iGt i j))
    _ → nothing
  eval (eAnd e₁ e₂) = case (eval e₁ , eval e₂) of λ where
    (just (boolV b₁) , just (boolV b₂)) → just (boolV (bAnd b₁ b₂))
    _ → nothing
  eval (eCond e₁ e₂ e₃) = case (eval e₁) of λ where
    (just (boolV b)) → bIf b (eval e₂) (eval e₃)
    _ → nothing


open EvalExp

-- The execution of a declaration adds a new binding
-- to the environment.

execDecl : Decl → Env → Maybe Env
execDecl (dInit t x e) ρ = case eval ρ e of λ where
  (just v) → just ((x , v) ∷ ρ)
  nothing  → nothing

-- Execution of declarations returns the extended environment.

execDecls : List Decl → Env → Maybe Env
execDecls [] ρ = just ρ
execDecls (d ∷ ds) ρ = case execDecl d ρ of λ where
  (just ρ') → execDecls ds ρ'
  nothing   → nothing

-- We evaluate a program by first executing the declarations,
-- and then evaluating the main expression.

evalPrg : Program → Maybe ℤ
evalPrg (program ds e) = case execDecls ds [] of λ where
  (just ρ) → case eval ρ e of λ where
    (just (intV v)) → just v
    _               → nothing
  nothing   → nothing
