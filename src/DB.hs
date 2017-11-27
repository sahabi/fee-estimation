{-# LANGUAGE Arrows #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TemplateHaskell #-}

module DB where

import Prelude hiding (sum)
import           Data.Profunctor.Product.Default (Default)
import           Data.Profunctor.Product (p2, p3, p5)
import           Opaleye (Column, Nullable, matchNullable, isNull,
                         Table(Table), required, queryTable,
                         Query, QueryArr, restrict, (.==), (.<=), (.&&), (.<),
                         (.===), runInsertMany, runDelete, 
                         (.++), ifThenElse, pgString, aggregate, groupBy,
                         count, avg, sum, leftJoin, runQuery,
                         showSqlForPostgres, Unpackspec,
                         PGInt4, PGInt8, PGText, PGDate, PGFloat8, PGBool)
import qualified Opaleye.PGTypes as P
import qualified Database.PostgreSQL.Simple as PGS
import GHC.Int (Int64)
import Types as T

unconfTxTable :: Table (Column PGText, Column PGFloat8, Column PGInt4)
                     (Column PGText, Column PGFloat8, Column PGInt4)
unconfTxTable = Table "unconftxtable" (p3 ( required "txid"
                                      , required "rate"
                                      , required "height" ))

unconfTxQuery :: Query (Column PGText, Column PGFloat8, Column PGInt4)
unconfTxQuery = queryTable unconfTxTable

insertUnconfTx :: IO Int64 
insertUnconfTx = do { 
           con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"} 
         ; runInsertMany con unconfTxTable (return (P.pgString "123", 2.0, 3))
         }

runUnconfTxQuery :: PGS.Connection
                 -> Query (Column PGText, Column PGFloat8, Column PGInt4)
                 -> IO [(String, Double, Int)]
runUnconfTxQuery = runQuery

confTxTable :: Table (Column PGText, Column PGFloat8, Column PGInt4, Column PGInt4, Column PGInt4)
                     (Column PGText, Column PGFloat8, Column PGInt4, Column PGInt4, Column PGInt4)
confTxTable = Table "conftxtable" (p5 ( required "txid"
                                      , required "rate"
                                      , required "mheight"
                                      , required "bheight"
                                      , required "dheight"))

confTxQuery :: Query (Column PGText, Column PGFloat8, Column PGInt4, Column PGInt4, Column PGInt4)
confTxQuery = queryTable confTxTable

insertConfTx :: IO Int64 
insertConfTx = do { 
           con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"} 
         ; runInsertMany con confTxTable (return (P.pgString "123", 2.0, 3, 2, 1))
         }


{-do { con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"} ; runUnconfTxQuery con unconfTxQuery  }-}
{-do { con <- PGS.connect PGS.defaultConnectInfo { PGS.connectDatabase = "sahabi"} ; runConfTxQuery con confTxQuery  }-}

runConfTxQuery :: PGS.Connection
                 -> Query (Column PGText, Column PGFloat8, Column PGInt4, Column PGInt4, Column PGInt4)
                 -> IO [(String, Double, Int, Int, Int)]
runConfTxQuery = runQuery

printSql :: Default Unpackspec a a => Query a -> IO ()
printSql = putStrLn . maybe "Empty query" id . showSqlForPostgres
