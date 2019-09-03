
record Stream (A : Set) : Set where
  coinductive
  field
    head : A
    tail : Stream A
open Stream

variable A : Set

repeat : A → Stream A
head (repeat x) = x
tail (repeat x) = repeat x

data Coℕ : Set
record Coℕ' : Set

data Coℕ where
  zero : Coℕ
  suc  : Coℕ' → Coℕ

record Coℕ' where
  coinductive
  field
    force : Coℕ
open Coℕ'

∞' : Coℕ'
force ∞' = suc ∞'

open import Data.Nat using (ℕ)

injectℕ : ℕ → Coℕ
injectℕ x = {!!}
