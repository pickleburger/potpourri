{-# LANGUAGE DataKinds
           , PolyKinds
           , TypeFamilies
           , GADTs
           , TypeOperators
           , ScopedTypeVariables
           , PatternSynonyms
           , AllowAmbiguousTypes
#-}

module Proofs where

infix 2 ==
data (==) :: k -> k -> * where
    Refl :: x == x

sym :: a == b -> b == a
sym Refl = Refl 

trans :: a == b -> b == c -> a == c
trans Refl eq = eq

data From a (b :: *) = From b
data To   a (b :: *) = To b
data By     (a :: *) = By a

type EQ a b = From a (To b (By (a == b)))
pattern Eq p = From (To (By p))

infixl 1 .>
(.>) :: forall (a :: k) b c. EQ a b -> To c (By (b == c)) -> EQ a c
Eq Refl .> eq = From eq

proof :: EQ a b -> a == b
proof (Eq eq) = eq

trivial :: By (a == a)
trivial = By Refl

qed :: To a (By (a == a))
qed = To trivial

data Function :: * -> * -> *

type family Apply (f :: Function a b -> *) (t :: a) :: b

cong :: forall f a b. a == b -> Apply f a == Apply f b
cong Refl = Refl

