module Main where

import Lib

target = 1
estimator :: Integer -> Integer
estimator t = t

main :: IO ()
main = print $ estimator target 
