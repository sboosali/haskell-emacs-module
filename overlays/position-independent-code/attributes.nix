/* A haskell compiler and package set with `-fPIC`.

Both the given Haskell compiler, and every Haskell package in its package set, are built with position independent code, i.e. `-fPIC`.

e.g. returns attributes like:

  {
    haskell.compiler.position-independent-code.${ghc} = { ... }
    haskell.packages.position-independent-code.${ghc} = { ... }
  }

e.g. nix-repl

  nix-repl> static-spiros = (import ~/nixpkgs {}).haskell.packages.position-independent-code.ghc822.spiros
  nix-repl> :b static-spiros 
  
  # 

or with the cmdln:

  $ nix-build --show-trace  -E '(import ~/nixpkgs {}).haskell.packages.position-independent-code.ghc822.spiros'

  $ nix-env --show-trace -f ~/nixpkgs -iA haskell.packages.position-independent-code.ghc822.spiros



*/
########################################
# ARGUMENTS

{ haskellCompiler
, haskellCompilerName

, haskellPackages
, buildHaskellPackages 

, makeHaskellPackageSet

, pkgs
# , self  ? pkgs
# , super ? pkgs

, stdenv                ? pkgs.stdenv
, lib                   ? pkgs.lib

, callPackage           ? pkgs.callPackage
, all-cabal-hashes      ? pkgs.all-cabal-hashes 
, haskellLib            ? pkgs.haskell.lib

# , haskellUtilities      ? haskell.lib
}:

########################################
# IMPORTS / UTILITIES
let

haskellCompilerPICWith = import ./compiler.nix;

haskellPackagesPICWith = import ./packages.nix;

/* find a haskell compiler and its package set,
from a compiler flavor/version as a string. 

e.g. 

  > parseHaskellCompiler pkgs "ghc822"
  {
    name     = "ghc822"
    compiler = pkgs.haskell.compiler.ghc822;
    packages = pkgs.haskell.packages.ghc822;
  }


*/
parseHaskellCompiler = self: name:
 let
 compiler = self.haskell.compiler.${name};
 packages = self.haskell.packages.${name};
 in
 { inherit name compiler packages; };

in
########################################
let

haskellCompilerPIC = haskellCompilerPICWith {
 ghc = haskellCompiler;
};

haskellCompilerNamePIC = haskellCompilerName;
# haskellCompilerNamePIC = "${haskellCompilerName}-pic"

in
########################################
let

haskellPackagesPIC = haskellPackagesPICWith {

 haskellCompiler = haskellCompilerPIC;

 inherit # (arguments)
   haskellPackages
   buildHaskellPackages 
   makeHaskellPackageSet
   pkgs
   stdenv                
   lib      
   callPackage           
   all-cabal-hashes      
   haskellLib            
   ;

};

in
########################################
# THE NEW ATTRIBUTES

/* 

the namespacing mimicks `integer-simple`, e.g.:

  haskell.compiler.integer-simple.ghc822 = { ... }
  haskell.compiler.position-independent-code.ghc822 = { ... }

*/


{

 haskell.compiler.position-independent-code = {
   ${haskellCompilerName} = haskellCompilerPIC;
 };

 haskell.packages.position-independent-code = {
   ${haskellCompilerName} = haskellPackagesPIC;
 };

}

########################################
