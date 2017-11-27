{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
import Network.HTTP.Conduit (simpleHttp)
import Data.Aeson
import GHC.Generics

data TxIn =
  TxIn { sequence :: Int
       , witness :: String
       , prev_out :: [TxOut]
       , script :: String
       } deriving (Show, Generic)

data TxOut =
  TxOut { spent :: Bool
        , tx_index :: Int
        , addr :: String
        , value :: Int
        , n :: Int
        , script :: String
     } deriving (Show, Generic)

instance FromJSON TxIn
instance FromJSON TxOut

data Tx = 
  Tx { ver :: Int
--     , inputs :: [TxIn]
--     , weight :: Int
--     , relayed_by :: String
--     , out :: [TxOut]
--     , lock_time :: Int
--     , size :: Int
--     , double_spend :: Bool
--     , time :: Int
--     , tx_index :: Int
--     , vin_sz :: Int
--     , hash :: String
--     , vout_sz :: Int 
     } deriving (Show, Generic)

instance FromJSON Tx 

data UnconfTx =
  UnconfTx { txs :: [Tx] 
               } deriving (Show, Generic)

instance FromJSON UnconfTx 

getConversion :: IO (Maybe UnconfTx)
getConversion  =
  fmap decode $ simpleHttp $
      "https://blockchain.info/unconfirmed-transactions?format=json"
