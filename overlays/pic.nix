/* a Haskell package set where everything is built with `-fPIC`.

This requires overriding `buildHaskellPackages`, the ghc "boot libraries" (?). 

TODO: should we (can we?) override any C packages to be built with position dependent code too. e.g. via `cabal`'s `cc-options`, and thus via `mkDerivation`. 

*/
########################################
# ARGUMENTS

{ haskellCompiler

, haskellPackages
, buildHaskellPackages 

, makeHaskellPackageSet

, pkgs
, stdenv
, lib   

, callPackage        
, all-cabal-hashes   
, haskellLib         

# , haskellUtilities      ? haskell.lib
}:

########################################
let

####################

/* :: { overrides :: Overlay HaskellPackageSet }

   where
   
   type Overlay a = (a -> a -> a) 

e.g.

  .override overrides-PIC;

*/
overrides-PIC = {

  overrides = self: super: {

    mkDerivation = mkDerivation-PIC super;

  };

};

####################



/* 

a "pseudo-attribute" of a HaskellPackageSet:

  mkDerivation-PIC haskellPackages
  ~ 
  haskellPackages.mkDerivation

*/

mkDerivation-PIC = self: arguments:
  self.mkDerivation
    (configureFlags-PIC arguments);

####################

/* :: HaskellDerivationArguments -> HaskellDerivationArguments

   where
   
   haskellPackages.mkDerivation :: HaskellDerivationArguments -> HaskellDerivation

*/

configureFlags-PIC = arguments:

  arguments // {

    configureFlags = (arguments.configureFlags or [])
      ++ [ "--ghc-option=-fPIC" ];
  
  };

in
########################################
# CUSTOM LIBRARIES WITH CUSTOM COMPILER 
let

haskellPackages-PIC =
 makeHaskellPackageSet haskellPackagesConfig-PIC;

haskellPackagesConfig-PIC = {

  inherit pkgs stdenv lib;
 
  inherit buildHaskellPackages all-cabal-hashes haskellLib;
  # haskellLib = haskellUtilities;

  initialHaskellPackages = haskellPackages;
 
  ghc = haskellCompiler;

  inherit (overrides-PIC) overrides;

 };

# overrides = (self: super: {});
in
########################################

haskellPackages-PIC






########################################
/* a `ghc` with `-fPIC`. 

re-configure the given Haskell compiler (in particular, its runtime-system a.k.a. its RTS), to be built with position independent code, i.e. `-fPIC`.

integer-simple

*/
########################################
# ARGUMENTS

{ ghc
}:

in
########################################
# COMPILER
let

haskellCompilerPIC =
 haskellCompilerPICFor ghc;

haskellCompilerPICFor = haskellCompiler:
 haskellCompiler.overrideAttrs
   preConfigure-haskellCompilerPIC;

####################

/* :: DerivationAttributes -> DerivationAttributes

  _.overrideAttrs preConfigure-haskellCompilerPIC

for a GHC (i.e. its RTS) with PIC.

i.e. the runtime system (which is in C, not Haskell) is built with PIC, via `GhcRtsHcOpts += -fPIC`.

"setting it on SRC_HC_OPTS might be overkill; we don't care if GHC itself is position-independent." - @TravisWhitaker

*/
preConfigure-haskellCompilerPIC = attributes: {

  inherit flagsForRTSWithPIC;

  preConfigure = attributes.preConfigure + ''
    echo "${flagsForRTSWithPIC}" >> mk/build.mk
  '';

};

flagsForRTSWithPIC = ''
SRC_HC_OPTS += -fPIC
GhcRtsHcOpts += -fPIC
GhcLibHcOpts += -fPIC
'';

in
########################################

haskellCompilerPIC

########################################
