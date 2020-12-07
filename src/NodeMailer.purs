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
import Foreign (Foreign, unsafeToForeign)
import NodeMailer.Attachment (Attachment)

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

sendMail_ :: Transporter -> Message -> Aff Unit
sendMail_ transporter message = void $ sendMail transporter message

sendMail :: Transporter -> Message -> Aff MessageInfo
sendMail transporter message = fromEffectFnAff $ runFn2 _sendMail transporter (unsafeToForeign message)

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

foreign import _sendMail :: Fn2 Transporter Foreign (EffectFnAff MessageInfo)

foreign import _createTestAccount :: EffectFnAff TestAccount

foreign import _getTestMessageUrl
  :: Fn3 (Maybe String) (String -> Maybe String) MessageInfo (Maybe String)

