{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Block where

import qualified Interface                 as I
import qualified Client                    as C
import qualified RPC                       as R
import qualified Types                     as T 
import Data.Aeson.Types                    (FromJSON, emptyArray)
import GHC.Generics

data Block = Block { tx :: [T.TxID]
                   , height :: T.Height 
                   } deriving (Show, Generic)

instance FromJSON Block

-- |
getBestBlockHash ::  C.Client ->  IO T.Hash
getBestBlockHash client =
  I.call client "getbestblockhash" emptyArray 

-- |
getBlock :: T.Hash -> C.Client -> IO Block
getBlock hash client = 
  I.call client "getblock" [hash]


-- |
getBestBlock_ :: C.Client -> IO Block
getBestBlock_ client = 
  ((flip (:)) []) <$> R.client getBestBlockHash 
  >>= I.call client "getblock"  

getBestBlock :: IO Block
getBestBlock = R.client getBestBlock_


