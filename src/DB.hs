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
                                              (.===), runInsertMany, runDelete,
                                              (.++), ifThenElse, pgString, aggregate, groupBy,
                                              count, avg, sum, leftJoin, runQuery,
                                              showSqlForPostgres, Unpackspec,
                                              PGInt4, PGInt8, PGText, PGDate, PGFloat8, PGBool)
import Data.Profunctor.Product.Default      (Default)
import Data.Profunctor.Product              (p2, p3, p5)
import GHC.Int                              (Int64)
import Types                                as T
import Prelude hiding                       (sum)
import qualified Opaleye.PGTypes            as P
import qualified Database.PostgreSQL.Simple as PGS

data UnconfTx = UnconfTx
            { txid :: T.TxID
            , rate :: T.BTC
            , height :: T.Height
            } deriving (Show)

toUnconfTx :: (T.TxID, T.BTC, T.Height) -> UnconfTx
toUnconfTx (s,d,i) = UnconfTx s d i


unconfTxTable :: Table (Column PGText, Column PGFloat8, Column PGInt4)
                     (Column PGText, Column PGFloat8, Column PGInt4)
unconfTxTable = Table "unconftxtable" (p3 ( required "txid"
                                      , required "rate"
                                      , required "height" ))

unconfTxQuery :: Query (Column PGText, Column PGFloat8, Column PGInt4)
unconfTxQuery = queryTable unconfTxTable

queryUnconfTx :: IO [UnconfTx]
queryUnconfTx = do {
        con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"}
      ; res <- runQuery con unconfTxQuery
      ; return (fmap toUnconfTx res)
      }
tqueryUnconfTx :: IO [ (T.TxID, T.BTC, T.Height)]
tqueryUnconfTx = do {
        con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"}
      ; res <- runQuery con unconfTxQuery
      ; return (res)
      }


insertUnconfTx :: String
               -> Column PGFloat8
               -> Column PGInt4
               -> IO Int64
insertUnconfTx txid rate h = do {
                                con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"}
                                ; runInsertMany con unconfTxTable (return (P.pgString txid, rate, h))
                                }

data ConfTx = ConfTx { txid :: T.TxID
                     , rate :: T.BTC
                     , mheight :: T.Height
                     , bheight :: T.Height
                     , dheight :: T.Height
                     } deriving (Show)

toConfTx :: (String, Double, Int, Int, Int) -> ConfTx
toConfTx (s,d,i,ii,iii) = ConfTx s d i ii iii

confTxTable :: Table (Column PGText, Column PGFloat8, Column PGInt4, Column PGInt4, Column PGInt4)
                     (Column PGText, Column PGFloat8, Column PGInt4, Column PGInt4, Column PGInt4)
confTxTable = Table "conftxtable" (p5 ( required "txid"
                                      , required "rate"
                                      , required "mheight"
                                      , required "bheight"
                                      , required "dheight"))


confTxQuery :: Query (Column PGText, Column PGFloat8, Column PGInt4, Column PGInt4, Column PGInt4)
confTxQuery = queryTable confTxTable


queryConfTx :: IO [ConfTx]
queryConfTx = do {
                 con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"}
                 ; res <- runQuery con confTxQuery
                 ; return (fmap toConfTx res)
                 }

insertConfTx :: String
             -> Column PGFloat8
             -> Column PGInt4
             -> Column PGInt4
             -> Column PGInt4
             -> IO Int64
insertConfTx txid rate mh bh dh = do {
                                     con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"}
                                     ; runInsertMany con confTxTable (return (P.pgString txid, rate, mh, bh, dh))
                                     }


printSql :: Default Unpackspec a a => Query a -> IO ()
printSql = putStrLn . maybe "Empty query" id . showSqlForPostgres
