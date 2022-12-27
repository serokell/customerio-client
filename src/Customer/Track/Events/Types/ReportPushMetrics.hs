-- SPDX-FileCopyrightText: 2022 Serokell <https://serokell.io/>
--
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}

module Customer.Track.Events.Types.ReportPushMetrics
  ( ReportPushMetricsBody(..)
  , EventType(..)
  ) where

import Customer.Aeson (defaultAesonOptions)
import Data.Aeson (ToJSON(toJSON))
import Data.Aeson.TH (deriveToJSON)
import Data.Text (Text)


data EventType = Opened | Converted | Delivered

instance ToJSON EventType where
  toJSON = \case
    Opened -> "opened"
    Converted -> "converted"
    Delivered -> "delivered"

data ReportPushMetricsBody = MkReportPushMetrics
  { rpmDeliveryId :: Text
  , rpmEvent      :: EventType
  , rpmDeviceId   :: Text
  , rpmTimestamp  :: Int
  }

deriveToJSON defaultAesonOptions ''ReportPushMetricsBody
