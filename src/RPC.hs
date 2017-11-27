module RPC where

import           Control.Lens              ((&), (?~))
import qualified Network.Wreq          as W
import qualified Network.Wreq.Session  as WS
import qualified Data.Text.Encoding    as TE
import qualified Data.Text             as T
import qualified Client                as C

withClient :: String -> Int -> T.Text -> T.Text -> (C.Client -> IO a) -> IO a
withClient host port user pass callback =
  let options :: W.Options
      options = W.defaults & applyAuth

      applyAuth = W.auth ?~ W.basicAuth (TE.encodeUtf8 user) (TE.encodeUtf8 pass)

      generateUrl :: String
      generateUrl = "http://" ++ host ++ ":" ++ show port

  in WS.withSession (callback . C.Client generateUrl options)

client :: (C.Client -> IO a) -> IO a
client = withClient "127.0.0.1" 8332 (T.pack "sahabi") (T.pack "5555")
