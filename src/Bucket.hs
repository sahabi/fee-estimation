module Bucket where

import qualified Types as T

data Target = Target {
                       target :: T.Height
                     , prob   :: Double
                     , rate   :: T.Satoshi
                     }
data TargetB = TargetB { bminRange :: T.Satoshi
                       , bmaxRange :: T.Satoshi
                       , btotalTx :: Int
                       , btarget :: T.Height
                       , bprob :: Double
                       , brate :: T.Satoshi
                      }
toTarget :: (Int, Double, Int) -> Target
toTarget (target,prob,fee) = Target target prob fee

toTargetB :: (Int, Int, Int, Int, Double, Int) -> TargetB
toTargetB (min,max,tot,target,prob,rate) = TargetB min max tot target prob rate


data Bucket = Bucket { minRange :: T.Satoshi
                     , maxRange :: T.Satoshi
                     , totalTx :: Int
                     , targets :: [Target]
                     }
