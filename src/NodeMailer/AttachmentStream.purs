module NodeMailer.AttachmentStream where

import Foreign (unsafeToForeign)
import Node.Stream (Readable)
import Simple.JSON (class WriteForeign)
import Unsafe.Coerce (unsafeCoerce)

foreign import data AttachmentStream :: Type

fromReadable :: forall r. Readable r -> AttachmentStream
fromReadable = unsafeCoerce

instance writeForeignReadFileStream :: WriteForeign AttachmentStream where
  writeImpl = unsafeToForeign
