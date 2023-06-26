module NodeMailer.DKIM where

type Options =
  { domainName :: String
  , keySelector :: String
  , privateKey :: String
  }

