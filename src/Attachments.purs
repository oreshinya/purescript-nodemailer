module Attachments 
  ( Attachment
  -- , defaultAttachment
  , attachContent
  , attachPath
  ) where

import Data.Maybe (Maybe(..))
import Unsafe.Coerce (unsafeCoerce)

foreign import data Attachment :: Type

-- type Attachment = 
--   { filename :: Maybe String
--   , content :: Maybe String
--   , path :: Maybe String
--   , href :: Maybe String
--   , contentType :: Maybe String
--   , contentDisposition :: Maybe String
--   , cid :: Maybe String
--   , encoding :: Maybe String
--   , headers :: Maybe String
--   , raw :: Maybe String
--   }

-- defaultAttachment :: Attachment
-- defaultAttachment = 
--   { filename: Nothing
--   , content: Nothing
--   , path: Nothing
--   , href: Nothing
--   , contentType: Nothing
--   , contentDisposition: Nothing
--   , cid: Nothing
--   , encoding: Nothing
--   , headers: Nothing
--   , raw: Nothing
--   }

attachContent :: { content :: String, filename :: String } -> Attachment
attachContent r = unsafeToAttachment r
  -- defaultAttachment 
  -- { content = Just r.content, filename = Just r.filename }

attachPath :: String -> Attachment
attachPath path = unsafeToAttachment { path }

unsafeToAttachment :: ∀ a. a -> Attachment
unsafeToAttachment = unsafeCoerce

  -- defaultAttachment { path = Just path }
