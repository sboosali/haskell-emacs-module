########################################
# ARGUMENTS

{ overlays ? []

, nixpkgsPath ? <nixpkgs>
, nixpkgsWith ? import nixpkgsPath
, nixpkgs     ? nixpkgsWith { inherit overlays; }

, pkgs           ? nixpkgs.pkgs
, buildPackages  ? pkgs.buildPackages;
, targetPackages ? pkgs.targetPackages;

, haskell                ? pkgs.haskell;
, haskellUtilities       ? haskell.lib;
, haskellCompilers       ? haskell.compiler;
, haskellPackagesOf      ? haskell.packages;

, buildHaskellPackagesFor ? buildPackages.haskell.packages;
  
, compiler ? "ghc822"

}:

########################################
# DEFINITIONS
let

buildHaskellPackages = buildHaskellPackagesFor.${compiler};

haskell-modules-path = "${nixpkgs.path}/pkgs/development/haskell-modules/" 

in
########################################
# PACKAGE SET

# @TravisWhitaker https://github.com/haskell/cabal/issues/4827#issuecomment-378448042

# "exports": ghcPIC and haskellPackagesPIC.

rec {

ghcPIC = haskell.compiler.${compiler}.overrideAttrs
  (attrs: rec
    {
        picConfigString = ''
            SRC_HC_OPTS += -fPIC
            GhcRtsHcOpts += -fPIC
            GhcLibHcOpts += -fPIC
        '';

        preConfigure = attrs.preConfigure + ''
            echo "${picConfigString}" >> mk/build.mk
        '';
    });


haskellPackagesPIC =
 (buildHaskellPackages.callPackage haskell-modules-path 
    {
        ghc = ghcPIC; # from above
        haskellLib = haskellUtilities;
        inherit buildHaskellPackages;
    }
 ).override {
        overrides = self: super:
          {
            mkDerivation = args: super.mkDerivation (args //
              {
                configureFlags = (args.configureFlags or []) ++ ["--ghc-option=-fPIC"];
              });
          };
  };

}

/*OLD


pkgs.callPackage

anonymous function at /nix/store/br5xvmki2nyv0s529x8ggp4nz72wdd85-nixpkgs/pkgs/development/haskell-modules/hackage-packages.nix:128754:6 called without required argument 'array', at /nix/store/1ib1chgdhg4pdy9i888bpbmhmmwz6cdq-nixpkgs-18.09pre134727.d0d05024d10/nixpkgs/pkgs/development/haskell-modules/make-package-set.nix:88:27


*/