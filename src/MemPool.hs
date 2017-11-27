{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module MemPool where

import Data.Aeson.Types (emptyArray)
import Data.ByteString.Lazy.Internal
import Control.Lens     
import qualified Network.Wreq     as W
import qualified Interface        as I
import qualified Client           as C
import qualified ChainQuery       as CQ
import qualified Types            as T 
import qualified RPC              as R
import qualified Data.Map         as Map
import qualified Data.Aeson.Types as T

type Resp = W.Response (Map.Map String T.Value)

getUnconfTx :: IO () 
getUnconfTx = do
    r <- W.asJSON =<< W.get "https://blockchain.info/unconfirmed-transactions" 
    print (W.headers (r ^. W.responseBody))

getRawMemPool_ :: C.Client -> IO [T.TxEntry_]
getRawMemPool_ client =
  I.call client "getrawmempool" [True]

getRawMemPool :: IO T.RawMemPool
getRawMemPool = do
    txs <- R.client getRawMemPool_
    return (map T.makeTxEntry txs)
