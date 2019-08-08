#!/bin/bash

# check or install dependencies:
cabal --version || sudo apt-get install cabal-install
git   --version || sudo apt-get install git
emacs --version || sudo apt-get install emacs
sudo apt-get install zlib1g-dev

# install Agda (requires GHC):
export PATH="$PATH:$HOME/.cabal/bin"
cabal update
cabal install alex happy
cabal get Agda && cd Agda-2.6.0.1 && cabal install

# make sure agda is on the path
agda --version

# setup emacs mode
agda-mode setup
echo "(setenv \"PATH\" (concat (getenv \"PATH\") \":$HOME/.cabal/bin\"))" >> $HOME/.emacs
echo "(setq exec-path (append exec-path '(\"$HOME/.cabal/bin\")))" >> $HOME/.emacs

# install standard library (requires git):
git clone https://github.com/agda/agda-stdlib.git
cd agda-stdlib && git checkout v1.1 && cabal install
mkdir $HOME/.agda
echo $PWD/standard-library.agda-lib >> $HOME/.agda/libraries
echo standard-library >> $HOME/.agda/defaults

# install BNFC (also needs alex and happy):
cabal install BNFC
