{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE OverlappingInstances #-}

module Types where

import Data.Aeson
import Data.Aeson.Types
import GHC.Generics
import Data.HashMap.Strict
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.FromRow

type Satoshi = Int

type Height = Int

type FeeRate = Satoshi

type TxID = String

type Bytes = Int

type BTC = Double

type UnixTime = Integer

data TxEntry_ = TxEntry_
        { txid_ :: TxID
        , txsize_ :: Bytes
        , modifiedfee_ :: BTC
        , time_ :: UnixTime
        , height_ :: Height
        } deriving Show

instance FromJSON [TxEntry_] where
  parseJSON x =
    parseJSON x >>= mapM parseTxEntry . toList

data TxEntry = TxEntry
        { txid :: TxID
        , txsize :: Bytes
        , fee :: BTC
        , time :: UnixTime
        , height :: Height
        , rate :: BTC
        } deriving (Show)

instance FromRow TxEntry where
    fromRow = TxEntry <$> field <*> field <*> field <*> field <*> field <*> field


parseTxEntry :: (String, Value) -> Parser TxEntry_
parseTxEntry (i, v) =
  withObject "entry body"  (\ o ->
    TxEntry_ i <$> o .: "size"
    <*> o .: "modifiedfee"
    <*> o .: "time"
    <*> o .: "height")
    v

makeTxEntry :: TxEntry_ -> TxEntry
makeTxEntry x = TxEntry (txid_ x) (txsize_ x) (modifiedfee_ x) (time_ x) (height_ x)
                $ (modifiedfee_ x) / (fromIntegral (txsize_ x))


newtype Counters = Counters [Counter] deriving (Show)

type Hash = String

data Counter = Counter { target  :: Height
                       , confAvg :: Float
                       , txCtAvg :: Float
                       } deriving (Show, Generic)


data FeeRange = FeeRange { min :: BTC
                         , max :: BTC
                         } deriving (Show, Generic)

data TargetRange = TargetRange { min :: Height
                               , max :: Height
                               } deriving (Show, Generic)

data FeeInfo = FeeInfo {
    short  :: FeeStat,
    medium :: FeeStat,
    long   :: FeeStat
    } deriving (Eq, Show, Generic)

instance FromJSON FeeInfo

data FeeStat = FeeStat {
    feerate :: Float,
    decay   :: Float,
    scale   :: Integer,
    pass    :: FeeStatInfo,
    fail    :: FeeStatInfo
    } deriving (Eq, Show, Generic)

instance FromJSON FeeStat

data FeeStatInfo = FeeStatInfo {
    startrange   :: Integer,
    endrange     :: Integer,
    withintarget :: Float,
    totalconfirmed :: Float,
    inmempool      :: Integer,
    leftmempool    :: Float
    } deriving (Eq, Show, Generic)

instance FromJSON FeeStatInfo

