{-# LANGUAGE DataKinds
           , PolyKinds
           , TypeFamilies
           , GADTs
           , TypeOperators
           , ScopedTypeVariables
           , PatternSynonyms
           , TypeApplications
#-}

module NatProofs where

import Proofs

data Nat = Z | S Nat
data SNat :: Nat -> * where
  SZ :: SNat 'Z
  SS :: SNat n -> SNat ('S n)

data RS :: Function Nat Nat -> *
type instance Apply RS m = 'S m

type family Pred (m :: Nat) :: Nat where
  Pred 'Z     = 'Z
  Pred ('S m) = m

type family (+) (m :: Nat) (n :: Nat) :: Nat where
  'Z   + n = n
  'S m + n = 'S (m + n)

plusZr :: forall m. SNat m -> m + 'Z == m
plusZr SZ      = Refl
plusZr (SS sm) = cong @RS $ plusZr sm

plusSr :: forall m n. SNat m -> SNat n -> m + 'S n == 'S (m + n)
plusSr SZ      sn = Refl
plusSr (SS sm) sn = cong @RS $ plusSr sm sn

infixr 6 .-
(.-) = ($)

plusComm :: forall m n. SNat m -> SNat n -> m + n == n + m
plusComm SZ      sn = sym $ plusZr sn
plusComm (SS sm) sn = proof $
     From @(m + n) .-
     To   @('S (Pred m + n)) .-
     trivial
  .> To   @('S (n + Pred m)) .-
     By (cong @RS (plusComm sm sn))
  .> To   @(n + m) .-
     By (sym $ plusSr sn sm)
  .> qed
