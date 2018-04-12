########################################
# ARGUMENTS

{ overlaysPath ? ./nix/overlays
, overlays     ? [ # (overlaysPath + "/position-independant-code.nix") 
                 ]

, nixpkgsPath ? <nixpkgs>
, nixpkgsWith ? import nixpkgsPath
, nixpkgs     ? nixpkgsWith { inherit overlays; }

, compiler       ? null
, integer-simple ? false
, resolver       ? null

, withHoogle      ? false 
#, withLLVM        ? false
, withProfiled    ? false
, withTested      ? false
, withBenchmarked ? false
, withDocumented  ? false
, withHyperlinked ? true
, withDwarf       ? false

, whichObjectLibraries ? null
, whichLinker          ? null

, options ? {}

, minimalDependencies ? false
, development         ? true

, packageDotNix ? null
# : ( null | FilePath | (Attributes -> Derivation) )

}:

########################################
let

### "IMPORTS"

inherit (nixpkgs) pkgs;
inherit (pkgs)    stdenv;
# "import" utilities
inherit (pkgs)       fetchFromGitHub;

inherit (stdenv.lib)
 optionalAttrs importJSON
 ;

#lib = import "${nixpkgs.path}/pkgs/development/haskell-modules/lib.nix" { pkgs = nixpkgs; };
haskell = pkgs.haskell.lib; 

/* 

> attrNames pkgs.haskell.lib
addBuildDepend             :: ? -> ?
addBuildDepends            :: ? -> ?
addBuildTool               :: ? -> ?
addBuildTools              :: ? -> ?
addExtraLibraries          :: ? -> ?
addExtraLibrary            :: ? -> ?
addPkgconfigDepend         :: ? -> ?
addPkgconfigDepends        :: ? -> ?
addSetupDepend             :: ? -> ?
addSetupDepends            :: ? -> ?
appendConfigureFlag        :: ? -> ?
appendPatch                :: ? -> ?
appendPatches              :: ? -> ?
buildFromSdist             :: ? -> ?
buildStackProject          :: ? -> ?
buildStrictly              :: ? -> ?
checkUnusedPackages        :: ? -> ?
controlPhases              :: ? -> ?
disableCabalFlag           :: ? -> ?
disableDeadCodeElimination :: ? -> ?
disableHardening           :: ? -> ?
disableLibraryProfiling    :: ? -> ?
disableSharedExecutables   :: ? -> ?
disableSharedLibraries     :: ? -> ?
disableStaticLibraries     :: ? -> ?
doBenchmark                :: ? -> ?
doCheck                    :: ? -> ?
doCoverage                 :: ? -> ?
doDistribute               :: ? -> ?
doHaddock                  :: ? -> ?
doHyperlinkSource          :: ? -> ?
doJailbreak                :: ? -> ?
doStrip                    :: ? -> ?
dontBenchmark              :: ? -> ?
dontCheck                  :: ? -> ?
dontCoverage               :: ? -> ?
dontDistribute             :: ? -> ?
dontHaddock                :: ? -> ?
dontHyperlinkSource        :: ? -> ?
dontJailbreak              :: ? -> ?
dontStrip                  :: ? -> ?
enableCabalFlag            :: ? -> ?
enableDWARFDebugging       :: ? -> ?
enableDeadCodeElimination  :: ? -> ?
enableLibraryProfiling     :: ? -> ?
enableSharedExecutables    :: ? -> ?
enableSharedLibraries      :: ? -> ?
enableStaticLibraries      :: ? -> ?
extractBuildInputs         :: ? -> ?
failOnAllWarnings          :: ? -> ?
getHaskellBuildInputs      :: ? -> ?
ghcInfo                    :: ? -> ?
justStaticExecutables      :: ? -> ?
linkWithGold               :: ? -> ?
makePackageSet             :: ? -> ?
markBroken                 :: ? -> ?
markBrokenVersion          :: ? -> ?
overrideCabal              :: ? -> ?
overrideSrc                :: ? -> ?
packageSourceOverrides     :: ? -> ?
removeConfigureFlag        :: ? -> ?
sdistTarball               :: ? -> ?
shellAware                 :: ? -> ?
triggerRebuild             :: ? -> ?

configuration transformers:

doCheck                    :: ? -> ?

doBenchmark

doHaddock                  :: ? -> ?
doHyperlinkSource          :: ? -> ?
doCoverage                 :: ? -> ?

doJailbreak                :: ? -> ?

linkWithGold

enableDWARFDebugging       :: ? -> ?

enableDeadCodeElimination  :: ? -> ?

enableLibraryProfiling     :: ? -> ?

enableSharedExecutables    :: ? -> ?

enableSharedLibraries      :: ? -> ?
enableStaticLibraries      :: ? -> ?

*/

