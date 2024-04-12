module Fin.Properties where

open import Data.Fin.Base
open import Data.Fin.Properties
open import Data.Fin.Patterns
open import Data.Nat as ℕ using (ℕ; z≤n; s≤s; _∸_)
open import Relation.Binary.PropositionalEquality

private variable
  m n : ℕ

toℕ-reduce≥ : ∀ (i : Fin (m ℕ.+ n)) (m≤n : m ℕ.≤ toℕ i) → toℕ (reduce≥ i m≤n) ≡ toℕ i ∸ m
toℕ-reduce≥ {ℕ.zero} i z≤n = refl
toℕ-reduce≥ {ℕ.suc m} (suc i) (s≤s m≤i) rewrite toℕ-reduce≥ i m≤i = refl