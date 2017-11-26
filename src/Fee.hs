{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Fee where

import qualified Types                     as T
import qualified Interface                 as I
import qualified Client                    as C


-- |
getFeeEstimate :: C.Client         -- ^ Our client context
               -> IO T.FeeInfo    -- ^ The address created
getFeeEstimate client =
  I.call client "estimaterawfee"  [(6 :: Integer)]

