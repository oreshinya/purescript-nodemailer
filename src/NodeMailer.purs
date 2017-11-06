module NodeMailer
  ( NODEMAILER
  , AuthConfig
  , TransportConfig
  , Message
  , Transporter
  , createTransporter
  , sendMail
  ) where

import Prelude

import Control.Monad.Aff (Aff)
import Control.Monad.Aff.Compat (EffFnAff, fromEffFnAff)
import Control.Monad.Eff (Eff, kind Effect)
import Data.Function.Uncurried (Fn2, runFn2)



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

type Message =
  { from :: String
  , to :: Array String
  , subject :: String
  , text :: String
  }

foreign import data Transporter :: Type

foreign import data NODEMAILER :: Effect



sendMail :: forall e. Message -> Transporter -> Aff (nodemailer :: NODEMAILER | e) Unit
sendMail message transporter = fromEffFnAff $ runFn2 _sendMail message transporter



foreign import createTransporter :: forall e. TransportConfig -> Eff (nodemailer :: NODEMAILER | e)  Transporter



foreign import _sendMail :: forall e. Fn2 Message Transporter (EffFnAff (nodemailer :: NODEMAILER | e) Unit)
