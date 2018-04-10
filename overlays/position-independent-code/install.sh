#!/bin/bash
set -e
########################################

# installs all derivations in the Nix expression,
# passing-through command-line-arguments. 

SHELL_FILE=./position-independent-code.shell.nix

########################################

nix-env --show-trace  -f "${SHELL_FILE}"  -i '.*'  $*

########################################
