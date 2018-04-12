{ 
}:

########################################
# HELPERS
let

/*

NOTE https://gist.github.com/CMCDragonkai/de84aece83f8521d087416fa21e34df4

  nix-repl> ./foo + "/" + "bar"
  /home/bas.van.dijk/foobar

^ `+` is left associative, so it is interpreted as:

  (./foo + "/") + "bar"

  nix-repl> ./foo + "/"
  /home/bas.van.dijk/foo

^ Nix performs normalization on paths since the final slash is not included. 

  nix-repl> ./foo + ("/" + "bar")
  /home/bas.van.dijk/foo/bar


e.g.

  > appendFilenameStringToDirectoryPath ./nix/overlays "position-independant-code.nix"
  /home/sboo/haskell/haskell-emacs-module/nix/overlays/position-independant-code.nix

*/
appendFilenameStringToDirectoryPath = directory: filename:
  directory + "/${filename}";
  # directory + ("/" + filename)

/*

NOTE `readDir`:

  $ find ./nix/overlays
  ./nix/overlays/position-independant-code.nix
  ./nix/overlays/ghjcs/
  ./nix/overlays/ghjcs/default.nix


  $ nix-repl
  > readDir ./nix/overlays
  { "position-independant-code.nix" = "regular"; "ghcjs" = "directory"; }
  > readDir ./nix/overlays/ghcjs 
  { "ghcjs.nix" = "regular"; }

*/

# readDirectoryRecursively = directory: let
#   isDir = file
#   go = path: let
#     contents = builtins.readDir path

in
########################################

let 

with builtins;

appendFilename = directory: filename:
  directory + "/${filename}";

overlayDirectory = ../overlays; 

in

let

overlayDirectoryContents =
 attrNames (readDir overlayDirectory))

importOverlay = filename:
 import (appendFilename overlayDirectory filename)

overlayFiles = filter isOverlay overlayDirectoryContents

isOverlay = filename:
    (match ".*\\.nix" filename) != null
 || pathExists (appendFilename overlayDirectory (filename + "/default.nix"))

in

map importOverlay overlayFiles

########################################

{ inherit appendFilenameStringToDirectoryPath; 
}
########################################
