module ChainQuery where


import           Control.Lens              ((&), (?~))
import qualified Network.Wreq          as W
import qualified Network.Wreq.Session  as WS
import qualified Data.Text.Encoding        as TE
import qualified Data.Text as T
import qualified Client as C

withClient :: String -> Int -> (C.Client -> IO a) -> IO a
withClient host port callback =
  let options :: W.Options
      options = W.defaults 

      generateUrl :: String
      generateUrl = "https://" ++ host ++ ":" ++ show port

  in WS.withSession (callback . C.Client generateUrl options)

client :: (C.Client -> IO a) -> IO a
client = withClient "blockchain.info/unconfirmed-transactions" 443 
