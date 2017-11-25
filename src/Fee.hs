{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Fee where

import           Data.Aeson
import           Data.Aeson.Types

import GHC.Generics
import qualified Data.HashMap.Strict       as HM
import qualified Interface                 as I
import qualified Client                    as C

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

-- |
getFeeEstimate :: C.Client         -- ^ Our client context
               -> IO FeeInfo    -- ^ The address created
getFeeEstimate client =
  I.call client "estimaterawfee"  [(6 :: Integer)]

