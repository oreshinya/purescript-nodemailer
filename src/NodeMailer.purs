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
import Foreign (Foreign)
import Foreign.Generic (defaultOptions)
import Foreign.Generic.Class (class EncodeRecord, encodeRecord_)
import Foreign.Object (Object)
import Prim.RowList as RL
import Type.Data.RowList (RLProxy(..))

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
sendMail m transporter = 
  let message = m { attachments = map convertAttachment m.attachments } in
  fromEffectFnAff $ runFn2 _sendMail message transporter

foreign import createTransporter :: TransportConfig -> Effect Transporter

convert :: 
  forall r rl
  .  RL.RowToList r rl
  => EncodeRecord r rl
  => { | r }
  -> Object Foreign
convert = encodeRecord_ (RLProxy :: RLProxy rl) defaultOptions

convertAttachment :: Attachment -> Object Foreign
convertAttachment = case _ of
  AttachContent r -> convert r
  AttachPath r -> convert r

type UnsafeMessage =
  { from :: String
  , to :: Array String
  , cc :: Array String
  , bcc :: Array String
  , subject :: String
  , text :: String
  , attachments :: Array (Object Foreign)
  }

foreign import _sendMail :: Fn2 UnsafeMessage Transporter (EffectFnAff Unit)
