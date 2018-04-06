#!/bin/bash
set -e
########################################

# builds the derivations in the Nix expression,
# passing-through command-line-arguments. 

# by building the modified haskell packages, 
# we build the modified compiler they require too. 

HASKELL_PACKAGE=lens

########################################

nix-build --show-trace  ./pic.nix  -A "haskellPackagesPIC.${HASKELL_PACKAGE}"  $*

########################################
