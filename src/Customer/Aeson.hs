-- SPDX-FileCopyrightText: 2022 Serokell <https://serokell.io/>
--
-- SPDX-License-Identifier: Apache-2.0

module Customer.Aeson (defaultAesonOptions, mkPair, mkObject) where

import Data.Aeson.Casing ( aesonPrefix, snakeCase )
import Data.Aeson.Types
import Data.Maybe (catMaybes)
import GHC.Exts (fromList)

defaultAesonOptions :: Options
defaultAesonOptions = aesonPrefix snakeCase

mkPair :: ToJSON v => Key -> v -> (Key, Value)
mkPair = (.=)

mkObject :: [Maybe (Key, Value)] -> Object
mkObject = fromList . catMaybes
