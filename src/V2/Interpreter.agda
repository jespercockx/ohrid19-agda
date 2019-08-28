-- Interpreter for WHILE language.

-- As computation is not guaranteed to terminate,
-- execution of statements is placed in the Delay monad.

module V2.Interpreter where

open import Library
open import V2.WellTypedSyntax
open import V2.Value

-- Evaluation of expressions in fixed environment ρ.

module EvalExp {Γ} (ρ : Env Γ) where

  eval : ∀{t} (e : Exp Γ t) → Val t
  eval (eInt  i)        = i
  eval (eBool b)        = b
  eval (eVar x)         = lookupEnv ρ x
  eval (eOp plus e₁ e₂) = eval e₁ + eval e₂
  eval (eOp gt  e₁ e₂)  = iGt (eval e₁) (eval e₂)
  eval (eOp and e₁ e₂)  = case eval e₁ of λ where
    true  → eval e₂
    false → false
  eval (eCond e₁ e₂ e₃) = case eval e₁ of λ where
    true  → eval e₂
    false → eval e₃

open EvalExp

-- Execution of declarations, extending the environment.

execDecl : ∀{Γ t} (d : Decl Γ t) (ρ : Env Γ) → Env (t ∷ Γ)
execDecl (dInit e) ρ = eval ρ e ∷ ρ

execDecls : ∀{Γ Γ'} (ds : Decls Γ Γ') (ρ : Env Γ) → Env Γ'
execDecls []       ρ = ρ
execDecls (d ∷ ds) ρ = execDecls ds (execDecl d ρ)

-- Execution of the program (main loop).

runProgram : (prg : Program) → ℤ
runProgram (program ds e) =

  -- Execute the declarations to get the initial environment ρ.
  let ρ = execDecls ds [] in

  -- Evaluate the main expression to yield result.
  EvalExp.eval ρ e
