{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
module Estimation where
import Control.Applicative
import Control.Monad
import Control.Monad.IO.Class
--import Control.Monad.Trans.Either
import Data.Monoid
import Data.Proxy
import Data.Text (Text)
import Data.Int
import Data.Aeson
import Data.ByteString.Lazy
import GHC.Generics
import Network.HTTP.Conduit
import Servant.API 
import Servant.Client
import qualified Data.ByteString.Lazy as B
import qualified Data.Text as T
import qualified Data.Text.IO as T

server = "https://bitcoinfees.earn.com/api/v1/fees/"

type EarnAPI =
        "recommended" :> Get '[JSON] [Recommended]
  :<|>  "list"        :> Get '[JSON] [FeeList]

data Recommended = Recommended
                   { fastestFee  :: Int,
                     halfHourFee :: Int,
                     hourFee     :: Int
                   } deriving (Show, Generic)

instance FromJSON Recommended

data FeeList = FeeList 
               { fees :: [FeeInfo] 
               } deriving (Show, Generic)

instance FromJSON FeeList

data FeeInfo = FeeInfo
               { minFee     :: Int,
                 maxFee     :: Int,
                 dayCount   :: Int,
                 memCount   :: Int,
                 minDelay   :: Int,
                 maxDelay   :: Int,
                 minMinutes :: Int,
                 maxMinutes :: Int
               } deriving (Show, Generic)

instance FromJSON FeeInfo

-- | Builds the bitcoinfees.earn.com endpoint URL
apiEndpointUrl :: Text -> Text -> Text
apiEndpointUrl server request = 
   T.concat [server, request]

-- | Represents getting the fee recommendation from the URL 
getRecommended :: IO (Maybe Recommended)
getRecommended =
  fmap decode $ simpleHttp $ server ++ "recommended"

getFeeList :: IO (Maybe FeeList)
getFeeList = 
  fmap decode $ simpleHttp $ server ++ "list"

getMinFee :: IO (Maybe FeeInfo)
getMinFee = do
  fl <- getFeeList 
  let min = Prelude.head <$> (fees <$> fl)
  return min 

getJSON :: IO B.ByteString
getJSON = simpleHttp $ server ++ "list"


--calcFee :: Size -> Rate -> BTC
--calcFee = (*)

