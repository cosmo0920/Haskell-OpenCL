module FT_1d.Util
   ( onError
   , programSourceFromFile
   , toNum
   , toStrings
   , numberFromFile
   ) where
import Foreign.C.Types( CDouble )
import System.IO
import System.Exit
import System.Environment
import qualified Control.Exception as E

--error handling
onError :: String -> IOError -> IO String
onError filename _error = do
  hPutStrLn stderr $ "File not found: " ++ filename ++ usage
  exitWith(ExitFailure 1)

usage :: String
usage = unlines $ [ ""
                  , "usage:"
                  , "ft_1d [input data file]"]

--read from file
programSourceFromFile :: IO String
programSourceFromFile = do
  let clprogramName = "ft_1d.cl"
  E.catch (readFile clprogramName)
          (onError clprogramName)

-- transform String to [CDouble]
toNum :: String -> [CDouble]
toNum = foldr toNumber [] . words
  where toNumber xs number = read xs:number

-- transform [CDouble] to String
toStrings :: [CDouble] -> String
toStrings = unlines . foldr toStr []
  where toStr xs number = show xs:number

-- read input value from File
numberFromFile :: IO String
numberFromFile = do
  args <- getArgs
  if length args /= 0 then do
    let cltransformSource = head args
    E.catch (readFile cltransformSource)
            (onError cltransformSource)
  else do
    let cltransformSource = "input.txt"
    E.catch (readFile cltransformSource)
            (onError cltransformSource)