module Client where


import           Control.Lens              ((&), (?~))
import qualified Network.Wreq          as W
import qualified Network.Wreq.Session  as WS
import qualified Data.Text.Encoding        as TE
import qualified Data.Text as T

-- | Client session data

data Client = Client {
  clientUrl     :: String,    -- ^ The JSON RPC url
  clientOpts    :: W.Options, -- ^ Default HTTP options to use with `wreq` requests
  clientSession :: WS.Session -- ^ Connection reuse of our HTTP session
  } deriving ( Show )

withClient :: String -> Int -> T.Text -> T.Text -> (Client -> IO a) -> IO a
withClient host port user pass callback =
  let options :: W.Options
      options = W.defaults & applyAuth

      applyAuth = W.auth ?~ W.basicAuth (TE.encodeUtf8 user) (TE.encodeUtf8 pass)

      generateUrl :: String
      generateUrl = "http://" ++ host ++ ":" ++ show port

  in WS.withSession (callback . Client generateUrl options)

client :: (Client -> IO a) -> IO a
client = withClient "127.0.0.1" 8332 (T.pack "sahabi") (T.pack "5555")
