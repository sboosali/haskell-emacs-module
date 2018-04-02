-- {-# LANGUAGE  #-}

{-| The package-specific custom prelude, which re-exports 
another custom ('Prelude.Spiros' from the @spiros@ package). 

-}
module Prelude.Language.Emacs
 ( module Prelude.Spiros
 -- , module Prelude.Language.Emacs
 -- , module X
 ) where

----------------------------------------

-- import as X

import "spiros" Prelude.Spiros

----------------------------------------

----------------------------------------
