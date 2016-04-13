\documentclass[a4paper,UKenglish]{lipics-v2016} 
%This is a template for producing LIPIcs articles. 
%See lipics-manual.pdf for further information.
%for A4 paper format use option "a4paper", for US-letter use option "letterpaper"
%for british hyphenation rules use option "UKenglish", for american hyphenation rules use option "USenglish"
% for section-numbered lemmas etc., use "numberwithinsect"

\input{commands}
\usepackage{agda}
\usepackage{mathpartir}
\usepackage{todonotes}
\usepackage{microtype}
\usepackage{catchfilebetweentags}
\bibliographystyle{plainurl}% the recommended bibstyle

% Author macros::begin %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\title{Typing with Leftovers -- A mechanization of Intuitionistic Linear Logic\footnote{This work was partially supported by someone.}}
\titlerunning{Typing with Leftovers} %optional, in case that the title is too long; the running title should fit into the top page column

%% Please provide for each author the \author and \affil macro,
%% even when authors have the same affiliation, i.e. for each
%% author there needs to be the  \author and \affil macros
\author[1]{Guillaume Allais}
\affil[1]{Nijmegen Quantum Logic Group ─ Radboud University\\
  \texttt{gallais@cs.ru.nl}}
\authorrunning{G. Allais} %mandatory. First: Use abbreviated first/middle names. Second (only in severe cases): Use first author plus 'et. al.'

\Copyright{Guillaume Allais}
%mandatory, please use full first names.
% LIPIcs license is "CC-BY";  http://creativecommons.org/licenses/by/3.0/

