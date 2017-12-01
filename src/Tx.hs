module Tx where

import qualified Block as B
import DB

unconf2ConfTx_ :: B.Block -> DB.UnconfTx -> DB.ConfTx
unconf2ConfTx_ b unconf = DB.ConfTx   (DB.uctxid unconf)
                                      (DB.ucrate unconf)
                                      (DB.ucheight unconf)
                                      (B.height b)
                                      ((B.height b) - (DB.ucheight unconf))


unconf2ConfTx :: [DB.UnconfTx] -> B.Block -> [DB.ConfTx]
unconf2ConfTx unconf b = map (unconf2ConfTx_ b) ctx where
    ctx = filter (DB.isConf b) unconf


