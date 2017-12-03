{-# LANGUAGE DuplicateRecordFields #-}
module Estimator where

import qualified Bucket as B
import DB

type Prob = Double
type MedianFee = Double
type Target = Integer

-- | This is the estimator algorithm based on 0.14
estimator14 :: Target -> IO (MedianFee)
estimator14 t = do
  buckets <- DB.queryBucket
  return (B.fee $ getBucketTarget t (findLowestBucket14 t buckets))

findLowestBucket14 :: Target -> [B.Bucket] -> B.Bucket
findLowestBucket14 t bs = last $ takeWhile (cr) bs where
  cr = ((>0.95) . B.prob . (getBucketTarget t))

getBucketTarget :: Target -> B.Bucket -> B.BucketTarget
getBucketTarget t b =  head $ filter ((== t) . B.target) b


