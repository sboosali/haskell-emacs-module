# a simplified/specialized pkgs/development/haskell-modules/default.nix

########################################

{ overlays ? []
, nixpkgs  ? import <nixpkgs> { inherit overlays; }

, pkgs
, stdenv
, lib

, haskellLib
, ghc
, all-cabal-hashes
, buildHaskellPackages

, overrides ? (self: super: {})

, initialHaskellPackages ? import "${nixpkgs.path}/pkgs/development/haskell-modules/hackage-packages.nix"
}:

########################################
let

inherit (lib)        extends makeExtensible;
inherit (haskellLib) overrideCabal makePackageSet;
  # ^ `makePackageSet` is `./make-package-set.nix`

haskellPackages = pkgs.callPackage makePackageSet {

   package-set = initialHaskellPackages;

   inherit stdenv haskellLib ghc buildHaskellPackages extensible-self all-cabal-hashes;
    # ^ references `extensible-self`
};

extensible-self = makeExtensible (extends overrides haskellPackages);
  #
  # ^ defines `extensible-self`, which is recursive:
  # `haskellPackages` inherits `extensible-self`;
  # and `extensible-self` is `haskellPackages` with extra methods (for extensibility). 
  # 
  # ^ when `overrides` is the default (the "identity overlay"):
  # 
  #        extensible-self = makeExtensible haskellPackages;
  # 
in
########################################

extensible-self
  # ^ references `extensible-self`
