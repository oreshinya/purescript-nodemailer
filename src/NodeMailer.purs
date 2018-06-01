module NodeMailer
  ( AuthConfig
  , TransportConfig
  , Message
  , Transporter
  , createTransporter
  , sendMail
  ) where

import Prelude

import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
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



sendMail :: Message -> Transporter -> Aff Unit
sendMail message transporter = fromEffectFnAff $ runFn2 _sendMail message transporter



foreign import createTransporter :: TransportConfig -> Effect Transporter



foreign import _sendMail :: Fn2 Message Transporter (EffectFnAff Unit)
