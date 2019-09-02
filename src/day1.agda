
data ℕ : Set where
  zero : ℕ
  suc : ℕ → ℕ

_+_ : ℕ → ℕ → ℕ
zero  + y = y
suc x + y = suc (x + y)

data List (A : Set) : Set where
  []  : List A
  _∷_ : A → List A → List A

data Maybe (A : Set) : Set where
  just : A → Maybe A
  nothing : Maybe A

lookup : {A : Set} → List A → ℕ → Maybe A
lookup [] _ = nothing
lookup (x ∷ xs) zero = just x
lookup (x ∷ xs) (suc i) = lookup xs i

infixl 10 _++_
_++_ : {A : Set} → List A → List A → List A
[]       ++ ys = ys
(x ∷ xs) ++ ys = x ∷ (xs ++ ys)
