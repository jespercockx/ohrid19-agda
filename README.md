Correct by Construction Programming in Agda
===========================================

(This page is currently under construction)

Abstract
--------

In a dependently typed programming language you can get much stronger
static guarantees about the correctness of your program than in most
other languages. At the same time, dependent types enable new forms of
interactive programming, by letting the types guide the construction
of the program. Dependently typed languages have existed for many
years, but only recently have they become usable for practical
programming.

In this course, you will learn how to write correct-by-construction
programs in the dependently typed programming language
Agda. Concretely, we will together implement a verified typechecker
and interpreter for a small C-like imperative language. Along the way,
We will explore several modern features of the Agda language that make
this task more pleasant, such as dependent pattern matching, monads
and do-notation, coinduction and copattern matching, instance
arguments, sized types, and the Haskell FFI.

Links
-----

* Slides [Lecture 1](slides/slides1.html) [Lecture
  2](slides/slides2.html) [Lecture 3](slides/slides3.html) [Lecture
  4](slides/slides4.html)

* Code listing [V1](src/V1/html/V1.runwhile.html)
  [V2](src/V1/html/V2.runwhile.html)
  [V3](src/V1/html/V3.runwhile.html)

* This README on as Webpage on
  [github.io](https://jespercockx.github.io/ohrid19-agda/)

Prerequisites
-------------

For the exercises in this course, you need to install [Agda
2.6.0.1](https://agda.readthedocs.io/en/v2.6.0.1/getting-started/installation.html).,
the [Agda standard library
v1.1](https://github.com/agda/agda-stdlib/blob/master/notes/installation-guide.md),
and the [BNFC tool](https://github.com/BNFC/bnfc).

If you are brave, there is a [bash
script](https://github.com/jespercockx/ohrid19-agda/blob/master/setup.sh)
that installs all of these on a fresh installation of Ubuntu 18.04 or
later. Alternatively, below are step-by-step instructions.

### Installing Agda from Cabal on Ubuntu

First, make sure you have git, cabal, and emacs installed. You also
need the `zlib` c library. On Ubuntu and related systems, the
following command should work:

```bash
sudo apt-get install git cabal-install emacs zlib1g-dev
```

Make sure that binaries installed by `cabal` are available on your
path by adding the following line to `~/.profile`:

```bash
export PATH="$PATH:$HOME/.cabal/bin"
```

Now install Agda and its prerequisites:

```bash
cabal update
cabal install alex happy
cabal get Agda && cd Agda-2.6.0.1 && cabal install
agda-mode setup
```

### Installing the standard library

To install the Agda standard library:

```bash
git clone https://github.com/agda/agda-stdlib.git
cd agda-stdlib && git checkout v1.1 && cabal install
mkdir $HOME/.agda
echo $PWD/standard-library.agda-lib >> $HOME/.agda/libraries
echo standard-library >> $HOME/.agda/defaults
```

### Installing BNFC

```bash
cabal install BNFC
```
