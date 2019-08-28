-- Type checker for the WHILE language.

{-# OPTIONS --postfix-projections #-}

module V1.TypeChecker where

open import Library

import V1.AST as A
open import V1.WellTypedSyntax

-- Type errors.
--
-- Currently, these errors do not carry enough evidence that
-- something is wrong.  The type checker does not produce
-- evidence of ill-typedness in case of failure,
-- only of well-typedness in case of success.

data TypeError : Set where
  typeMismatch : (tinf texp : Type)  → tinf ≢ texp → TypeError

instance
  PrintError : Print TypeError
  print {{PrintError}} = λ where
    (typeMismatch tinf texp _) → String.concat $
      "type mismatch: expected " ∷ print texp ∷
      ", but inferred " ∷ print tinf ∷ []

-- Type error monad.

open ErrorMonad {E = TypeError}

-- Checking expressions
---------------------------------------------------------------------------

mutual

  -- Type inference.

  inferExp : (e : A.Exp) → Error (Σ Type (λ t → Exp t))
  inferExp (A.eInt i)  = return (int  , eInt  i)
  inferExp (A.eBool b) = return (bool , eBool b)
  inferExp (A.ePlus e₁ e₂) = inferOp plus  e₁ e₂
  inferExp (A.eGt   e₁ e₂) = inferOp gt    e₁ e₂
  inferExp (A.eAnd  e₁ e₂) = inferOp and   e₁ e₂
  inferExp (A.eCond e₁ e₂ e₃) = do
    e₁' ← checkExp e₁ bool
    (t , e₂') ← inferExp e₂
    e₃' ← checkExp e₃ t
    return (t , eCond e₁' e₂' e₃')

  -- Type checking.
  -- Calls inference and checks inferred type against given type.

  checkExp : (e : A.Exp) (t : Type) → Error (Exp t)
  checkExp e t = do
    (t' , e') ← inferExp e
    case t' ≟ t of λ where
      (yes refl) → return e'
      (no  t'≢t) → throwError (typeMismatch t' t t'≢t)

  -- Operators.

  inferOp : ∀{t t'} (op : Op t t') (e₁ e₂ : A.Exp) → Error (Σ Type (λ t → Exp t))
  inferOp {t} {t'} op e₁ e₂ = do
    e₁' ← checkExp e₁ t
    e₂' ← checkExp e₂ t
    return (t' , eOp op e₁' e₂')

-- Checking the program.
---------------------------------------------------------------------------

checkProgram : (prg : A.Program) → Error Program
checkProgram (A.program e) = do
  e' ← checkExp e int
  return $ program e'


-- -}
-- -}
-- -}
-- -}
-- -}
-- -}
