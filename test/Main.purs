module Test.Main where


import Prelude

import Control.Monad.Aff (launchAff)
import Control.Monad.Eff (Eff)
import Data.Maybe (fromMaybe)
import Node.Process (PROCESS, lookupEnv)
import NodeMailer (NODEMAILER, TransportConfig, Message, createTransporter, sendMail)


main :: forall e. Eff (nodemailer :: NODEMAILER, process :: PROCESS | e) Unit
main = do
  t <- config >>= createTransporter
  msg <- message
  void $ launchAff $ sendMail msg t



config :: forall e. Eff (process :: PROCESS | e) TransportConfig
config = do
  host <- getHost
  user <- getUser
  pass <- getPass
  pure { host, port: 465, secure: true, auth: { user, pass } }
  where
    getHost = fromMaybe "" <$> lookupEnv "SMTP_HOST"
    getUser = fromMaybe "" <$> lookupEnv "SMTP_USER"
    getPass = fromMaybe "" <$> lookupEnv "SMTP_PASS"



message :: forall e. Eff (process :: PROCESS | e) Message
message = do
  to <- getTo
  pure { from: "noreply@example.com"
  , to: [ to ]
  , subject: "Test Subject"
  , text: "Go to https://github.com"
  }
  where
    getTo = fromMaybe "" <$> lookupEnv "TEST_TO"
