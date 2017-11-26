{-# LANGUAGE DuplicateRecordFields #-}
module Estimator where

import Test
import qualified Types as T
import Block as B
import MemPool
-- | from the list of txs of the current mempool and the latest 
--   block generate a list of confirmed transactions
getConfTx :: B.Block -> T.RawMemPool -> T.RawMemPool
getConfTx b = filter ((isConf b) . T.txid) 

getNoConfTx :: B.Block -> T.RawMemPool ->  T.RawMemPool
getNoConfTx b = filter (not . (isConf b) . T.txid) 

fst3 :: (a, b, c) -> a
fst3 (x, _, _) = x

isConf :: B.Block -> T.TxID -> Bool
isConf b t = t `elem` (B.tx b)

-- | This is the estimator algorithm based on 0.14
--estimator14 :: T.Target -> IO (T.FeeRate)
--estimator14 t = findLowest14 t $ getHistory period14

--getHistory :: T.Period -> IO ([Tx])
--getHistory (T.Period s e) =

run :: IO (T.RawMemPool, T.RawMemPool)
run = do
          mempool <- getRawMemPoolJ
          block <- getBestBlock  
          case mempool of
            Right mem -> return (getConfTx block mem, getNoConfTx block mem) 
