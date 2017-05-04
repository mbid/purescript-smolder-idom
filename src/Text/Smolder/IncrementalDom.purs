module Text.Smolder.IncrementalDom where

import Text.Smolder.Markup (Attribute, attribute)

key :: String -> Attribute
key = attribute "key"
