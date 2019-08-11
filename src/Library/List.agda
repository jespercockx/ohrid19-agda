
open import Data.List
open import Data.Product

open import Level

open import Library.Eq

open import Relation.Binary using (Decidable; Rel)
open import Relation.Binary.PropositionalEquality
open import Relation.Nullary

module Library.List where

open import Data.List.Base public using (List; []; _∷_; foldl)
open import Data.List.All public using (All; []; _∷_) hiding (module All)

-- Non-dependent association lists

AssocList : ∀{a b} {A : Set a} (B : Set b) (xs : List A) → Set (a ⊔ b)
AssocList B xs = All (λ _ → B) xs

module _ {a b} {A : Set a} {B : Set b} where

  -- Cons for non-dependent association lists.

  _↦_∷_ : ∀ (x : A) (v : B) {xs} (vs : AssocList B xs) → AssocList B (x ∷ xs)
  x ↦ v ∷ vs = _∷_ {x = x} v vs
