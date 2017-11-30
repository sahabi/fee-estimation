module Daemon where

import Data.Default ( def )
import System.Environment ( getArgs )
import System.Daemon
import qualified DB      as DB
import qualified MemPool as M
import qualified Block   as B

addOne :: Int -> IO Int
addOne n = return (n + 1)

main :: IO ()
main = do
    ensureDaemonRunning "addOne" def addOne
    memp        <- M.getRawMemPool
    fetchUnconf <- DB.queryUnconfTx
    writeUnconf <- DB.insertUnconfTx (M.rawMem2UnconfTx memp)
    block       <- B.getBestBlock
    writeConf   <- DB.insertConfTx (M.rawMem2ConfTx memp block)

    res <- runClient "localhost" 5000 (writeUnconf)
    print (res :: Maybe Int)
