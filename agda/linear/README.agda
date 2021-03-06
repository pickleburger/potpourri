module linear.README where

-- Raw terms
open import linear.Scope
open import linear.Language

-- Types, typing Contexts and Usage annotations
open import linear.Type
open import linear.Context
open import linear.Usage

-- Typing relation and basic properties
open import linear.Typing
open import linear.Typing.Inversion
open import linear.Typing.Functional

-- Extensionality of Typing wrt to pointwise equality on Usages
open import linear.Context.Pointwise
open import linear.Usage.Pointwise
open import linear.Typing.Extensional

-- Frame rule and stability of Typing under Weakening and Substitution
open import linear.Typing.Consumption
open import linear.Typing.Substitution

-- Decidability of Typing inference / checking
open import linear.Typecheck.Problem
open import linear.Typecheck

-- Thinning
open import linear.Usage.Erasure
open import linear.Typing.Thinning

-- More traditional presentation and Model
open import linear.ILL
open import linear.Model

-- Mix aka context permutations (needed for completeness)
open import linear.Mix
open import linear.Context.Mix
open import linear.Usage.Mix
open import linear.Typing.Mix

-- Soundness and Completeness
open import linear.Soundness
open import linear.Completeness

-- Examples
open import linear.Language.Examples
open import linear.Typing.Examples
open import linear.Typecheck.Examples
