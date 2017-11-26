import Data.Aeson
import qualified Data.ByteString.Lazy as B
import qualified Types as T

MempoolFile :: FilePath
mempoolFile = "Mempool.json"

getJSON :: IO B.ByteString
getJSON = B.readFile mempoolFile

main :: IO ()
main = do
 d <- (eitherDecode <$> getJSON) :: IO (Either String [T.TxEntry_])
 case d of
  Left err -> putStrLn err
  Right ps -> print (fmap T.makeTxEntry ps)
