-- The delay monad for potentially non-terminating computation.

module V3.Delay where

open import Library

-- Coinductive delay monad.

mutual

  record Delay (i : Size) (A : Set) : Set where
    coinductive
    constructor delay
    field
      force : {j : Size< i} → Delay' j A

  data Delay' (i : Size) (A : Set) : Set where
    return' : A         → Delay' i A
    later'  : Delay i A → Delay' i A

open Delay public

{-# FOREIGN GHC import Delay #-}
{-# COMPILE GHC Delay = data Delay ( Delay ) #-}
{-# COMPILE GHC Delay' = data Delay' ( Return | Later ) #-}

postulate runDelay : ∀ {i} {A : Set} → Delay i A → A
{-# COMPILE GHC runDelay = \_ _ -> runDelay #-}

-- Smart constructor.

later : ∀ {A i} → Delay i A → Delay (↑ i) A
force (later x) = later' x

-- Example: non-termination.

never : ∀ {A i} → Delay A i
force never = later' never

-- Monad instance.

private
  returnDelay : ∀{A i} → A → Delay i A
  force (returnDelay a) = return' a

  bindDelay : ∀ {i A B} → Delay i A → (A → Delay i B) → Delay i B
  bindDelay m k .force = case m .force of λ where
    (return' a) → k a .force
    (later' m') → later' (bindDelay m' k)

instance
  functorDelay : ∀ {i} → Functor (Delay i)
  fmap {{functorDelay}} f mx = bindDelay mx (λ x → returnDelay (f x))

  applicativeDelay : ∀ {i} → Applicative (Delay i)
  pure  {{applicativeDelay}}       = returnDelay
  _<*>_ {{applicativeDelay}} mf mx = bindDelay mf (_<$> mx)

  monadDelay : ∀ {i} → Monad (Delay i)
  _>>=_ {{monadDelay}} = bindDelay

-- -}
-- -}
-- -}
-- -}
-- -}
