open import Cubical.Foundations.Prelude
open import Cubical.Data.FinData
open import Cubical.Data.Nat

-- Single sorted propositional intuitionistic logic
module Intuitionistic.Propositional.Syntax where

data Formula (n : ℕ) : Type where
  var : Fin n → Formula n
  `¬ : Formula n → Formula n
  _`∧_ : Formula n → Formula n → Formula n
  _`∨_ : Formula n → Formula n → Formula n
  _`→_ : Formula n → Formula n → Formula n
