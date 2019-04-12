module NodeMailer
  ( AuthConfig
  , TransportConfig
  , Message
  , MessageBase
  , Attachment(..)
  , Transporter
  , createTransporter
  , sendMail
  ) where

import Prelude

import Data.Function.Uncurried (Fn2, runFn2)
import Data.Nullable (Nullable, notNull, null)
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

type MessageBase a =
  { from :: String
  , to :: Array String
  , cc :: Array String
  , bcc :: Array String
  , subject :: String
  , text :: String
  , attachments :: Array a
  }

type Message = MessageBase Attachment

-- This supports only a small subset of NodeMailer attachment properties
data Attachment 
  = AttachContent { filename :: String, content :: String }
  | AttachPath { path :: String }

foreign import data Transporter :: Type

sendMail :: Message -> Transporter -> Aff Unit
sendMail message transporter = 
  let msg = message { attachments = map convert message.attachments } in
  fromEffectFnAff $ runFn2 _sendMail msg transporter

foreign import createTransporter :: TransportConfig -> Effect Transporter

convert :: Attachment -> UnsafeAttachment
convert = case _ of
  AttachContent { filename, content } ->
    { filename: notNull filename
    , content: notNull content
    , path: null
    }
  AttachPath { path } ->
    { filename: null
    , content: null
    , path: notNull path
    }

type UnsafeAttachment = 
  { filename :: Nullable String
  , content :: Nullable String
  , path :: Nullable String
  }

type UnsafeMessage = MessageBase UnsafeAttachment

foreign import _sendMail :: Fn2 UnsafeMessage Transporter (EffectFnAff Unit)
