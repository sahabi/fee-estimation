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
import qualified Types                   as Ty

updateUnconfTx :: Ty.Height -> IO ()
updateUnconfTx h = do
  putStrLn $ "unconf tx: updating unconfirmed transactions from block " ++ show h
  memp' <- M.getRawMemPool
  let memp = filter ((>= h) . Ty.height) memp'
  putStrLn "unconf tx: got mempool"
  numDel <- DB.deleteUnconfTx
  putStrLn $ "unconf tx: deleted table: " ++ show numDel
  res <- DB.insertUnconfTx $  M.rawMem2UnconfTx 50000 memp
  putStrLn $ "unconf tx: inserted records: " ++ show res
  putStrLn "unconf tx: updated unconfirmed transactions"

updateBuckets :: IO ()
updateBuckets = do
  putStrLn "update buckets: updating buckets"
  block <- B.getBestBlock
  lastblock <- DB.queryLastBlock
  case  (Just $ B.height block) > lastblock  of
    False -> case lastblock of
              Just a -> updateUnconfTx (a-25)
              Nothing -> putStrLn "there's no last block!"
    True ->  do
      unconf <- DB.queryUnconfTx
      numDel <- DB.deleteUnconfTx
      putStrLn $ "buckets update: deleted unconf table: " ++ show numDel
      updates <- updateBuckets_ block unconf
      DB.deleteLastBlock
      DB.insertLastBlock $ B.height block
      putStrLn $ "done buckets update: " ++ show (B.height block)

updateBuckets_ :: B.Block -> [DB.UnconfTx] -> IO Int
updateBuckets_ b unconf = return(1)

main = do rconn <- R.connect R.defaultConnectInfo
          scheduler <- create (Name $ Te.pack "default") rconn (CheckInterval (Seconds 60)) (LockTimeout (Seconds 600)) (T.putStrLn)
          addTask scheduler (Te.pack "update-unconftx") (Every (Seconds 60)) (updateBuckets)
          --addTask scheduler (Te.pack "update-conftx") (Every (Seconds 400)) (updateConfTx)
          forkIO (run scheduler)
          forkIO (run scheduler)
          forever (threadDelay 1000000)