in
########################################
let

### UTILITIES

skipTests       = haskell.dontCheck; 
jailbreak       = haskell.doJailbreak;
dropUpperBounds = haskell.doJailbreak;

directory2string = path:
 toString (baseNameOf path); 

#:: String -> Path -> 
execCabal2nix = options: src:
  nixpkgs.runCommand "cabal2nix" {
    buildCommand = ''
      cabal2nix ${options} file://"${src}" >"$out"
    '';
    buildInputs = with nixpkgs; [
      cabal2nix
    ];
  } "";

execCabal2nixSubpath = subpath: src:
  nixpkgs.runCommand "cabal2nix" {
    buildCommand = ''
      cabal2nix --subpath "${subpath}" file://"${src}" >"$out"
    '';
    buildInputs = with nixpkgs; [
      cabal2nix
    ];
  } "";

in
########################################
let

### SOURCE OVERRIDES

# "megarepos" which have multiple packages as subdirectories.
repositories = {

};

# 
sources = {
};

in
########################################
let

inherit (stdenv.lib)
 isString
 ;

# TODO nix-shell --show-trace -p "(haskell.packages.${COMPILER}.override { overrides = self: super: { spiros = haskell.lib.dontCheck (haskell.lib.dontHaddock (self.callCabal2nix ''{{name}}'' ./. {})); }; }).ghcWithPackages (self: with self; [ {{name}} ])"

####################

