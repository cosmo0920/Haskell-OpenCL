{-# LANGUAGE ScopedTypeVariables #-}
module FT_1d.Execute
    ( executeCLMain ) where
import Control.Parallel.OpenCL
import FT_1d.Device

executeCLMain :: IO ()
executeCLMain = do
  -- initialize OpenCL
  platforms <- clGetPlatformIDs
  putStrLn $ show platforms
  mapM_ clDevice [platforms]
