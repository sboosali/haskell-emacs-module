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
