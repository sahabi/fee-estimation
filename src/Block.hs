{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Block where

import qualified Interface                 as I
import qualified Client                    as C
import qualified Types                     as T 
import Data.Aeson.Types (emptyArray)

-- |
getBestBlockHash ::  C.Client ->  IO T.Hash
getBestBlockHash client =
  I.call client "getbestblockhash" emptyArray 

-- |
getBlock :: T.Hash -> C.Client -> IO T.Block
getBlock hash client = 
  I.call client "getblock" [hash]


-- |
getBestBlock_ :: C.Client -> IO T.Block
getBestBlock_ client = 
  ((flip (:)) []) <$> C.client getBestBlockHash 
  >>= I.call client "getblock"  

getBestBlock :: IO T.Block
getBestBlock = C.client getBestBlock_