customMkDerivation = self: super: args:
  super.mkDerivation
    (args // customDerivationOptions);

customDerivationOptions = 
    { enableLibraryProfiling = withProfiled; 
      doCheck                = withTested; 
      doBenchmark            = withBenchmarked; 
      doHaddock              = withDocumented;
      doHyperlinkSource      = withDocumented && withHyperlinked;
      enableDWARFDebugging   = withDwarf;
    } //
    ( if   (whichObjectLibraries == "shared") 
      then { enableSharedLibraries  = true; 
           }
      else 
      if   (whichObjectLibraries == "static")
      then { enableStaticLibraries  = true; 
           }
      else
      if   (whichObjectLibraries == "both") # TODO
      then { enableSharedLibraries  = true;
             enableStaticLibraries  = true; 
           }
      else 
      if   (whichObjectLibraries == null)
      then {}
      else {} # TODO
    ) // 
    optionalAttrs (whichLinker == "gold") 
      { linkWithGold = true;
      }
 ;

####################

hooglePackagesOverride = self: super:
  {
    ghcWithPackages = self.ghc.withPackages;

    ghc = super.ghc //
      { withPackages = super.ghc.withHoogle; 
      };
  };

####################

####################

# llvmPackagesOverride = self: super:
#   {
#     ghcWithPackages = self.ghc.withPackages;

#     ghc = super.ghc //
#       { withPackages = super.ghc.llvmPackages; #TODO
#       };
#   };

### COMPILERS

haskellPackagesWithCompiler1 = 
  if   (compiler == null) || (compiler == "default")
       #TODO `integer-simple` is ignored if this matches
  then pkgs.haskellPackages

  else 
  if   integer-simple
  then pkgs.haskell.packages.integer-simple.${compiler}

  else 
  if   isString resolver
  then pkgs.haskell.packages.stackage.${resolver} # e.g. "lts-107"

  else pkgs.haskell.packages.${compiler};

haskellPackagesWithCustomPackages2 =
  if   withHoogle
  then haskellPackagesWithCompiler1.override {
         overrides = hooglePackagesOverride;
       }
  else haskellPackagesWithCompiler1;

haskellPackagesWithCustomDerivation3 = 
  haskellPackagesWithCustomPackages2.override {
    overrides = self: super: {
      mkDerivation = customMkDerivation self super;
    };
  };

# the last referenced, below
# TODO scoping
customizedHaskellPackages = haskellPackagesWithCustomDerivation3;

/*
nix-repl> haskell.packages._

haskell.packages.ghc7103
haskell.packages.ghc821Binary
haskell.packages.ghcHEAD
haskell.packages.integer-simple
haskell.packages.ghc7103Binary
haskell.packages.ghc822
haskell.packages.ghcjs
haskell.packages.ghc802
haskell.packages.ghc841
haskell.packages.ghcjsHEAD       

*/

in
########################################
### Haskell Dependencies...
let

/*

NOTES

* `local` / `github`: 
   They call `import` directly, thus those directories require a `default.nix`
* `cabal2nix` / `hackage` / `github2nix`: 
   They call `cabal2nix`, which generates the `default.nix`, so they don't require the given directory to be a valid `nix` package. 

TYPES
(in pseudo-typed-nix)

type Dependencies = { (Derivation | _) }

nix  : Path -> Dependencies -> Derivation
nix_ : Path ->              -> Derivation

hackage  : String/Name -> String/Version -> Dependencies -> Derivation
hackage_ : String/Name -> String/Version ->              -> Derivation                       

...

*/
myHaskellOverlaysWith = pkgs: self: super: let
#myHaskellOverlaysWith = pkgs: self: super: let
 call = path: self.callPackage path {}; 
 callWith = self.callPackage;

 local      = path:
              self.callPackage path; 

 github     = o:
              self.callPackage (pkgs.fetchFromGitHub o); 

             # o ::
             #      { owner           :: String
             #        repo            :: String
             #        rev             :: String
             #        fetchSubmodules :: Bool
             #        sha256          :: String
             #      } 

 cabal2nix  = name: source: 
              self.callCabal2nix name source;

 hackage    = name: version:
              self.callHackage name version;

 github2nix = o:
              cabal2nix o.repo (pkgs.fetchFromGitHub o); 

 local2nix  = path:
              cabal2nix (directory2string path) path;

 # override the package without overriding any dependencies
 local_      = path:           local      path         {};
 github_     = o:              github     o            {};
 cabal2nix_  = name: source:   cabal2nix  name source  {};
 hackage_    = name: version:  hackage    name version {};
 github2nix_ = o:              github2nix o            {};
 local2nix_  = path:           local2nix  path         {};

 #
 #haskell = pkgs.haskell.lib; 
 dependsOn = package: dependencies: 
  haskell.addBuildDepends package dependencies;

 in

 # let 
 # reflex_dom = (import repositories.reflex-dom) self pkgs;
 # in

 {
   ########################################
   # Add Haskell Packages Below           #
   ######################################## 

  #TODO pkgs.all-cabal-hashes

  spiros = local2nix_ ../spiros;
  vinyl  = local2nix_ ../vinyl;

  text = hackage "text" "1.2.3.0" {
  };

  Cabal = hackage "Cabal" "2.2.0.0" {};
  
  cabal-install = hackage "cabal-install" "2.2.0.0" {
    inherit (self) Cabal;
  }; #TODO +lib flag
  
  safe-exceptions = call ./safe-exceptions.nix;

  # cabal-install = callWith ./cabal-install-2.3.0.0.nix {
  #   Cabal = self.Cabal23;
  # };  # ^ from github

  # Cabal23 = callWith ./Cabal-2.3.0.0.nix {
  #   inherit (self) text;
  # };  # ^ from github

  # Cabal22 = call ./Cabal-2.2.0.0.nix; 
  # # ^ from hackage

  # # cabal-install_2_3_0_0 = callWith ./cabal-install-2.3.0.0.nix {
  # #   Cabal = self.Cabal_2_3_0_0;
  # # };
  # # # ^ from github

  # # Cabal         = self.Cabal_2_3_0_0;
  # # cabal-install = self.cabal-install_2_3_0_0;

  # lens
    # for cabal-doctest in custom-setup
  # lens = jailbreak (super.lens);
  # lens = hackage "lens" "4.16" {
  #   #TODO use scope
  #   Cabal = self.Cabal23;
  #   cabal-doctest = hackage "cabal-doctest" "1.0.6" {
  #     Cabal = self.Cabal23;
  #   };
  # };  

  # text = hackage_ "text" "1.2.3.0";
  # hpack                = hackage_ "hpack" "0.28.0";
  # distribution-nixpkgs = (hackage_ "distribution-nixpkgs" "1.1.1");
  #   # >=1.1.1
  # hackage-db           = (hackage_ "hackage-db" "2.0.1");
  #   # >=2.0.1

  # protolude = hackage_ "protolude" "0.2.1";

  # vinyl = skipTests super.vinyl; 

#
# test-suite doctests
#   build-depends:    base >= 4.7 && <= 5, lens, vinyl, doctest >= 0.8, singletons >= 0.10
#
# Configuring singletons-2.3.1...
# Setup: Encountered missing dependencies:
# base >=4.10 && <5
# builder for ‘/nix/store/qiaqn6ni9c8c6w8drlkx9iyf1djyx6r7-singletons-2.3.1.drv’ failed with exit code 1
# building path(s) ‘/nix/store/gi2hv1j8pbb5cn55h9lgx11g4ajryys1-protolude-0.2.1-doc’, ‘/nix/store/rz0rwxdl4n5cva0gdbs24zw8zc2p4iqk-protolude-0.2.1’
# cannot build derivation ‘/nix/store/1a61yj01hgv3f35324p0gfj8gn1327jy-vinyl-0.7.0.drv’: 1 dependencies couldn't be built
# killing process 14726
# cannot build derivation ‘/nix/store/p1m3pi9y22gpmar7bs0wb0lpvkkf37k8-ghc-8.0.2-with-packages.drv’: 1

 };

in
########################################
let

### OTHER OVERRIDES
 
modifiedHaskellPackages = customizedHaskellPackages.override {
#  overrides = self: super: {
  overrides = self: super:
    myHaskellOverlaysWith pkgs self super // {
  };
};
in

