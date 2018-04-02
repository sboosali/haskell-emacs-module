#!/bin/bash
########################################

GHCID_FILE=./ghcid.txt

########################################

echo '...' > "$GHCID_FILE"
# emacsclient "$GHCID_FILE" &

########################################

COMMAND='nix-shell --show-trace --run "cabal new-repl haskell-emacs-module"'
ghcid -o "$GHCID_FILE" --command "$COMMAND"

########################################
