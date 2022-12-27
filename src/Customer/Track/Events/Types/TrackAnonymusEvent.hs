-- SPDX-FileCopyrightText: 2022 Serokell <https://serokell.io/>
--
-- SPDX-License-Identifier: Apache-2.0

module Customer.Track.Events.Types.TrackAnonymusEvent
  ( module Customer.Track.Events.Types.TrackAnonymusEvent
  ) where

import Customer.Aeson (defaultAesonOptions, mkObject, mkPair)
import Data.Aeson
import Data.Aeson.TH (deriveToJSON)
import Data.Text (Text)

data TrackAnonymusEventBody
  = StandardAnonymusEventBody StandardAnonymusEvent
  | InviteAnonymusEventBody InviteAnonymusEvent

data StandardAnonymusEvent = MkStandardAnonymusEvent
  { saeName        :: Text
  , saeAnonymousId :: Text
  , saeId          :: Maybe Text
  , saeTimestamp   :: Maybe Int
  , saeData        :: Maybe StandardAnonymusData
  }

data InviteAnonymusEvent = MkInviteAnonymusEvent
  { iaeName      :: Text
  , iaeData      :: InviteAnonymusData
  , iaeTimestamp :: Maybe Int
  }

data StandardAnonymusData = MkStandardAnonymusData
  { sadFromAddress      :: Maybe Text
  , sadReplyTo          :: Maybe Text
  , sadAdditionalFields :: Maybe Object
  }

instance ToJSON StandardAnonymusData where
  toJSON MkStandardAnonymusData{..} = case sadAdditionalFields of
    Just km -> Object (mainFields <> km)
    Nothing -> Object mainFields
    where
      mainFields = mkObject
        [ mkPair "from_address" <$> sadFromAddress
        , mkPair "reply_to" <$> sadReplyTo
        ]

data InviteAnonymusData = MkInviteAnonymusData
  { iadRecipient        :: Text
  , iadFromAddress      :: Maybe Text
  , iadReplyTo          :: Maybe Text
  , iadAdditionalFields :: Maybe Object
  }

instance ToJSON InviteAnonymusData where
  toJSON MkInviteAnonymusData{..} = case iadAdditionalFields of
    Just km -> Object (mainFields <> km)
    Nothing -> Object mainFields
    where
      mainFields = mkObject
        [ Just (mkPair "recipient" iadRecipient)
        , mkPair "from_address" <$> iadFromAddress
        , mkPair "reply_to" <$> iadReplyTo
        ]

defaultStandardAnonymusEvent
  :: Text -- ^ name
  -> Text -- ^ anonymous_id
  -> StandardAnonymusEvent
defaultStandardAnonymusEvent name anonymousId =
  MkStandardAnonymusEvent name anonymousId  Nothing Nothing Nothing

defaultInviteAnonymusEvent
  :: Text -- ^ name
  -> Text -- ^ recipient (from `data` field)
  -> InviteAnonymusEvent
defaultInviteAnonymusEvent name recipient =
  MkInviteAnonymusEvent name (MkInviteAnonymusData recipient Nothing Nothing Nothing) Nothing

deriveToJSON defaultAesonOptions ''StandardAnonymusEvent
deriveToJSON defaultAesonOptions ''InviteAnonymusEvent
deriveToJSON (defaultAesonOptions {sumEncoding = UntaggedValue}) ''TrackAnonymusEventBody
