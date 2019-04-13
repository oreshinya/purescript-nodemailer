module NodeMailer
  ( AuthConfig
  , TransportConfig
  , Attachment(..)
  , Message
  , Transporter
  , MessageInfo
  , ReadFileStream
  , createTransporter
  , createTestAccount
  , getTestMessageUrl
  , sendMail
  , sendMail_
  , fromReadable
  ) where

import Prelude

import Data.Function.Uncurried (Fn2, Fn3, runFn2, runFn3)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Foreign (Foreign, unsafeToForeign)
import Node.Stream (Readable)
import Simple.JSON (class WriteForeign, write, writeImpl)
import Unsafe.Coerce (unsafeCoerce)

type AuthConfig =
  { user :: String
  , pass :: String
  }

type TransportConfig =
  { host :: String
  , port :: Int
  , secure :: Boolean
  , auth :: AuthConfig
  }

type TestAccount =
  { user :: String
  , pass :: String
  , smtp :: { host :: String, port :: Int, secure :: Boolean }
  }

data Attachment
  = FileFromPath { filename :: String, path :: String }
  | FileFromString { filename :: String, content :: String }
  | FileFromStream { filename :: String, content :: ReadFileStream }

type Message =
  { from :: String
  , to :: Array String
  , cc :: Array String
  , bcc :: Array String
  , subject :: String
  , text :: String
  , attachments :: Array Attachment
  }

foreign import data Transporter :: Type

foreign import data MessageInfo :: Type

foreign import data ReadFileStream :: Type

sendMail :: Message -> Transporter -> Aff Unit
sendMail message transporter = void $ sendMail_ message transporter

sendMail_ :: Message -> Transporter -> Aff MessageInfo
sendMail_ message transporter = fromEffectFnAff $ runFn2 _sendMail (write message) transporter

createTestAccount :: Aff TransportConfig
createTestAccount = do
  account <- fromEffectFnAff _createTestAccount
  pure
    { host: account.smtp.host
    , port: account.smtp.port
    , secure: account.smtp.secure
    , auth: { user: account.user, pass: account.pass }
    }

getTestMessageUrl :: MessageInfo -> Maybe String
getTestMessageUrl = runFn3 _getTestMessageUrl Nothing Just

fromReadable :: forall r. Readable r -> ReadFileStream
fromReadable = unsafeCoerce

foreign import createTransporter :: TransportConfig -> Effect Transporter

foreign import _sendMail :: Fn2 Foreign Transporter (EffectFnAff MessageInfo)

foreign import _createTestAccount :: EffectFnAff TestAccount

foreign import _getTestMessageUrl
  :: Fn3 (Maybe String) (String -> Maybe String) MessageInfo (Maybe String)

instance writeForeignAttachment :: WriteForeign Attachment where
  writeImpl (FileFromPath r) = writeImpl r
  writeImpl (FileFromString r) = writeImpl r
  writeImpl (FileFromStream r) = writeImpl r

instance writeForeignReadFileStream :: WriteForeign ReadFileStream where
  writeImpl = unsafeToForeign
