module Test.Main where


import Prelude

import Effect (Effect)
import Effect.Aff (launchAff)
import Data.Maybe (fromMaybe)
import Node.Process (lookupEnv)
import NodeMailer (TransportConfig, Message, createTransporter, sendMail)


main :: Effect Unit
main = do
  t <- config >>= createTransporter
  msg <- message
  void $ launchAff $ sendMail msg t



config :: Effect TransportConfig
config = do
  host <- getHost
  user <- getUser
  pass <- getPass
  pure { host, port: 465, secure: true, auth: { user, pass } }
  where
    getHost = fromMaybe "" <$> lookupEnv "SMTP_HOST"
    getUser = fromMaybe "" <$> lookupEnv "SMTP_USER"
    getPass = fromMaybe "" <$> lookupEnv "SMTP_PASS"



message :: Effect Message
message = do
  to <- getTo
  pure { from: "noreply@example.com"
  , to: [ to ]
  , cc: [ ]
  , bcc: [ ]
  , subject: "Test Subject"
  , text: "Go to https://github.com"
  , attachments: [ ]
  }
  where
    getTo = fromMaybe "" <$> lookupEnv "TEST_TO"
