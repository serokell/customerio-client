-- SPDX-FileCopyrightText: 2022 Serokell <https://serokell.io/>
--
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE RecordWildCards #-}

module Customer
  ( module Customer
  , module Customer.Track.Events.Types.ReportPushMetrics
  , module Customer.Track.Events.Types.TrackAnonymusEvent
  , module Customer.Track.Events.Types.TrackCustomerEvent
  ) where

import Customer.Track.Events.API (api)
import Customer.Track.Events.Types.ReportPushMetrics
import Customer.Track.Events.Types.TrackAnonymusEvent
import Customer.Track.Events.Types.TrackCustomerEvent
import Data.Text (Text)
import qualified Network.HTTP.Client as HTTP
import Servant.API
import Servant.Client

-- | Default host of the track API: https://track.customer.io:443
host :: BaseUrl
host = BaseUrl Https "track.customer.io" 443 ""

data Env = MkEnv
  { authtoken :: BasicAuthData
  , clientEnv :: ClientEnv
  }

-- | Same as `mkEnvDef`, but you can change BaseUrl.
--   May be useful only if `host` is outdated.
mkEnv :: BaseUrl -> BasicAuthData -> HTTP.Manager -> Env
mkEnv host' authtoken httpManager = MkEnv {..}
  where
    clientEnv = mkClientEnv httpManager host'

-- | Default way to create client environment
mkEnvDef :: BasicAuthData -> HTTP.Manager -> Env
mkEnvDef = mkEnv host

trackCustomerEventC :: BasicAuthData -> Text -> TrackCustomerEventBody -> ClientM ()
trackAnonymusEventC :: BasicAuthData -> TrackAnonymusEventBody -> ClientM ()
reportPushMetricsC  :: ReportPushMetricsBody -> ClientM ()

trackCustomerEventC
  :<|> trackAnonymusEventC
  :<|> reportPushMetricsC
  = client api

trackCustomerEvent :: Env -> Text -> TrackCustomerEventBody -> IO (Either ClientError ())
trackCustomerEvent MkEnv{..} identifier body = do
  runClientM (trackCustomerEventC authtoken identifier body) clientEnv

trackAnonymusEvent :: Env -> TrackAnonymusEventBody -> IO (Either ClientError ())
trackAnonymusEvent MkEnv{..} body = do
  runClientM (trackAnonymusEventC authtoken body) clientEnv

reportPushMetrics :: Env -> ReportPushMetricsBody -> IO (Either ClientError ())
reportPushMetrics MkEnv{..} body = do
  runClientM (reportPushMetricsC body) clientEnv
