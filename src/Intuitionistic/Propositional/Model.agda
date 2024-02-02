open import Cubical.Foundations.Prelude
open import Cubical.Foundations.HLevels
open import Cubical.Relation.Binary
open import Cubical.HITs.PropositionalTruncation
open import Cubical.HITs.PropositionalTruncation.Monad
open import Cubical.Data.Sum
open import Cubical.Data.Sigma
open import Cubical.Data.Empty
open import Cubical.Data.FinData
open import Intuitionistic.Propositional.Syntax

module Intuitionistic.Propositional.Model where

private
  variable
    ℓ ℓ' ℓ'' : Level

record IsModel (G : Type ℓ) (R : Rel G G ℓ') (_⊨_ : ∀ {n} → G → Formula n → Type ℓ'') : Type (ℓ-max (ℓ-suc ℓ) (ℓ-max (ℓ-suc ℓ') (ℓ-suc ℓ''))) where
  _⊭_ : ∀ {n} → G → Formula n → Type ℓ''
  Γ ⊭ f = (Γ ⊨ f) → ⊥
  field
    isInhabitedG : ∥ G ∥₁
    isPropValued⊨ : ∀ (Γ : G) {n} (A : Formula n) → isProp (Γ ⊨ A)
    isReflR : ∀ x → R x x
    isTransR : ∀ x y z → R x y → R y z → R x z
    varSound : ∀ {Γ Δ n} {x : Fin n} → Γ ⊨ (var x) → R Γ Δ → Δ ⊨ (var x)
    `∨Sound : ∀ {Γ n} {A B : Formula n} → Γ ⊨ (A `∨ B) ≡ ∥ (Γ ⊨ A) ⊎ (Γ ⊨ B) ∥₁
    `∧Sound : ∀ {Γ n} {A B : Formula n} → Γ ⊨ (A `∧ B) ≡ (Γ ⊨ A) × (Γ ⊨ B)
    `¬Sound : ∀ {Γ n} {A : Formula n} → Lift {j = ℓ-max ℓ ℓ'} (Γ ⊨ `¬ A) ≡ (∀ {Δ} → R Γ Δ → Δ ⊭ A)
    `→Sound : ∀ {Γ n} {A B : Formula n} → Lift {j = ℓ-max ℓ ℓ'} (Γ ⊨ (A `→ B)) ≡ (∀ {Δ} → R Γ Δ → Δ ⊨ A → Δ ⊨ B)

record Model (ℓ ℓ' ℓ'' : Level) : Type (ℓ-max (ℓ-suc ℓ) (ℓ-max (ℓ-suc ℓ') (ℓ-suc ℓ'')))  where
  field
    G : Type ℓ
    R : Rel G G ℓ'
    _⊨_ : ∀ {n} → G → Formula n → Type ℓ''
    isModel : IsModel G R _⊨_
  open IsModel isModel public


module _ (M : Model ℓ ℓ' ℓ'') where
  open Model M
  isValidInModel : ∀ {n} → Formula n → Type (ℓ-max ℓ ℓ'')
  isValidInModel {n} form = ∀ (Γ : G) → Γ ⊨ form

  isPropIsValidInModel : ∀ {n} → (f : Formula n) → isProp (isValidInModel f)
  isPropIsValidInModel {n} f = isPropΠ λ Γ → isPropValued⊨ Γ f

  evidenceTransport : ∀ {Γ Δ n} → (X : Formula n) → Γ ⊨ X → R Γ Δ → Δ ⊨ X
  evidenceTransport {Γ} {Δ} {n} (var x) Γ⊨X RΓΔ = varSound Γ⊨X RΓΔ
  evidenceTransport {Γ} {Δ} {n} X@(`¬ Y) Γ⊨X RΓΔ = {!`¬Sound !}
  evidenceTransport {Γ} {Δ} {n} X@(A `∧ B) Γ⊨X RΓΔ =
    transport
      (sym (`∧Sound {Γ = Δ} {A = A} {B = B}))
      (evidenceTransport A (fst (transport (`∧Sound {Γ = Γ} {A = A} {B = B}) Γ⊨X)) RΓΔ ,
       evidenceTransport B (snd (transport (`∧Sound {Γ = Γ} {A = A} {B = B}) Γ⊨X)) RΓΔ)
  evidenceTransport {Γ} {Δ} {n} X@(A `∨ B) Γ⊨X RΓΔ =
    transport
      (sym (`∨Sound {Γ = Δ} {A = A} {B = B}))
      (transport (`∨Sound {Γ = Γ} {A = A} {B = B}) Γ⊨X >>=
        λ { (inl Γ⊨A) → ∣ inl (evidenceTransport A Γ⊨A RΓΔ) ∣₁
          ; (inr Γ⊨B) → ∣ inr (evidenceTransport B Γ⊨B RΓΔ) ∣₁ }) 
  evidenceTransport {Γ} {Δ} {n} X@(A `→ B) Γ⊨X RΓΔ =
    {!!}
