{-# OPTIONS_GHC -fno-warn-missing-signatures #-} 
    -- to test inference

-- {-# LANGUAGE  #-}
-- {-# LANGUAGE OverloadedStrings #-}
-- {-# LANGUAGE OverloadedLists #-}

{-| This module provides a simple example program. 


Being a @library@ module, it's typechecked with the package, 
and thus should always build.

Only public interfaces are imported (i.e. no @.Internal@s),
all required language extensions are listed within this module,
and there are minimal other dependencies. 


Doctests:

@
TODO
@

Please read the source too <https://hackage.haskell.org/package/haskell-emacs-module/docs/src/Example.Language.Emacs.html (direct Hackage link)>. 


-}
module Example.Language.Emacs where

-- import Language.Emacs

import "base" Prelude

----------------------------------------

{-|
-}
example = ()

----------------------------------------
