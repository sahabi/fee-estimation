#!/usr/bin/env stack
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
-- stack script --resolver lts-8.22
import           Data.Aeson.Parser           (json)
import           Data.Conduit                (($$))
import           Data.Conduit.Attoparsec     (sinkParser)
import           Network.HTTP.Client
import           Network.HTTP.Client.Conduit (bodyReaderSource)
import           Network.HTTP.Client.TLS     (tlsManagerSettings)
import           Network.HTTP.Types.Status   (statusCode)
import           Data.Aeson
import qualified Data.Text as T
data Person = Person {name :: String, age :: Int}

instance FromJSON Person where
  parseJSON = withObject "person" $ \o -> do
    name <- o .: "name"
    age <- o .: "age"
    return Person{..}    

main :: Maybe a 
main = do
    manager <- newManager tlsManagerSettings

    request <- parseRequest "https://blockchain.info/unconfirmed-transactions?format=json"

    withResponse request manager $ \response -> do
        --putStrLn $ "The status code was: " ++
        --           show (statusCode $ responseStatus response)

        value <- bodyReaderSource (responseBody response)
              $$ sinkParser json
        decode value :: IO (Person) 
