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
import qualified Block                      as B

data UnconfTx = UnconfTx
  { uctxid :: T.TxID
    , ucrate :: T.BTC
    , ucheight :: T.Height
  } deriving (Show)

instance Eq UnconfTx where
  x == y = (uctxid x) == (uctxid y)

isConf :: B.Block -> UnconfTx -> Bool
isConf b tx = (uctxid tx) `elem` (B.tx b)

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

insertUnconfTx :: [UnconfTx]
               -> IO Int64
insertUnconfTx uc = do {
                        con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"}
                        ; runInsertMany con unconfTxTable [
                        (P.pgString $ uctxid x
                       , P.pgDouble $ ucrate x
                       , P.pgInt4 $ ucheight x ) | x <- uc]
                        }

data ConfTx = ConfTx { ctxid :: T.TxID
                     , crate :: T.BTC
                     , cmheight :: T.Height
                     , cbheight :: T.Height
                     , cdheight :: T.Height
                     } deriving (Show)

instance Eq ConfTx where
  x == y = (ctxid x) == (ctxid y)

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

insertConfTx :: [ConfTx]
             -> IO Int64

insertConfTx c = do {
                     con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"}
                   ; runInsertMany con confTxTable [
                      (P.pgString $ ctxid x
                     , P.pgDouble $ crate x
                     , P.pgInt4 $ cmheight x
                     , P.pgInt4 $ cbheight x
                     , P.pgInt4 $ cdheight x) | x <- c]
                     }


printSql :: Default Unpackspec a a => Query a -> IO ()
printSql = putStrLn . maybe "Empty query" id . showSqlForPostgres