########################################
let
### "CMDLN" OPTIONS 

inherit (stdenv.lib)
 id foldl' mapAttrs attrValues 
 ;

compose =
 f: g: x: f (g x)
 ;

# boolean eliminator
bool = x: y: b:
 if b then x else y
 ;

/* : { String : (Bool -> (Derivation -> Derivation)) }

mapping between my alias for a configuration option (short to be specified at the command line), and the toggling functions of that configuration option

*/
aliasedDerivationTransformers = self: 

  { test                = bool self.doCheck
                               self.dontCheck 
  
  ; bench               = bool self.doBenchmark
                               self.dontBenchmark 
  
  ; haddock             = bool (compose self.doHyperlinkSource self.doHaddock)
                               self.dontHaddock 
  
  ; coverage            = bool self.doCoverage
                               self.dontCoverage 
  
  ; static              = bool self.enableStaticLibraries
                               self.disableStaticLibraries 
    
  ; shared              = bool self.enableSharedLibraries
                               self.disableSharedLibraries 
    
  ; sharedExecutables   = bool self.enableSharedExecutables
                               self.disableSharedExecutables 
  
  ; strip               = bool self.doStrip
                               self.dontStrip 
  
  ; goldLinker          = bool self.linkWithGold
                               id 
  
  ; deadCodeElimination = bool self.enableDeadCodeElimination
                               self.disableDeadCodeElimination 
  
  ; dwarfDebugging      = bool self.enableDWARFDebugging
                               self.disableDWARFDebugging 

  ; strict              = bool id# self.buildStrictly
                               id 

  ; checkUnusedPackages = bool (self.checkUnusedPackages {})
                               id

  ;};

