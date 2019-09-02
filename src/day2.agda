
open import Data.Nat

data Vec (A : Set) : ℕ → Set where
  []  : Vec A 0
  _∷_ : ∀ {n} → A → Vec A n → Vec A (suc n)

data Fin : ℕ → Set where
  zero : {n : ℕ} → Fin (suc n)
  suc  : {n : ℕ} → Fin n → Fin (suc n)

test : Fin 5
test = suc (suc (suc zero))

Fin0-empty : {A : Set} → Fin 0 → A
Fin0-empty ()

private
  variable m n : ℕ

module Vectors {A : Set} where

  head : Vec A (suc n) → A
  head (x ∷ xs) = x

  tail : Vec A (suc n) → Vec A n
  tail (x ∷ xs) = xs

  _++_ : Vec A m → Vec A n → Vec A (m + n)
  [] ++ ys = ys
  (x ∷ xs) ++ ys = x ∷ (xs ++ ys)

  lookup : Vec A n → Fin n → A
  lookup [] ()
  lookup (x ∷ xs) zero = x
  lookup (x ∷ xs) (suc i) = lookup xs i

open Vectors public
