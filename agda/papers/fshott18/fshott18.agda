-- The content of this file is based on:
-- "Finite Sets in Homotopy Type Theory" by
-- Dan Frumin, Herman Geuvers, Léon Gondelman, and Niels van der Weide

{-# OPTIONS --cubical #-}

module fshott18 where

open import Cubical renaming (_∨_ to _⊔_ ; _∧_ to _⊓_)
open import Data.Empty
open import Data.Unit
open import Data.Sum
open import Data.Product

data ∥_∥ (A : Set) : Set where
  elt   : A → ∥ A ∥
  trunc : ∀ x y → elt x ≡ elt y

_∨_ : (A B : Set) → Set
A ∨ B = ∥ A ⊎ B ∥

_∧_ : (A B : Set) → Set
A ∧ B = ∥ A × B ∥

module _ {A B : Set} where

  ∨-comm : A ∨ B → B ∨ A
  ∨-comm (elt (inj₁ a)) = elt (inj₂ a)
  ∨-comm (elt (inj₂ b)) = elt (inj₁ b)
  ∨-comm (trunc (inj₁ a₁) (inj₁ a₂) i) = trunc (inj₂ a₁) (inj₂ a₂) i
  ∨-comm (trunc (inj₁ a₁) (inj₂ b₂) i) = trunc (inj₂ a₁) (inj₁ b₂) i
  ∨-comm (trunc (inj₂ b₁) (inj₁ a₂) i) = trunc (inj₁ b₁) (inj₂ a₂) i
  ∨-comm (trunc (inj₂ b₁) (inj₂ b₂) i) = trunc (inj₁ b₁) (inj₁ b₂) i

  ∧-comm : A ∧ B → B ∧ A
  ∧-comm (elt (a , b))                 = elt (b , a)
  ∧-comm (trunc (a₁ , b₁) (a₂ , b₂) i) = trunc (b₁ , a₁) (b₂ , a₂) i

  ∧-× : A ∧ B → ∥ A ∥ × ∥ B ∥
  ∧-× (elt (a , b))                 = elt a , elt b
  ∧-× (trunc (a₁ , b₁) (a₂ , b₂) i) = trunc a₁ a₂ i , trunc b₁ b₂ i

infixr 6 _∪_
data K (A : Set) : Set where
  ⊘     : K A
  ⟨_⟩   : A → K A
  _∪_   : K A → K A → K A
  Knl    : ∀ x → ⊘ ∪ x ≡ x
  Knr    : ∀ x → x ∪ ⊘ ≡ x
  Kidem  : ∀ x → ⟨ x ⟩ ∪ ⟨ x ⟩ ≡ ⟨ x ⟩
  Kassoc : ∀ x y z → x ∪ (y ∪ z) ≡ (x ∪ y) ∪ z
  Kcomm  : ∀ x y → x ∪ y ≡ y ∪ x
  Ktrunc : ∀ x y (p q : x ≡ y) → p ≡ q

infixr 6 _∷_
data L (A : Set) : Set where
  []    : L A
  _∷_   : A → L A → L A
  Ldupl  : ∀ x xs → x ∷ x ∷ xs ≡ x ∷ xs
  Lcomm  : ∀ x y xs → x ∷ y ∷ xs ≡ y ∷ x ∷ xs
  Ltrunc : ∀ x y (p q : x ≡ y) → p ≡ q

module _ {A : Set} where

  union-idem : (x : K A) → x ∪ x ≡ x
  union-idem ⊘                     = Knl ⊘
  union-idem ⟨ x ⟩                = Kidem x
  union-idem (x ∪ y)              = begin
   (x ∪ y) ∪ x ∪ y   ≡⟨ Kassoc (x ∪ y) x y ⟩
   ((x ∪ y) ∪ x) ∪ y ≡⟨ cong (λ s → (s ∪ x) ∪ y) (Kcomm x y) ⟩
   ((y ∪ x) ∪ x) ∪ y ≡⟨ cong (_∪ y) (sym (Kassoc y x x)) ⟩
   (y ∪ x ∪ x) ∪ y   ≡⟨ cong (λ s → (y ∪ s) ∪ y) (union-idem x) ⟩
   (y ∪ x) ∪ y       ≡⟨ cong (_∪ y) (Kcomm y x) ⟩
   (x ∪ y) ∪ y       ≡⟨ sym (Kassoc x y y) ⟩
   x ∪ y ∪ y         ≡⟨ cong (x ∪_) (union-idem y) ⟩
   x ∪ y             ∎
  union-idem (Knl x i)            = {!!}
  union-idem (Knr x i)            = {!!}
  union-idem (Kidem x i)          = {!!}
  union-idem (Kassoc x y z i)     = {!!}
  union-idem (Kcomm x y i)        = {!!}
  union-idem (Ktrunc x y p q i j) = {!!}

{-
  _∈_ : (a : A) → K A → Set
  a ∈ ⊘                 = ⊥
  a ∈ ⟨ x ⟩             = ∥ a ≡ x ∥
  a ∈ (x ∪ y)           = {!!}
  a ∈ nl x i            = {!!}
  a ∈ nr x i            = {!!}
  a ∈ idem x i          = {!!}
  a ∈ assoc x y z i     = {!!}
  a ∈ comm x y i        = {!!}
  a ∈ trunc x y p q i j = {!!}
-}