/*NOTES

http://gsc.io/nixos/nixpkgs/manual/

10.5.4.8.1. failOnAllWarnings
Applying haskell.lib.failOnAllWarnings to a Haskell package enables the -Wall and -Werror GHC options to turn all warnings into build failures.


10.5.4.8.2. buildStrictly
Applying haskell.lib.buildStrictly to a Haskell package calls failOnAllWarnings on the given package to turn all warnings into build failures. Additionally the source of your package is gotten from first invoking cabal sdist to ensure all needed files are listed in the Cabal file.


10.5.4.8.3. checkUnusedPackages
Applying haskell.lib.checkUnusedPackages to a Haskell package invokes the packunused tool on the package. packunused complains when it finds packages listed as build-depends in the Cabal file which are redundant. For example:

    $ nix-build -E 'let pkgs = import <nixpkgs> {}; in pkgs.haskell.lib.checkUnusedPackages {} pkgs.haskellPackages.scientific'
    these derivations will be built:
      /nix/store/3lc51cxj2j57y3zfpq5i69qbzjpvyci1-scientific-0.3.5.1.drv
    ...
    detected package components
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
     - library
     - testsuite(s): test-scientific
     - benchmark(s): bench-scientific*
    
    (component names suffixed with '*' are not configured to be built)
    
    library
    ~~~~~~~
    
    The following package dependencies seem redundant:
    
     - ghc-prim-0.5.0.0
    
    testsuite(test-scientific)
    ~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    no redundant packages dependencies found
    
    builder for ‘/nix/store/3lc51cxj2j57y3zfpq5i69qbzjpvyci1-scientific-0.3.5.1.drv’ failed with exit code 1
    error: build of ‘/nix/store/3lc51cxj2j57y3zfpq5i69qbzjpvyci1-scientific-0.3.5.1.drv’ failed

As you can see, packunused finds out that although the testsuite component has no redundant dependencies the library component of scientific-0.3.5.1 depends on ghc-prim which is unused in the library.
    
*/


/* : String -> Bool -> (Derivation -> Derivation)

*/
translateMyOptionToANixHaskellDerivationTransformer
 = self: optionName: optionValue:
   (aliasedDerivationTransformers self).${optionName} optionValue #TODO `self`
 ;

/* : List (Derivation -> Derivation)

*/
theseOptions = self:
 attrValues
  (mapAttrs (translateMyOptionToANixHaskellDerivationTransformer self) 
   options)
 ;

/* : Derivation -> Derivation

NOTE 

foldl :: (b ->        a -> b) -> b ->      [a] -> b

($) :: (a -> b) -> a -> b
($) = id @(a -> b)

(.) :: (a -> a) -> (a -> a) -> (a -> a)

specializations:

foldl :: (b ->        a -> b) -> b ->      [a] -> b
foldl :: (b -> (b -> b) -> b) -> b -> [b -> b] -> b

foldl :: (b        ->        a ->        b) ->       b ->       [a] -> b
foldl :: ((a -> a) -> (a -> a) -> (a -> a)) -> (a -> a) -> [a -> a] -> (a -> a)

foldl :: ((Derivation -> Derivation) -> (Derivation -> Derivation) -> (Derivation -> Derivation)) -> (Derivation -> Derivation) -> [Derivation -> Derivation] -> (Derivation -> Derivation)

*/
thisOverride = self:
 foldl' compose id (theseOptions self)
 ;

/* NOTES

==========


==========

fold...

  # Strict version of `foldl'.
     The difference is that evaluation is forced upon access. Usually used
     with small whole results (in contract with lazily-generated list or large
     lists where only a part is consumed.)
  #
  foldl' = builtins.foldl' or foldl;

  # “left fold”, like `foldr', but from the left:
     `foldl op nul [x_1 x_2 ... x_n] == op (... (op (op nul x_1) x_2) ... x_n)`.
     Type:
       foldl :: (b -> a -> b) -> b -> [a] -> b
     Example:
       lconcat = foldl (a: b: a + b) "z"
       lconcat [ "a" "b" "c" ]
       => "zabc"
       # different types
       lstrange = foldl (str: int: str + toString (int + 1)) ""
       strange [ 1 2 3 4 ]
       => "a2345"
  #
  foldl = op: nul: list:
    let
      len = length list;
      foldl' = n:
        if n == -1
        then nul
        else op (foldl' (n - 1)) (elemAt list n);
    in foldl' (length list - 1);

==========

attrValues...

  # Return the values of all attributes in the given set, sorted by
     attribute name.
     Example:
       attrValues {c = 3; a = 1; b = 2;}
       => [1 2 3]
  #
  attrValues = builtins.attrValues or (attrs: attrVals (attrNames attrs) attrs);


==========

mapAttrs...

  # Apply a function to each element in an attribute set.  The
     function takes two arguments --- the attribute name and its value
     --- and returns the new value for the attribute.  The result is a
     new attribute set.
     Example:
       mapAttrs (name: value: name + "-" + value)
          { x = "foo"; y = "bar"; }
       => { x = "x-foo"; y = "y-bar"; }
  #
  mapAttrs = f: set:
    listToAttrs (map (attr: { name = attr; value = f attr set.${attr}; }) (attrNames set));


==========

*/

