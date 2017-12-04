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
import Bucket

updateBuckets :: IO ()
updateBuckets = do
  putStrLn "update buckets: updating buckets"
  memp <- M.getRawMemPool
  unconf <- DB.queryUnconfTx
  lastblock <- DB.queryLastBlock
  DB.deleteUnconfTx
  DB.insertUnconfTx $ M.rawMem2UnconfTx 50000 memp
  block <- B.getBestBlock
  case  (Just $ B.height block) > lastblock  of
    False -> case lastblock of
              Nothing -> putStrLn "there's no last block!"
              otherwise -> putStrLn "no new block."
    True ->  do
      let conf = unconf2ConfTx unconf block
      case length conf of
        0 -> putStrLn "not a single confirmation!"
        otherwise -> do
          num <- updateBuckets' conf
          DB.deleteLastBlock
          DB.insertLastBlock $ B.height block
          putStrLn ""
  putStrLn $ "done buckets update: " ++ show (B.height block)

updateBuckets' :: [DB.ConfTx] -> IO Int
updateBuckets' conf =

conf2Bucket :: DB.ConfTx -> Bucket
conf2Bucket conf  :: Bucket (getRange $ crate

main = do rconn <- R.connect R.defaultConnectInfo
          scheduler <- create (Name $ Te.pack "default") rconn (CheckInterval (Seconds 60))
            (LockTimeout (Seconds 600)) (T.putStrLn)
          addTask scheduler (Te.pack "update-unconftx") (Every (Seconds 60)) (updateBuckets)
          forkIO (run scheduler)
          --forkIO (run scheduler)
          forever (threadDelay 1000000)
