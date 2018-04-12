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
