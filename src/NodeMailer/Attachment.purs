module NodeMailer.Attachment where

import NodeMailer.AttachmentStream (AttachmentStream)
import Simple.JSON (class WriteForeign, writeImpl)

data Attachment
  = FileFromPath { filename :: String, path :: String }
  | FileFromString { filename :: String, content :: String }
  | FileFromStream { filename :: String, content :: AttachmentStream }

instance writeForeignAttachment :: WriteForeign Attachment where
  writeImpl (FileFromPath r) = writeImpl r
  writeImpl (FileFromString r) = writeImpl r
  writeImpl (FileFromStream r) = writeImpl r
