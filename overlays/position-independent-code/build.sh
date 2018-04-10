#!/bin/bash
set -e
########################################

# builds the derivations in the Nix expression,
# passing-through command-line-arguments. 

# by building the modified haskell packages, 
# we build the modified compiler they require too. 

NIX_SHELL_FILE=./shell.nix

NIX_NAMESPACE=haskell.packages.position-independent-code

HASKELL_COMPILER=${1:-ghc822}
HASKELL_PACKAGE=${2:-lens}

NIX_PACKAGE="${NIX_NAMESPACE}.${HASKELL_COMPILER}.${HASKELL_PACKAGE}"

########################################

nix-build --show-trace "${NIX_SHELL_FILE}"  -A "${NIX_PACKAGE}"  --argstr compiler "${HASKELL_COMPILER}"

########################################
