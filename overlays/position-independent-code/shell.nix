/* an overlay for [1] Haskell compilers (in particular, the RTS) and [2] Haskell package sets that:
are built with position independent code, i.e. `-fPIC`.
*/
########################################
# ARGUMENTS

{ compiler               ? "ghc822"

, overlays               ? []

, nixpkgsPath            ? <nixpkgs>
, nixpkgsWith            ? import nixpkgsPath
, nixpkgs                ? nixpkgsWith { inherit overlays; }

, pkgs                   ? nixpkgs.pkgs
, stdenv                 ? pkgs.stdenv
, utilities              ? pkgs.lib
, buildPackages          ? pkgs.buildPackages
, targetPackages         ? pkgs.targetPackages
, callPackage            ? pkgs.callPackage

, haskell                ? pkgs.haskell
, haskellUtilities       ? haskell.lib
, all-cabal-hashes       ? pkgs.all-cabal-hashes

, haskellCompilers       ? haskell.compiler
, haskellCompiler        ? haskellCompilers.${compiler}
  # e.g. self.haskell.compiler.ghc822

, haskellPackages        ? haskell.packages.${compiler}
, buildHaskellPackages   ? buildPackages.haskell.packages.${compiler}

, makeHaskellPackageSet  ? import ./make-haskell-package-set.nix

}@arguments:

########################################
# DEFINITIONS
let

#default = import ./default.nix;

attributesWith = import ./attributes.nix;

in
########################################

attributesWith {
 
 haskellCompilerName = compiler;

 inherit  # (arguments)
   pkgs
   haskellCompiler
   haskellPackages
   buildHaskellPackages 
   makeHaskellPackageSet
   ;

}

########################################
# USAGE

/* 



[1] the `haskellCompiler` changes from:

  pkgs.haskell.compiler.ghc822

to:

  pkgs.haskell.compiler.position-independent-code.ghc822


[2] `haskellPackages` changes from:

  pkgs.haskell.packages.ghc822

to:

  pkgs.haskell.packages.position-independent-code.ghc822


*/

########################################
# NOTES

/* 

`PIC` means "position independent code". 

`self` is the final `nixpkgs`. 
`super` is the "previous" one; 
the overlays are folded/composed in the order of the `overlays` argument in, for example, `(import <nixpkgs> { overlays = [ ... ]; } )`. (I think, the order is lexicographic-but-number-aware by filename, when read automatically). 

*/

########################################
