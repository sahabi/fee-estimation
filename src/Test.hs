module Test where
import Data.Aeson
import qualified Data.ByteString.Lazy as B
import qualified Types as T

mempoolFile :: FilePath
mempoolFile = "Mempool.json"

getJSON :: IO B.ByteString
getJSON = B.readFile mempoolFile

getRawMemPoolJ :: IO (Either String [T.TxEntry])
getRawMemPoolJ = do
 d <- (eitherDecode <$> getJSON) :: IO (Either String [T.TxEntry_])
 case d of
  Left err -> return (Left err)
  Right ps -> return (Right $ fmap T.makeTxEntry ps)
