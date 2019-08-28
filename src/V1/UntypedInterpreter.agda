-- Untyped interpreter for the WHILE language.
--
-- * Runs directly on the unchecked abstract syntax tree.
-- * May fail due to scope and other runtime errors.
-- * while loops may not terminate.

module V1.UntypedInterpreter where

open import Library
open import V1.AST

-- Untyped values.

data Val : Set where
  intV  : ℤ       → Val
  boolV : Boolean → Val

instance
  PrintVal : Print Val
  print {{PrintVal}} = λ where
    (intV i)  → print i
    (boolV b) → print b

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

-- Evaluation may fail due to type errors, thus eval is partial.
-- E.g. eval (eNot (eInt zero)) ≡ nothing.

eval : Exp → Maybe Val
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

evalPrg : Program → Maybe ℤ
evalPrg (program e) = case eval e of λ where
    (just (intV v)) → just v
    _               → nothing
