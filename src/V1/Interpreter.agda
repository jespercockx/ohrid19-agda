-- Interpreter for WHILE language.

-- As computation is not guaranteed to terminate,
-- execution of statements is placed in the Delay monad.

module V1.Interpreter where

open import Library
open import V1.WellTypedSyntax
open import V1.Value

-- Evaluation of expressions in fixed environment ρ.

eval : ∀{t} (e : Exp t) → Val t
eval (eInt  i)        = i
eval (eBool b)        = b
eval (eOp plus e₁ e₂) = eval e₁ + eval e₂
eval (eOp gt  e₁ e₂)  = iGt (eval e₁) (eval e₂)
eval (eOp and e₁ e₂)  = case eval e₁ of λ where
                          true  → eval e₂
                          false → false
eval (eCond e₁ e₂ e₃) = case eval e₁ of λ where
                          true  → eval e₂
                          false → eval e₃

-- Execution of the program (main loop).

runProgram : (prg : Program) → ℤ
runProgram (program e) =
  -- Evaluate the main expression to yield result.
  eval e
