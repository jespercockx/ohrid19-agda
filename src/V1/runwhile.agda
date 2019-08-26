-- Type checker and interpreter for WHILE language.

module V1.runwhile where

open import Library
open import V1.WellTypedSyntax using (Program)
open import V1.TypeChecker     using (checkProgram)

import V1.AST as A
import V1.Parser as Parser
open import V1.Interpreter using (runProgram)

-- Other modules, not used here.
import V1.Value
import V1.UntypedInterpreter

-- Parse.

parse : String → IO A.Program
parse contents = case Parser.parse contents of λ where
    (bad cs) → do
      putStrLn "SYNTAX ERROR"
      putStrLn (String.fromList cs)
      exitFailure
    (ok prg) → return prg
  where
    open Parser using (Err; ok; bad)

-- Type check.

check : A.Program → IO Program
check prg = case checkProgram prg of λ where
    (fail err) → do
      putStrLn "TYPE ERROR"
      putStr   (print prg)
      putStrLn "The type error is:"
      putStrLn (print err)
      exitFailure
    (ok prg') → return prg'
  where
    open ErrorMonad using (fail; ok)

-- Interpret.

run : Program → IO ⊤
run prg' = putStrLn (print (runProgram prg'))

-- Display usage information and exit.

usage : IO ⊤
usage = do
  putStrLn "Usage: runwhile <SourceFile>"
  exitFailure

-- Parse command line argument and send file content through pipeline.

runwhile : IO ⊤
runwhile = do
  file ∷ [] ← getArgs
    where _ → usage
  run =<< check =<< parse =<< readFiniteFile file
  return _

main = runwhile


-- -}
