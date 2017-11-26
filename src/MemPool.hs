{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module MemPool where

import qualified Interface                 as I
import qualified Client                    as C
import qualified Types                     as T 


-- |
getRawMemPool_ :: C.Client -> IO [T.TxEntry_]
getRawMemPool_ client =
  I.call client "getrawmempool" [True]-- >>= (fmap T.makeTxEntry)

getRawMemPool :: IO T.RawMemPool
getRawMemPool = do
    txs <- C.client getRawMemPool_
    return (map T.makeTxEntry txs)
