open import Algebra
open import Algebra.Apartness
open import Algebra.DecidableField

module Algebra.Module.ConcreteDefinition {c ℓ₁} (HCR : DecidableField c ℓ₁ ℓ₁) where

open import Level
open import Function
open import Data.Nat hiding (_+_; _*_; _⊔_)
open import Data.Fin using () renaming (suc to fsuc)
open import Data.Empty.Polymorphic
open import Data.Product
open import Data.Unit.Polymorphic
open import Data.Vec.Functional
open import Data.Fin.Patterns
open import Algebra.Matrix.Structures
open import Relation.Nullary.Negation.Core

open DecidableField HCR renaming (Carrier to A) hiding (sym)
open import Algebra.HeytingCommutativeRing.Properties heytingCommutativeRing
open import Algebra.Apartness.Properties.HeytingCommutativeRing heytingCommutativeRing
open CommutativeRing commutativeRing using (ring; sym)
open Ring ring using (rawRing)
open import Algebra.Module.Instances.FunctionalVector ring
import Algebra.Module.Definition as MDef'
open import Relation.Binary.Reasoning.Setoid setoid

open module MDef {n} = MDef' (leftModule n)

open MRing rawRing hiding (0ᴹ)

private variable
  m n : ℕ


AreCollinear : (xs ys : Vector A n) → Set ℓ₁
AreCollinear {0} xs ys = ⊥
AreCollinear {1} xs ys = ⊤
AreCollinear {2} xs ys = xs 0F * ys 1F ≈ xs 1F * ys 0F
AreCollinear {2+ (suc n)} xs ys = xs 0F * ys 1F ≈ xs 1F * ys 0F × AreCollinear (tail xs) (tail ys)

AreNotCollinear : (xs ys : Vector A n) → Set ℓ₁
AreNotCollinear {0} xs ys = ⊤
AreNotCollinear {1} xs ys = ⊥
AreNotCollinear {2+ n} xs ys = AreCollinear (tail xs) (tail ys) → xs 0F * ys 1F # xs 1F * ys 0F

IsCLinearIndependent : Matrix A n m → m ≤ 3 → Set ℓ₁
IsCLinearIndependent {0} {0} xs z≤n = ⊤
IsCLinearIndependent {suc n} {0} xs z≤n = ⊥
IsCLinearIndependent {0} {1} xs (s≤s z≤n) = ⊤
IsCLinearIndependent {1} {1} xs (s≤s z≤n) = xs 0F 0F # 0#
IsCLinearIndependent {2+ _} {1} xs (s≤s z≤n) = ⊥
IsCLinearIndependent {0} {2} xs (s≤s (s≤s z≤n)) = ⊤
IsCLinearIndependent {1} {2} xs (s≤s (s≤s z≤n)) = xs 0F 0F # 0#
IsCLinearIndependent {2} {2} xs (s≤s (s≤s z≤n)) = xs 0F 0F * xs 1F 1F # xs 0F 1F * xs 1F 0F
IsCLinearIndependent {2+ (suc _)} {2} xs (s≤s (s≤s z≤n)) = ⊥
IsCLinearIndependent {0} {3} xs (s≤s (s≤s (s≤s z≤n))) = ⊤
IsCLinearIndependent {1} {3} xs (s≤s (s≤s (s≤s z≤n))) = xs 0F 0F # 0#
IsCLinearIndependent {2} {3} xs (s≤s (s≤s (s≤s z≤n))) = AreNotCollinear (xs 0F) (xs 1F)
IsCLinearIndependent {3} {3} xs (s≤s (s≤s (s≤s z≤n))) = let
  -- Determinant different than zero
  a = xs 0F 0F; b = xs 0F 1F; c = xs 0F 2F
  d = xs 1F 0F; e = xs 1F 0F; f = xs 1F 2F
  g = xs 2F 0F; h = xs 2F 0F; i = xs 2F 2F
  in a * (e * i - h * f) - b * (d * i - g * f) + c * (d * h - e * g) # 0#
IsCLinearIndependent {2+ (2+ n)} {3} xs (s≤s (s≤s (s≤s z≤n))) = ⊥


IsCInd⇒Ind : (xs : Matrix A n m) (m≤3 : m ≤ 3) → IsCLinearIndependent xs m≤3 → IsLinearIndependent xs
IsCInd⇒Ind {1} {1} xs (s≤s z≤n) cLin ∑≈0 0F =
  x#0*y≈0⇒y≈0 cLin (trans (*-comm _ _) (trans (sym (+-identityʳ _)) (∑≈0 0F)))
IsCInd⇒Ind {1} {2} xs (s≤s (s≤s z≤n)) cLin ∑≈0 0F =
  x#0*y≈0⇒y≈0 cLin (trans (*-comm _ _) (trans (sym (+-identityʳ _)) (∑≈0 0F)))
IsCInd⇒Ind {2} {2} xs (s≤s (s≤s z≤n)) cLin {ys} ∑≈0 0F = {!!}
  where
  open *-solver

  help₁ = begin
    xs 1F 1F * xs 0F 0F * ys 0F + ys 1F * xs 1F 0F * xs 1F 1F
      ≈⟨ +-cong (solve 3 (λ a b c → a ⊕ b ⊕ c , a ⊕ (c ⊕ b)) refl _ _ _)
                (solve 3 (λ a b c → a ⊕ b ⊕ c , c ⊕ (a ⊕ b)) refl _ _ _) ⟩
    xs 1F 1F * (ys 0F * xs 0F 0F) + xs 1F 1F * (ys 1F * xs 1F 0F) ≈˘⟨ distribˡ _ _ _ ⟩
    xs 1F 1F * (ys 0F * xs 0F 0F + ys 1F * xs 1F 0F)
      ≈⟨ *-congˡ {x = xs 1F 1F} (trans (sym (+-congˡ (+-identityʳ _))) (∑≈0 0F)) ⟩
    _ * 0# ≈⟨ zeroʳ _ ⟩
    0# ∎

  help₂ : xs 1F 0F * (ys 0F * xs 0F 1F + ys 1F * xs 1F 1F) ≈ 0#
  help₂ = trans (*-congˡ (trans (sym (+-congˡ (+-identityʳ _))) (∑≈0 1F))) (zeroʳ _)

IsCInd⇒Ind {2} {2} xs (s≤s (s≤s z≤n)) cLin ∑≈0 1F = {!!}

IsCInd⇒Ind {1} {3} xs (s≤s (s≤s (s≤s z≤n))) cLin ∑≈0 0F =
  x#0*y≈0⇒y≈0 cLin (trans (*-comm _ _) (trans (sym (+-identityʳ _)) (∑≈0 0F)))
IsCInd⇒Ind {2} {3} xs (s≤s (s≤s (s≤s z≤n))) cLin ∑≈0 i = {!!}
IsCInd⇒Ind {3} {3} xs (s≤s (s≤s (s≤s z≤n))) cLin ∑≈0 i = {!!}
