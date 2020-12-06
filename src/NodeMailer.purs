module NodeMailer
  ( AuthConfig
  , TransportConfig
  , Message
  , Transporter
  , MessageInfo
  , createTransporter
  , createTestAccount
  , getTestMessageUrl
  , sendMail
  , sendMail_
  ) where

import Prelude

import Data.Function.Uncurried (Fn2, Fn3, runFn2, runFn3)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Foreign (Foreign)
import NodeMailer.Attachment (Attachment)
import Simple.JSON (write)

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

sendMail_ :: Message -> Transporter -> Aff Unit
sendMail_ message transporter = void $ sendMail message transporter

sendMail :: Message -> Transporter -> Aff MessageInfo
sendMail message transporter = fromEffectFnAff $ runFn2 _sendMail (write message) transporter

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

foreign import createTransporter :: TransportConfig -> Effect Transporter

foreign import _sendMail :: Fn2 Foreign Transporter (EffectFnAff MessageInfo)

foreign import _createTestAccount :: EffectFnAff TestAccount

foreign import _getTestMessageUrl
  :: Fn3 (Maybe String) (String -> Maybe String) MessageInfo (Maybe String)
