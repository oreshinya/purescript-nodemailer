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
import Data.Nullable (Nullable, toNullable)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Effect.Uncurried (EffectFn1, runEffectFn1)
import Foreign (Foreign)
import NodeMailer.Attachment (Attachment)
import NodeMailer.DKIM as DKIM
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
  , dkim :: Nullable DKIM.Options
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

createTransporter :: TransportConfig -> Effect Transporter
createTransporter config = runEffectFn1 createTransporterImpl config

sendMail :: Message -> Transporter -> Aff Unit
sendMail message transporter = void $ sendMail_ message transporter

sendMail_ :: Message -> Transporter -> Aff MessageInfo
sendMail_ message transporter = fromEffectFnAff $ runFn2 sendMailImpl (write message) transporter

createTestAccount :: Aff TransportConfig
createTestAccount = do
  account <- fromEffectFnAff createTestAccountImpl
  pure
    { host: account.smtp.host
    , port: account.smtp.port
    , secure: account.smtp.secure
    , auth: { user: account.user, pass: account.pass }
    , dkim: toNullable Nothing
    }

getTestMessageUrl :: MessageInfo -> Maybe String
getTestMessageUrl = runFn3 getTestMessageUrlImpl Nothing Just

foreign import createTransporterImpl :: EffectFn1 TransportConfig Transporter

foreign import sendMailImpl :: Fn2 Foreign Transporter (EffectFnAff MessageInfo)

foreign import createTestAccountImpl :: EffectFnAff TestAccount

foreign import getTestMessageUrlImpl
  :: Fn3 (Maybe String) (String -> Maybe String) MessageInfo (Maybe String)