\subjclass{Dummy classification -- please refer to \url{http://www.acm.org/about/class/ccs98-html}}
% mandatory: Please choose ACM 1998 classifications from http://www.acm.org/about/class/ccs98-html
% . E.g., cite as "F.1.1 Models of Computation".
\keywords{Dummy keyword -- please provide 1--5 keywords}% mandatory: Please provide 1-5 keywords
% Author macros::end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Editor-only macros:: begin (do not touch as author)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\EventEditors{John Q. Open and Joan R. Acces}
\EventNoEds{2}
\EventLongTitle{42nd Conference on Very Important Topics (CVIT 2016)}
\EventShortTitle{CVIT 2016}
\EventAcronym{CVIT}
\EventYear{2016}
\EventDate{December 24--27, 2016}
\EventLocation{Little Whinging, United Kingdom}
\EventLogo{}
\SeriesVolume{42}
\ArticleNo{23}
% Editor-only macros::end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\begin{document}

\maketitle

\begin{abstract}We start from a simple lambda-calculus and introduce a bidirectional 
typing relation corresponding to an Intuitionistic Linear Logic. This 
typing relation is based on the idea that a linear term consumes some 
of the resources available in its context whilst leaving behind leftovers 
which could then be used by another program. 

Practically, this means that typing derivations have both an input 
and an output context. This leads to a notion of weakening (all the 
extra resources added to the input context come out unchanged in the 
output one), a rather direct proof of stability under substitution, 
an analogue of the frame rule of separation logic showing that the 
state of unused resources can be safely ignored, as well as a proof 
that typechecking is decidable. 

The work has been fully formalised in Agda, commented source files 
are provided as additional material.
\end{abstract}


\section{Introduction}

\paragraph*{Notations} This whole development has been fully formalised
in Agda. Rather than including Agda syntax, the results are reformulated
in terms of definitions, lemmas, theorems, etc. However it is important
to keep in mind the distinction between various kinds of objects.
\texttt{Teletype} is used to denote data constructors, \DefinedType{small
capitals} are characteristic of defined types. A type families' index is
written as a subscript e.g. $\Var{}_n$.

\section{The Calculus of Raw Terms}

Following Altenkirch and Reus~\cite{altenkirch1999monadic},
we define the raw terms of our language not as an inductive
type but rather as an inductive \emph{family}~\cite{dybjer1994inductive}.
This technique, sometimes dubbed ``type-level de Bruijn indices'',
makes it possible to keep track in the index of the family of the
free currently in scope. As is nowadays folklore, instead of using
a set-indexed presentation where a closed terms is indexed by
the empty set $⊥$ and fresh variables are introduced by wrapping
the index in a \texttt{Maybe} type constructor\footnote{The value
\texttt{nothing} represents the fresh variable whilst the data
constructor \texttt{just} lifts all the existing ones in the new
scope.}, we index our terms by a natural number instead. The
\Var{} type family defined below represents the de Bruijn
indices~\cite{debruijn1972lambda} corresponding to the $n-1$ free
variables present in a scope $n$.

\begin{mathpar}
\inferrule
 {n : \Nat{}
}{\Var{}_n : \Set{}
}

\and \inferrule
 {
}{\texttt{zero} : \Var{}_{1 + n}
}

\and \inferrule
 {k : \Var{}_n
}{\texttt{suc} (k) : \Var{}_{1 + n}
}
\end{mathpar}

The calculus is presented in a bidirectional fashion\todo{cite}.
This gives a clean classification of term formers as being either
constructors of canonical values or eliminations corresponding to
computations. This separation also characterises the flow of
information during typechecking: given a context assigning a type
to each free variable, canonical values (which we call \Checkable{})
can be \emph{check}ed against a type whilst we may infer the type of
computations (which we call \Inferable{}).

\begin{table}[h]\centering
\begin{tabular}{lcl}
⟨$\Inferable{}_n$⟩ & ::= & \texttt{var} ⟨$\Var{}_n$⟩ \\
                   &  |  & \texttt{app} ⟨$\Inferable{}_n$⟩ ⟨$\Checkable{}_n$⟩ \\
                   &  |  & \texttt{case} ⟨$\Inferable{}_n$⟩
                           \texttt{return} ⟨\Type{}⟩
                           \texttt{of} ⟨$\Checkable{}_{1 + n}$⟩
                           \texttt{\%\%} ⟨$\Checkable{}_{1 + n}$⟩ \\
                   &  |  & \texttt{cut} ⟨$\Checkable{}_n$⟩ ⟨\Type{}⟩ \\ \\

⟨$\Checkable{}_n$⟩ & ::= & \texttt{lam} ⟨$\Checkable{}_{1 + n}$⟩ \\
                   &  |  & \texttt{let} ⟨$\Pattern{}_m$⟩ \texttt{∷=} ⟨$\Inferable{}_n$⟩
                           \texttt{in} ⟨$\Checkable{}_{m + n}$⟩ \\
                   &  |  & \texttt{prd} ⟨$\Checkable{}_n$⟩ ⟨$\Checkable{}_n$⟩ \\
                   &  |  & \texttt{inl} ⟨$\Checkable{}_n$⟩ \\
                   &  |  & \texttt{inr} ⟨$\Checkable{}_n$⟩ \\
                   &  |  & \texttt{neu} ⟨$\Inferable{}_n$⟩ \\                  
\end{tabular}
\caption{Grammar of the Language of Raw Terms}
\end{table}

Two additional rules (\texttt{neu} and \texttt{cut} respectively)
allow the embeddin of \Inferable{} into \Checkable{} and vice-versa. They
make it possible to form redexes by embedding canonical values into
computations and then applying eliminators to them. In terms of
typechecking, they correspond to a change of direction between
inferring and checking. The constructor \texttt{cut} takes an
extra \Type{} argument in order to guarantee the success of
type-inference for \Inferable{} terms.

A notable specificity of this language is the ability to use nested
patterns in a let binder rather than having to resort to cascading
lets. This is achieved thanks to a rather simple piece of kit: the
\Pattern{} type family. A value of type $\Pattern{}_n$ represents a
pattern binding $n$ variables. Because variables are represented as
de Bruijn indices, the base pattern does not need to be associated
with a name, it simply is a constructor \texttt{v} binding exactly
$1$ variable. The comma pattern constructor takes two nested patterns
respectively binding $m$ and $n$ variable and uses them to deeply
match a pair thus binding $(m + n)$ variables.

\begin{mathpar}
\inferrule
 {n : \Nat{}
}{\Pattern{}_n : \Set{}
}

\and \inferrule
 {
}{\texttt{v} : \Pattern{}_1
}

\and \inferrule
 {p : \Pattern{}_m \and q : \Pattern{}_n
}{p \texttt{,} q : \Pattern{}_{m + n}
}
\end{mathpar}

The grammar of raw terms only guarantees that all expressions are
well-scoped by construction. It does not impose any other constraint,
which means that a user may write valid programs but also invalid
ones as the following examples demonstrate:

\begin{example}\texttt{swap} is a closed, well-typed linear term
taking a pair as an input and swapping its components. It corresponds
to the mathematical function $(x, y) \mapsto (y, x)$.
\begin{lstlisting}
  swap = lam (let (v , v) ∷= var zero
              in prd (neu (var (suc zero))) (neu (var zero)))
\end{lstlisting}
\end{example}

\begin{example}\texttt{illTyped} is a closed linear term. However
it is manifestly ill-typed: the let-binding it uses tries to break
down a function as if it were a pair.
\begin{lstlisting}
  illTyped = let (v , v) ∷= cut (lam (neu (var zero))) (a ⊸ a)
             in prd (neu (var zero)) (neu (var (suc zero)))
\end{lstlisting}
\end{example}

\begin{example}Finally, \texttt{diagonal} is a term typable in the
simply-typed lambda calculus but it is not linear: it duplicates
its input just like $x \mapsto (x, x)$ does.
\begin{lstlisting}
  diagonal = lam (prd (neu (var zero)) (neu (var zero)))
\end{lstlisting}
\end{example}

\section{Linear Typing Rules}

These considerations lead us to the need for a typing relation
describing the rules terms need to abide by in order to qualify
as valid programs. A linear type system is characterised by the
fact that all the resources available in a context have to be
used exactly once by the term being checked. In traditional
presentations of linear logic this is achieved by representing
the context as a multiset and, in each rule, cutting it up and
distributing its parts among the premises. This is epitomised
by the introduction rule for tensor (cf. Figure~\ref{rule:tensor}).

However, multisets are an intrinsically extensional notion and
therefore quite arduous to work with in an intensional type
theory. Various strategies can be applied to tackle this issue;
most of them rely on using linked lists to represent contexts
together with either extra inference rules to reorganise the
context or a side condition to rules splitting the context so
that it may be re-arranged on the fly. In the following example
$\_≈\_$ stands for ``bag-equivalence'' of lists.
\begin{figure}[h]
\begin{mathpar}
\inferrule
 {Γ ⊢ σ \and Δ ⊢ τ
}{Γ, Δ ⊢ σ ⊗ τ
}{⊗_i}

\and \inferrule
 {Γ ⊢ σ \and Δ ⊢ τ \and Γ, Δ ≈ Θ
}{Θ ⊢ σ ⊗ τ
}{⊗_i}
\end{mathpar}
\caption{Introduction rules for tensor (left: usual presentation, right: with reordering on the fly)\label{rule:tensor}}
\end{figure}

All of these strategies are artefacts of the unfortunate mismatch
between the ideal mathematical objects one wishes to model and
their internal representation in the proof assistant. Short of
having proper quotient types, this will continue to be an issue
when dealing with multisets. The solution described in the rest
of this paper tries not to replicate a set-theoretic approach in
intuitionistic type theory but rather strives to find the type
theoretical structures which can make the problem more tractable.
Indeed, given the right abstractions most proofs become simple
structural inductions.

\subsection{Usage Annotations}

McBride's recent work~\cite{mcbride2016got} on combining linear and
dependent types highlights the distinction one can make between
referring to a resource and actually consuming it. In the same spirit,
rather than dispatching the available resources in the appropriate
subderivations, we consider that a term is checked in a \emph{given}
context on top of which usage annotations are super-imposed. These
usage annotations indicate whether resources have been consumed already
or are still availble. Type-inference (resp. Type-checking) is then
inferring (resp. checking) a term's type but \emph{also} annotating
the resources consumed by the term in question and returning the
``leftovers'' which gave their name to this paper.

\begin{definition}
\label{definition:context}
A ``context'' is a list of \Type{}s indexed by its length. It can
be formally described by the following inference rules:
\begin{mathpar}
\inferrule
 {n : \Nat{}
}{\Context{}_n : \Set{}
}

\and \inferrule
 {
}{[] : \Context{}_0
}

\and \inferrule
 {γ : \Context{}_n \and σ : \Type{}
}{γ ∙ σ : \Context{}_{1 + n}
}
\end{mathpar}
\end{definition}


\begin{definition}
\label{definition:usage}
A \Usage{} is a predicate on a type σ describing whether the
resource associated to it is available or not. We name the
constructors describing these two states \texttt{fresh} and
\texttt{stale} respectively. The pointwise lifting of \Usage{}
to contexts is called \Usages{}. The inference rules are:
\begin{mathpar}
\inferrule
 {σ : \Type{}
}{\Usage{}_σ : \Set{}
}
\and\inferrule
 {
}{\texttt{fresh}_σ : \Usage{}_σ
}
\and\inferrule
 {
}{\texttt{stale}_σ : \Usage{}_σ
}
\end{mathpar}
\begin{mathpar}
\inferrule
 { γ : \Context{}_n
}{\Usages{}_γ : \Set{}
}
\and\inferrule
 {
}{[] : \Usages{}_{[]}
}
\and\inferrule
 {Γ : \Usages{}_γ \and S : \Usage{}_σ
}{Γ ∙ S : \Usages{}_{γ ∙ σ}
}
\end{mathpar}
\end{definition}

\subsection{Typing as Consumption Annotation}

A Typing relation seen as a consumption annotation process describes
what it means, given a context an its usage annotation, to ascribe a
type to a term whilst crafting another usage annotation containing all
the leftover resources. Formally:

\begin{definition}
\label{definition:typing}
A ``Typing Relation'' for $T$ a \Nat{}-indexed inductive family is
an indexed relation $\text{\𝓣{}}_n$ such that:
\begin{mathpar}
\inferrule
 {n : \Nat{} \and γ : \Context{}_n \and Γ, Δ : \Usages{}_γ \and t : T_n \and σ : \Type{}
}{\text{\𝓣{}}_n(Γ, t, σ, Δ) : \Set{}
}
\end{mathpar}
\end{definition}

The simplest instance of a Typing Relation is the one for de Bruijn
indices: given an index $k$ and a usage annotation, it successfully
associates a type to that index if and only if the $k$th resource
in context is \texttt{fresh}. In the resulting leftovers, it will
have turned \texttt{stale}:

\begin{definition}
\label{typing:deBruijn}
The relation is defined inductively. It has exactly two constructors
and their name are overloaded with the corresponding constructors for
\Var{}:
\begin{mathpar}
\inferrule
 {
}{\texttt{zero} : Γ ∙ \texttt{fresh}_σ ⊢ \texttt{zero} ∈ σ ⊠ Γ ∙ \texttt{stale}_σ
}
\and \inferrule
 {K : Γ ⊢ k ∈ σ ⊠ Δ
}{\texttt{suc}(K) : Γ ∙ A ⊢ \texttt{suc}(k) ∈ σ ⊠ Δ ∙ A
}
\end{mathpar}
\end{definition}

\begin{example}
Which makes it to write the first typing derivation of this paper:
the de Bruijn index 1 has type τ in the context (γ ∙ σ ∙ τ) with
usage annotation ($Γ ∙ \texttt{fresh}_τ ∙ \texttt{fresh}_σ$):
\begin{mathpar}
\inferrule
 {\inferrule
   {
  }{\texttt{zero} : Γ ∙ \texttt{fresh}_τ ⊢ \texttt{zero} ∈ τ ⊠ Γ ∙ \texttt{stale}_τ
  }
}{\texttt{suc(zero)} : Γ ∙ \texttt{fresh}_τ ∙ \texttt{fresh}_σ ⊢ \texttt{suc(zero)} ∈ τ ⊠ Γ ∙ \texttt{stale}_τ ∙ \texttt{fresh}_σ
}
\end{mathpar}
Or, as it would be written in Agda:\todo{fixthis}
\begin{lstlisting}
  one : Γ ∙ fresh τ :: fresh σ ⊢ suc(zero) ∈  τ  ⊠ Γ ∙ stale τ ∙ fresh σ
  one = suc zero
\end{lstlisting}
\end{example}

\section{}
\begin{definition}
\label{definition:differences}
``Consumption equality'' relates pairs of γ-usages seen as whenever they
exhibit the same consumption pattern: they leave the same resources left untouched

\begin{mathpar}
\inferrule
 {Γ, Δ, Θ, ξ : \Usages{}_γ
}{Γ ─ Δ ≡ Θ ─ ξ : \Set{}
}
\and \inferrule
 {
}{[] - [] ≡ [] - []
}{
}
\and \inferrule
 {Γ - Δ ≡ Θ - ξ
}{(Γ ∙ A) - (Δ ∙ A) ≡ (Θ ∙ B) - (ξ ∙ B)
}{
}
\and \inferrule
 {Γ - Δ ≡ Θ - ξ
}{(Γ ∙ [σ]) - (Δ ∙ ]σ[) ≡ (Θ ∙ [σ]) - (ξ ∙ ]σ[)
}{
}
\end{mathpar}
\end{definition}

\begin{definition}
\label{definition:framing}
A Typing relation \𝓣{} is said to have the ``Framing Property'' if for all
term $t$, type $σ$ and γ-usages annotations Γ, Δ, Θ and ξ, whenever
Γ ─ Δ ≡ Θ ─ ξ  and \𝓣{} Γ t σ Δ hold then so does \𝓣{} Θ t σ ξ.
\end{definition}


\begin{theorem}[Frame Rule]
\label{theorem:framing}
\begin{itemize}
  \item Check has the Framing Property
  \item Infer has the Framing Property
\end{itemize}
\end{theorem}

\begin{theorem}[Stability under Weakening]
\label{theorem:weakening}
\end{theorem}

\begin{theorem}[Stability under Substitution]
\label{theorem:substituting}
\end{theorem}

\begin{theorem}[Decidability of Typechecking]
\label{theorem:typechecking}
\end{theorem}



\section{Related Work}

We have already mentioned McBride's work~\cite{mcbride2016got}
on (as a first approximation: the setup is actually more general)
a type theory with a \emph{dependent linear} function space as a
very important source of inspiration. In that context it is indeed
crucial to retain the ability to tlak about a resource even if it
has already been consumed. E.g. a function taking a boolean and
deciding wheter it is equal to \texttt{tt} or \texttt{ff} will
have a type mentioning the function's argument twice. But in a
lawful manner: $(x : \DefinedType{Bool}) ⊸ (x ≡ \texttt{tt}) ∨ (x ≡ \texttt{ff})$.
This leads to the need for a context \emph{shared} across all
subterms and consumption annotations ensuring that the linear
resources are never used more than once.

We can find a very concrete motivation for a predicate similar to
our \Usage{} in Robbert Krebbers' thesis~\cite{krebbers2015thesis}.
In section 2.5.9, he describes one source of undefined behaviours
in the C standard: the execution order of expressions is unspecified
thus leaving the implementers with absolute freedom to pick any order
they like if that yields better performances. To make their life
simpler, the standard specifies that no object should be modified
more than once during the execution of an expression. In order to
enforce this invariant, the memory model is enriched with extra
information:
\begin{quote}
  [E]ach bit in memory carries a permission that is set to a special
  locked permission when a store has been performed. The memory
  model prohibits any access (read or store) to objects with locked
  permissions. At the next sequence point, the permissions of locked
  objects are changed back into their original permission, making
  future accesses possible again.
\end{quote}



\appendix

%%
%% Bibliography
%%

%% Either use bibtex (recommended),

\bibliography{main}

%% .. or use the thebibliography environment explicitely



\end{document}