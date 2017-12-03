module Bucket where

data BucketTarget = BucketTarget {
                                   target :: Int
                                 , prob   :: Double
                                 , fee    :: Double
                                 }
toBucketTarget :: (Int, Double, Double) -> BucketTarget
toBucketTarget (target,prob,fee) = BucketTarget target prob fee

confTxToBT :: ConfTx -> BucketTarget
confTxToBT ctx = BucketTarget (cdheight ctx)

type Bucket = [BucketTarget]
