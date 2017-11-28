module Client where

import qualified Network.Wreq         as W
import qualified Network.Wreq.Session as WS
-- | Client session data

data Client = Client { 
                       clientUrl     :: String
                     , clientOpts    :: W.Options
                     , clientSession :: WS.Session
                     } deriving ( Show )


