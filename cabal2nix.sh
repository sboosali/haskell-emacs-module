#!/bin/bash
set -e
########################################
cabal2nix .         > "./haskell-emacs-module.nix"
########################################
cabal2nix . --shell > "./shell.haskell-emacs-module.nix"
########################################
echo
echo '[default.nix]'
echo
cat ./default.nix

echo
echo '[shell.nix]'
echo
cat ./shell.nix

echo
echo '[haskell-emacs-module.nix]'
echo
cat ./haskell-emacs-module.nix

echo
echo '[shell.haskell-emacs-module.nix]'
echo
cat ./shell.haskell-emacs-module.nix
########################################
./nix-shell.sh --run ""
########################################
