{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module MemPool where

import Data.List
import Data.Aeson.Types (emptyArray)
import Data.ByteString.Lazy.Internal
import Control.Lens
import qualified DB               as DB
import qualified Network.Wreq     as W
import qualified Interface        as I
import qualified Client           as C
import qualified Types            as T
import qualified RPC              as R
import qualified Data.Map         as Map
import qualified Data.Aeson.Types as T
import qualified Block            as B

type Resp = W.Response (Map.Map String T.Value)
type RawMemPool = [T.TxEntry]

getRawMemPool_ :: C.Client -> IO [T.TxEntry_]
getRawMemPool_ client =
  I.call client "getrawmempool" [True]

getRawMemPool :: IO RawMemPool
getRawMemPool = do
    txs <- R.client getRawMemPool_
    return (map T.makeTxEntry txs)

txEntry2UnconfTx :: T.TxEntry -> DB.UnconfTx
txEntry2UnconfTx tx = DB.UnconfTx (T.txid tx) (T.rate tx) (T.height tx)

txEntry2ConfTx :: B.Block -> T.TxEntry -> DB.ConfTx
txEntry2ConfTx b tx = DB.ConfTx (T.txid tx) (T.rate tx) (T.height tx) (B.height b) ((B.height b) - (T.height tx))

isConf :: B.Block ->  T.TxEntry -> Bool
isConf b tx = (T.txid tx) `elem` (B.tx b)

rawMem2ConfTx :: RawMemPool -> B.Block -> [DB.ConfTx]
rawMem2ConfTx rm b = map (txEntry2ConfTx b) ctx where
    ctx = filter (isConf b) rm

rawMem2UnconfTx :: RawMemPool -> [DB.UnconfTx]
rawMem2UnconfTx rm = fmap txEntry2UnconfTx rm

getMemPoolCount :: RawMemPool -> Int
getMemPoolCount = fmap length $ rawMem2UnconfTx
