#!/bin/bash
########################################
./nix-shell.sh --run "cabal new-repl haskell-emacs-module $*"
########################################
