module NodeMailer
  ( AuthConfig
  , TransportConfig
  , Message
  , Attachment(..)
  , Transporter
  , createTransporter
  , sendMail
  ) where

import Prelude

import Data.Function.Uncurried (Fn2, runFn2)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)



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
  , cc :: Array String
  , bcc :: Array String
  , subject :: String
  , text :: String
  , attachments :: Array Attachment
  }

-- This supports only a small subset of NodeMailer attachment properties
data Attachment 
  = AttachContent { filename :: String, content :: String }
  | AttachPath { path :: String }

foreign import data Transporter :: Type



sendMail :: Message -> Transporter -> Aff Unit
sendMail message transporter = fromEffectFnAff $ runFn2 _sendMail message transporter



foreign import createTransporter :: TransportConfig -> Effect Transporter



foreign import _sendMail :: Fn2 Message Transporter (EffectFnAff Unit)
