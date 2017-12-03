module Bucket where

data BucketTarget = BucketTarget {
                                   target :: Int
                                 , prob   :: Double
                                 , fee    :: Double
                                 }
toBucketTarget :: (Int, Double, Double) -> BucketTarget
toBucketTarget (target,prob,fee) = BucketTarget target prob fee

--confTxToBT :: ConfTx -> BucketTarget
--confTxToBT ctx = BucketTarget (cdheight ctx) 1.0 1.0

type Bucket = [BucketTarget]
