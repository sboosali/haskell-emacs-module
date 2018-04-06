/* an overlay for [1] Haskell compilers (in particular, the RTS) and [2] Haskell package sets that:
are built with position independent code, i.e. `-fPIC`.
*/

########################################
self: super: 

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
# "IMPORTS"
let

# haskellUtilities = super.haskell.lib;

in
########################################
# COMPILER
let

ghc822-PIC =
 self.haskell.compiler.ghc822.overrideAttrs preConfigure-ghcWithPIC;

####################

/* :: DerivationAttributes -> DerivationAttributes

  _.overrideAttrs preConfigure-ghcWithPIC

for a GHC (i.e. its RTS) with PIC.

i.e. the runtime system (which is in C, not Haskell) is built with PIC, via `GhcRtsHcOpts += -fPIC`.

"setting it on SRC_HC_OPTS might be overkill; we don't care if GHC itself is position-independent." - @TravisWhitaker

*/
preConfigure-ghcWithPIC = attributes: {

  inherit flagsForRTSWithPIC;

  preConfigure = attributes.preConfigure + buildmkForRTSWithPIC;

};

####################

/* 
*/
buildmkForRTSWithPIC = ''
echo "${flagsForRTSWithPIC}" >> mk/build.mk
'';

/* 
*/
flagsForRTSWithPIC = ''
SRC_HC_OPTS += -fPIC
GhcRtsHcOpts += -fPIC
GhcLibHcOpts += -fPIC
'';

in
########################################
# PACKAGE-SET
let

/* a Haskell package set with mass PIC; i.e. each package is built with the -fPIC flag. 

this requires overriding `buildHaskellPackages`, the ghc "boot libraries" (?). 

*/


/*NOTES


buildPackages



  
*/


/*

{ pkgs, stdenv, lib
, ghc, haskellLib, buildHaskellPackages
, all-cabal-hashes

, compilerConfig      ? (self: super: {})
, packageSetConfig    ? (self: super: {})
, overrides           ? (self: super: {})

, initialPackages     ? import ./initial-packages.nix
, configurationCommon ? import ./configuration-common.nix
, configurationNix    ? import ./configuration-nix.nix
}:

*/

####################

overridenHaskellModules =
 defaultHaskellModules.override overrides-ghcWithPIC;

####################

defaultHaskellModules = self.callPackage "${nixpkgs.path}/pkgs/development/haskell-modules/" {

  ghc = self.haskell.compiler.position-independent-code.ghc822;

  buildHaskellPackages = self.buildPackages.haskell.packages.ghc822;

  haskellLib = super.haskell.lib;

    # ^ from below: preConfigure-ghcWithPIC
};

# locationOfHaskellModules = "${nixpkgs.path}/pkgs/development/haskell-modules/";

####################

/* :: { overrides :: Overlay HaskellPackageSet }

   where
   
   type Overlay a = (a -> a -> a) 

e.g.

  ghc.override overrides-ghcWithPIC;

*/
overrides-ghcWithPIC = {

  overrides = self-haskellPackages: super-haskellPackages: {
    mkDerivation = mkDerivation-withPIC super-haskellPackages;
  };

};

####################

/* 

a "pseudo-attribute" of a HaskellPackageSet:

  mkDerivation-withPIC haskellPackages
  ~ 
  haskellPackages.mkDerivation

*/

mkDerivation-withPIC = haskellPackages: arguments:
  haskellPackages.mkDerivation (configureFlags-withPIC arguments);

####################

/* :: HaskellDerivationArguments -> HaskellDerivationArguments

   where
   
   haskellPackages.mkDerivation :: HaskellDerivationArguments -> HaskellDerivation


*/

configureFlags-withPIC = arguments: arguments // {
  configureFlags = (arguments.configureFlags or [])
    ++ [ cabalFlagPIC ];
};

 # arguments@{configureFlags, ...}:

/* :: String
*/
cabalFlagPIC = ''--ghc-option=${flagPIC}''; 

/* :: String
*/
flagPIC = "-fPIC"

in
########################################
# THE OVERLAY

/* 

the namespacing mimicks `integer-simple`:

  haskell.compiler.integer-simple.${ghc}
  haskell.compiler.position-independent-code.${ghc}

*/


{

 haskell.compiler.position-independent-code = {
   ghc822 = ghc822-PIC
 };

 haskell.packages.position-independent-code.ghc822 =
   overridenHaskellModules; 

}

########################################
