module FT_1d.Device
    ( clDevice
    , clDeviceGPU ) where
import Control.Parallel.OpenCL
import Control.Monad
import FT_1d.Internal

clDevice :: [CLPlatformID] -> IO ()
clDevice _platform = forM_ _platform $ \platform -> do
  devs <- clGetDeviceIDs platform CL_DEVICE_TYPE_ALL
  mapM_ clDeviceGPU devs

-- execute OpenCL Kernel Program on GPU Type Device
clDeviceGPU :: CLDeviceID -> IO ()
clDeviceGPU dev = do
  devtype <- clGetDeviceType dev
  putStrLn $ show devtype
  when (show devtype == show [CL_DEVICE_TYPE_GPU])
           $ mapM_ execCL [dev]