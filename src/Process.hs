module Process where
import           Tx
import           Data.List
import           Control.Monad      (forever)
import           System.Periodic
import           Control.Concurrent      (threadDelay, forkIO)
import qualified DB      as DB
import qualified MemPool as M
import qualified Block   as B
import qualified Data.Text.IO            as T
import qualified Database.Redis          as R
import qualified Data.Text               as Te

updateUnconfTx :: IO ()
updateUnconfTx = do
    memp        <- M.getRawMemPool
    dbUnconf    <- DB.queryUnconfTx
    res <- DB.insertUnconfTx  ( ((M.rawMem2UnconfTx 500 memp)) \\ dbUnconf)
    print res

updateConfTx :: IO ()
updateConfTx = do
    dbUnconf    <- DB.queryUnconfTx
    block       <- B.getBestBlock
    dbConf      <- DB.queryConfTx
    res         <- DB.insertConfTx $ ((Tx.unconf2ConfTx dbUnconf block) \\ dbConf)
    print res

main = do rconn <- R.connect R.defaultConnectInfo
          scheduler <- create (Name $ Te.pack "default") rconn (CheckInterval (Seconds 60)) (LockTimeout (Seconds 600)) (T.putStrLn)
          addTask scheduler (Te.pack "update-unconftx") (Every (Seconds 3600)) (updateUnconfTx)
          addTask scheduler (Te.pack "update-conftx") (Every (Seconds 400)) (updateConfTx)
          forkIO (run scheduler)
          --forkIO (run scheduler)
          forever (threadDelay 1000000)
