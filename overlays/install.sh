#!/bin/bash
set -e
########################################

# installs all derivations in the Nix expression,
# passing-through command-line-arguments. 

########################################

nix-env --show-trace  -f "./pic.nix"  -i '.*'  $*

########################################
