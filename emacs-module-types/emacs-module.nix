{ mkDerivation, base, bytestring, containers, deepseq, doctest
, exceptions, hashable, lens, mtl, spiros, stdenv, text
, transformers, unordered-containers
}:
mkDerivation {
  pname = "haskell-emacs-module";
  version = "0.0.0";
  src = ./.;
  libraryHaskellDepends = [
    base bytestring containers deepseq exceptions hashable lens mtl
    spiros text transformers unordered-containers
  ];
  testHaskellDepends = [ base doctest ];
  homepage = "http://github.com/sboosali/haskell-emacs-module#readme";
  description = "TODO";
  license = stdenv.lib.licenses.bsd3;
}
