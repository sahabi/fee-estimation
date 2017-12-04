{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE Arrows #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TemplateHaskell #-}

module DB where

import Opaleye                              (Column, Nullable, matchNullable, isNull,
                                              Table(Table), required, queryTable,
                                              Query, QueryArr, restrict, (.==), (.<=), (.&&), (.<),
                                              (.===),  runInsertMany, runDelete,
                                              (.++), ifThenElse, pgString, aggregate, groupBy,
                                              count, avg, sum, leftJoin, runQuery,
                                              showSqlForPostgres, Unpackspec,
                                              PGInt4, PGInt8, PGText, PGDate, PGFloat8, PGBool)
import Data.Profunctor.Product.Default      (Default)
import Data.Profunctor.Product              (p2, p3, p5, p6)
import GHC.Int                              (Int64)
import Types                                as T
import Prelude hiding                       (sum)
import qualified Opaleye.PGTypes            as P
import qualified Database.PostgreSQL.Simple as PGS
import qualified Block                      as B
import Bucket

data UnconfTx = UnconfTx
  { uctxid :: T.TxID
    , ucrate :: T.Satoshi
    , ucheight :: T.Height
  } deriving (Show)

instance Eq UnconfTx where
  x == y = (uctxid x) == (uctxid y)

isConf :: B.Block -> UnconfTx -> Bool
isConf b tx = (uctxid tx) `elem` (B.tx b)

toUnconfTx :: (T.TxID, T.Satoshi, T.Height) -> UnconfTx
toUnconfTx (s,d,i) = UnconfTx s d i


unconfTxTable :: Table (Column PGText, Column PGInt4, Column PGInt4)
                     (Column PGText, Column PGInt4, Column PGInt4)
unconfTxTable = Table "unconftxtable" (p3 ( required "txid"
  , required "rate"
  , required "height" ))

unconfTxQuery :: Query (Column PGText, Column PGInt4, Column PGInt4)
unconfTxQuery = queryTable unconfTxTable

queryUnconfTx :: IO [UnconfTx]
queryUnconfTx = do {
                   con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"}
      ; res <- runQuery con unconfTxQuery
      ; return (fmap toUnconfTx res)
                   }
tqueryUnconfTx :: IO [ (T.TxID, T.Satoshi, T.Height)]
tqueryUnconfTx = do {
        con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"}
      ; res <- runQuery con unconfTxQuery
      ; return (res)
      }

insertUnconfTx :: [UnconfTx]
               -> IO Int64
insertUnconfTx uc = do {
                        con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"}
                        ; runInsertMany con unconfTxTable [
                        (P.pgString $ uctxid x
                       , P.pgInt4 $ ucrate x
                       , P.pgInt4 $ ucheight x ) | x <- uc]
                        }
deleteUnconfTx :: IO Int64
deleteUnconfTx = do {
                        con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"}
                        ; runDelete con unconfTxTable (\_ -> P.pgBool True)
                       }


data ConfTx = ConfTx { ctxid :: T.TxID
                     , crate :: T.Satoshi
                     , cmheight :: T.Height
                     , cbheight :: T.Height
                     , cdheight :: T.Height
                     } deriving (Show)

instance Eq ConfTx where
  x == y = (ctxid x) == (ctxid y)

toConfTx :: (String, Int, Int, Int, Int) -> ConfTx
toConfTx (txid,rate,mh,bh,dh) = ConfTx txid rate mh bh dh

confTxTable :: Table (Column PGText, Column PGInt4, Column PGInt4, Column PGInt4, Column PGInt4)
                     (Column PGText, Column PGInt4, Column PGInt4, Column PGInt4, Column PGInt4)
confTxTable = Table "conftxtable" (p5 ( required "txid"
                                      , required "rate"
                                      , required "mheight"
                                      , required "bheight"
                                      , required "dheight"))


confTxQuery :: Query (Column PGText, Column PGInt4, Column PGInt4, Column PGInt4, Column PGInt4)
confTxQuery = queryTable confTxTable


queryConfTx :: IO [ConfTx]
queryConfTx = do {
                 con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"}
                 ; res <- runQuery con confTxQuery
                 ; return (fmap toConfTx res)
                 }

insertConfTx :: [ConfTx]
             -> IO Int64

insertConfTx c = do {
                     con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"}
                   ; runInsertMany con confTxTable [
                      (P.pgString $ ctxid x
                     , P.pgInt4 $ crate x
                     , P.pgInt4 $ cmheight x
                     , P.pgInt4 $ cbheight x
                     , P.pgInt4 $ cdheight x) | x <- c]
                     }

deleteConfTx :: IO Int64
deleteConfTx = do {
                        con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"}
                        ; runDelete con confTxTable (\_ -> P.pgBool True)
                       }


bucketTable :: Table ( Column PGInt4
                     , Column PGInt4
                     , Column PGInt4
                     , Column PGInt4
                     , Column PGFloat8
                     , Column PGInt4
                     )
                     ( Column PGInt4
                     , Column PGInt4
                     , Column PGInt4
                     , Column PGInt4
                     , Column PGFloat8
                     , Column PGInt4
                     )
bucketTable = Table "buckettable" (p6 ( required "minrange"
                                      , required "maxrange"
                                      , required "totaltx"
                                      , required "target"
                                      , required "prob"
                                      , required "rate"))


bucketQuery :: Query ( Column PGInt4
                     , Column PGInt4
                     , Column PGInt4
                     , Column PGInt4
                     , Column PGFloat8
                     , Column PGInt4
                     )

bucketQuery = queryTable bucketTable

queryTargetB :: IO [TargetB]
queryTargetB = do {
                 con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"}
                 ; res <- runQuery con bucketQuery
                 ; return (fmap toTargetB res)
                 }

insertTargets :: Bucket
             -> IO Int64

insertTargets b = do {
                     con <- PGS.connect PGS.defaultConnectInfo {
                                         PGS.connectDatabase = "sahabi"
                                                               }
                   ; let ts = Bucket.targets b
                   ; runInsertMany con bucketTable [
                   ( P.pgInt4   $ Bucket.minRange b
                   , P.pgInt4   $ Bucket.maxRange b
                   , P.pgInt4   $ Bucket.totalTx b
                   , P.pgInt4   $ Bucket.target t
                   , P.pgDouble $ Bucket.prob t
                   , P.pgInt4   $ Bucket.rate t
                   ) | t <- ts]
                          }

insertBuckets :: [Bucket] -> IO [Int64]
insertBuckets = sequence . (fmap insertTargets)

lastBlockTable :: Table (Column PGInt4)
                        (Column PGInt4)

lastBlockTable = Table "lastblocktable" ( required "height" )


lastBlockQuery :: Query (Column PGInt4)
lastBlockQuery = queryTable lastBlockTable

queryLastBlock :: IO (Maybe T.Height)
queryLastBlock = do
                    con <- PGS.connect PGS.defaultConnectInfo {PGS.connectDatabase = "sahabi"}
                    res <- runQuery con lastBlockQuery
                    case length res of
                      0         -> return Nothing
                      otherwise -> return $ Just (head res ::Int)

insertLastBlock :: T.Height
                -> IO Int64

insertLastBlock c = do {
                     con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"}
                   ; runInsertMany con lastBlockTable [P.pgInt4 c]
                     }

deleteLastBlock :: IO Int64
deleteLastBlock = do {
                        con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"}
                        ; runDelete con lastBlockTable (\_ -> P.pgBool True)
                       }

printSql :: Default Unpackspec a a => Query a -> IO ()
printSql = putStrLn . maybe "Empty query" id . showSqlForPostgres
