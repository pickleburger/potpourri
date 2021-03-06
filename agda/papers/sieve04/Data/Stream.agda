module papers.sieve04.Data.Stream where

open import Level
open import Size
open import Data.Empty
open import Relation.Nullary
open import Data.Product as P hiding (map)
open import Function

record Stream {ℓ} (A : Set ℓ) (i : Size) : Set ℓ where
  constructor _∷_
  coinductive
  field
    head : A
    tail : {j : Size< i} → Stream A j
open Stream public

module _ {ℓ} {A : Set ℓ} where

  unfold : ∀ {ℓ′} {S : Set ℓ′} → (S → A × S) → S → ∀ {i} → Stream A i
  head (unfold next seed) = proj₁ $ next seed
  tail (unfold next seed) = unfold next (proj₂ $ next seed)

  pure : A → Stream A ∞
  pure a = unfold (λ a → (a , a)) a

  data In : (a : A) (xs : Stream A ∞) → Set ℓ where
    here  : ∀ {xs} →                    In (head xs) xs
    there : ∀ {a xs} → In a (tail xs) → In a         xs

module _ {ℓ ℓ′} {A : Set ℓ} {B : Set ℓ′} where

  app : ∀ {i} → Stream (A → B) i → Stream A i → Stream B i
  head (app fs as) = head fs $ head as
  tail (app fs as) = app (tail fs) (tail as)

  map : (A → B) → ∀ {i} → Stream A i → Stream B i
  map f s = app (pure f) s

module _ {ℓ ℓ′} {A : Set ℓ} (P : A → Set ℓ′) where

  data ⋄ : ∀ {i} (s : Stream A i) → Set (ℓ ⊔ ℓ′) where
    now   : ∀ {a i} {s : Stream A i} → P a           → ⋄ (a ∷ s)
    later : ∀ {a i} {s : Stream A i} → ¬ (P a) → ⋄ s → ⋄ (a ∷ s)

  record □ {i} (s : Stream A i) : Set (ℓ ⊔ ℓ′) where
    coinductive
    field
      Phead : P (head s)
      Ptail : ∀ {j : Size< i} → □ {j} (tail s)
  open □ public

  record Infinite {i} (s : Stream A i) : Set (ℓ ⊔ ℓ′) where
    coinductive
    field
      ⋄here : ⋄ {i} s
      □tail : ∀ {j : Size< i} → Infinite {j} (tail s)
  open Infinite public

module _ {ℓ ℓ′} {A : Set ℓ} {P : A → Set ℓ′} where

  filter  : (s : Stream A ∞) → Infinite P s         → Stream A ∞
  filter⋄ : (s : Stream A ∞) → Infinite P s → ⋄ P s → Stream A ∞

  filter s inf = filter⋄ s inf (⋄here inf)

  head (filter⋄ s inf (now _)) = head s
  tail (filter⋄ s inf (now _)) = filter (tail s) (□tail inf)
  filter⋄ s inf (later _ di)   = filter⋄ (tail s) (□tail inf) di

module _ {ℓ ℓ′ ℓ′′} {A : Set ℓ} {P : A → Set ℓ′} {Q : A → Set ℓ′′} where

  filter-□  : {s : Stream A ∞} (inf : Infinite P s) →
              □ Q s → ∀ {i} → □ Q {i} (filter s inf)
  filter⋄-□ : {s : Stream A ∞} (inf : Infinite P s) (di : ⋄ P s) →
              □ Q s → ∀ {i} → □ Q {i} (filter⋄ s inf di)

  filter-□ inf □Q = filter⋄-□ inf (⋄here inf) □Q

  Phead (filter⋄-□ inf (now _) □Q) = Phead □Q
  Ptail (filter⋄-□ inf (now _) □Q) = filter-□ (□tail inf) (Ptail □Q)
  filter⋄-□ inf (later _ di) □Q = filter⋄-□ (□tail inf) di (Ptail □Q)

module _ {ℓ ℓ′} {A : Set ℓ} {P : A → Set ℓ′} where

  □-filter : {s : Stream A ∞} (inf : Infinite P s) →
             ∀ {i} → □ P {i} (filter s inf)
  □-filter⋄ : {s : Stream A ∞} (inf : Infinite P s) (di : ⋄ P s) →
              ∀ {i} → □ P {i} (filter⋄ s inf di)

  □-filter inf = □-filter⋄ inf (⋄here inf)

  Phead (□-filter⋄ inf (now p)) = p
  Ptail (□-filter⋄ inf (now _)) = □-filter (□tail inf)
  □-filter⋄ inf (later _ di) = □-filter⋄ (□tail inf) di


  ∈-filter  : {a : A} {s : Stream A ∞} (inf : Infinite P s) →
              In a s → P a → In a (filter s inf)
  ∈-filter⋄ : {a : A} {s : Stream A ∞} (inf : Infinite P s) (di : ⋄ P s) →
              In a s → P a → In a (filter⋄ s inf di)


  ∈-filter inf index = ∈-filter⋄ inf (⋄here inf) index

  ∈-filter⋄ inf (now _)       here          p = here
  ∈-filter⋄ inf (now _)       (there index) p = there (∈-filter (□tail inf) index p)
  ∈-filter⋄ inf (later ¬p di) here          p = ⊥-elim (¬p p)
  ∈-filter⋄ inf (later ¬p di) (there index) p = ∈-filter⋄ (□tail inf) di index p
