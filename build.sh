#!/bin/bash
set -e
########################################
./nix-shell.sh --run "cabal new-build $*" 
########################################
