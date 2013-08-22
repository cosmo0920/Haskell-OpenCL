module FT_1d.Internal
   ( execCL ) where
import Control.Parallel.OpenCL
import Foreign( castPtr, nullPtr, sizeOf )
import Foreign.C.Types( CDouble )
import Foreign.Marshal.Array( newArray, peekArray )
import FT_1d.Settings

execCL :: CLDeviceID -> IO ()
execCL dev = do
  context <- clCreateContext [] [dev] print
  q <- clCreateCommandQueue context dev []

  -- Compile and get binaries
  clsource <- programSourceFromFile
  program <- clCreateProgramWithSource context clsource
  clBuildProgram program [dev] ""
  bins <- clGetProgramBinaries program

  -- Create kernel from binaries
  (program2,_) <- clCreateProgramWithBinary context [dev] bins
  let clkernelBuildOption = ""
      clkernelName = "arrayft_1d"
  clBuildProgram program2 [dev] clkernelBuildOption
  kernel <- clCreateKernel program2 clkernelName
  -- read transform source
  insource <- numberFromFile

  -- Initialize parameters
  let original = toNum insource -- read from file [CDouble] value
      elemSize = sizeOf (0 :: CDouble) -- or CFloat
      vecSize = elemSize * length original

  putStrLn $ "Original array = \n" ++ toStrings original
  input <- newArray original

  mem_in <- clCreateBuffer context [CL_MEM_READ_ONLY, CL_MEM_COPY_HOST_PTR] (vecSize, castPtr input)
  mem_out <- clCreateBuffer context [CL_MEM_WRITE_ONLY] (vecSize, nullPtr)

  clSetKernelArgSto kernel 0 mem_in
  clSetKernelArgSto kernel 1 mem_out

  {- Execute Kernel
   * clEnqueueNDRangeKernel
     1. commandqueue
     2. clkernel
     3. global work size
     4. local work size (perhaps best for performance => [](NULL) )
     5. clevent (always NULL)
  -}
  eventExec <- clEnqueueNDRangeKernel q kernel [length original] [] []

  -- Get Result
  _eventRead <- clEnqueueReadBuffer q mem_out True 0 vecSize (castPtr input) [eventExec]
  result <- peekArray (length original) input
  putStrLn $ "Result array   = \n" ++ toStrings result
  return ()
