module Estimator where

import qualified Types as T
import Block
import MemPool
-- | from the list of txs of the current mempool and the latest 
--   block generate a list of confirmed transactions
getConfTx :: T.RawMemPool -> T.Block -> [T.TxID]
getConfTx memp b = filter (onlyConf b) tx where tx = [ T.txid i | i <- memp ] 

onlyConf :: T.Block -> T.TxID -> Bool
onlyConf b t = t `elem` (T.tx b)

-- | This is the estimator algorithm based on 0.14
--estimator14 :: T.Target -> IO (T.FeeRate)
--estimator14 t = findLowest14 t $ getHistory period14

--getHistory :: T.Period -> IO ([Tx])
--getHistory (T.Period s e) =

run :: IO [T.TxID]
run = do
          mempool <- getRawMemPool
          block <- getBestBlock  
          return (getConfTx mempool block) 
