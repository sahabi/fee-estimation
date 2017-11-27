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

unconfTxTable :: Table (Column PGText, Column PGFloat8, Column PGInt4)
                     (Column PGText, Column PGFloat8, Column PGInt4)
unconfTxTable = Table "unconftxtable" (p3 ( required "txid"
                                      , required "rate"
                                      , required "height" ))

confTxTable :: Table (Column PGText, Column PGFloat8, Column PGInt4, Column PGInt4, Column PGInt4)
                     (Column PGText, Column PGFloat8, Column PGInt4, Column PGInt4, Column PGInt4)
confTxTable = Table "conftxtable" (p5 ( required "txid"
                                      , required "rate"
                                      , required "mheight"
                                      , required "bheight"
                                      , required "dheight"))

unconfTxQuery :: Query (Column PGText, Column PGFloat8, Column PGInt4)
unconfTxQuery = queryTable unconfTxTable

confTxQuery :: Query (Column PGText, Column PGFloat8, Column PGInt4, Column PGInt4, Column PGInt4)
confTxQuery = queryTable confTxTable

runUnconfTxQuery :: PGS.Connection
                 -> Query (Column PGText, Column PGFloat8, Column PGInt4)
                 -> IO [(String, Double, Int)]
runUnconfTxQuery = runQuery

runConfTxQuery :: PGS.Connection
               -> Query (Column PGText, Column PGFloat8, Column PGInt4, Column PGInt4, Column PGInt4)
               -> IO [(String, Double, Int, Int, Int)]
runConfTxQuery = runQuery


insertUnconfTx :: String 
               -> Column PGFloat8 
               -> Column PGInt4 
               -> IO Int64 
insertUnconfTx txid rate h = do { 
           con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"} 
         ; runInsertMany con unconfTxTable (return (P.pgString txid, rate, h))
         }

insertConfTx :: String 
             -> Column PGFloat8 
             -> Column PGInt4 
             -> Column PGInt4 
             -> Column PGInt4 
             -> IO Int64 
insertConfTx txid rate mh bh dh= do { 
           con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"} 
         ; runInsertMany con confTxTable (return (P.pgString txid, rate, mh, bh, dh))
         }

printSql :: Default Unpackspec a a => Query a -> IO ()
printSql = putStrLn . maybe "Empty query" id . showSqlForPostgres