in
########################################
let
### DERIVATION / ENVIRONMENT

#package = packageDotNix

rawDerivation =
 if   packageDotNix == null
 then automaticallyNixifiedDerivation
 else manuallyNixifiedDerivation
 ;

automaticallyNixifiedDerivation =
 modifiedHaskellPackages.callCabal2nix 
   "project2nix"
   ./.
   {}
 ;

manuallyNixifiedDerivation =
 modifiedHaskellPackages.callPackage
   packageDotNix
   # ./spiros.nix 
   # ./default.nix 
   # ./.
   {}
 ;

installationDerivation =
 (thisOverride modifiedHaskellPackages 
   (id # haskell.buildStrictly
     rawDerivation))
 ;

/*

==========

==========

haddock
hyperlink
coverage
sharedLibraries
staticLibraries
sharedExecutables
gold
deadCodeElimination
dwarfDebugging

==========

doCheck                    :: ? -> ?
dontCheck                  :: ? -> ?

doBenchmark                :: ? -> ?
dontBenchmark              :: ? -> ?

doHaddock                  :: ? -> ?
dontHaddock                :: ? -> ?
doHyperlinkSource          :: ? -> ?
dontHyperlinkSource        :: ? -> ?
doCoverage                 :: ? -> ?
dontCoverage               :: ? -> ?

doJailbreak                :: ? -> ?
dontJailbreak              :: ? -> ?

linkWithGold               :: ? -> ?

enableSharedLibraries      :: ? -> ?
disableSharedLibraries     :: ? -> ?
enableStaticLibraries      :: ? -> ?
disableStaticLibraries     :: ? -> ?
enableSharedExecutables    :: ? -> ?
disableSharedExecutables   :: ? -> ?

appendConfigureFlag        :: ? -> ?
removeConfigureFlag        :: ? -> ?


TODO...

jailbreak

enableDWARFDebugging       :: ? -> ?

enableDeadCodeElimination  :: ? -> ?

enableLibraryProfiling     :: ? -> ?


*/

in
########################################
let
### ENVIRONMENT

# development environment
# for `nix-shell --pure`
developmentDerivation = 
  haskell.addBuildDepends 
    installationDerivation
    developmentPackages;

developmentPackages
  = developmentHaskellPackages
 # ++ developmentEmacsPackages 
 ++ developmentSystemPackages;

developmentSystemPackages = with pkgs; [
 #   
 cabal-install
 # 
 coreutils
 inotify-tools
 #   
 emacs
 git
 # 
];

developmentHaskellPackages = with modifiedHaskellPackages; [
 #   
 # ghcid
 # ghc-mod
 # 
 # 
 # hoogle
 # # 
 # hasktags
 # hlint
 # # 
 # present
 # stylish-haskell
 # hindent
 # #   
];

 # developmentEmacsHaskellPackages = with Packages; [
 #    dante
 #  ];

####################

minimalDerivation =
  haskell.addBuildDepends installationDerivation
    minimalSystemPackages;

minimalSystemPackages = with pkgs; [
 graphviz
  # for `dot`
];

####################

environmentDerivation =
 if   minimalDependencies
 then minimalDerivation
 else developmentDerivation;

environment = haskell.shellAware environmentDerivation; 
   # if pkgs.lib.inNixShell then drv.env else drv;

in
########################################

environment

########################################
/*

*/
