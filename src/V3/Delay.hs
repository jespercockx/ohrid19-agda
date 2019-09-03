
module Delay where

data Delay  i a = Delay (() -> Delay' i a)
data Delay' i a = Return a | Later (Delay i a)

runDelay :: () -> () -> Delay i a -> a
runDelay _ _ (Delay d) = case d () of
  (Return x) -> x
  (Later d ) -> runDelay () () d
