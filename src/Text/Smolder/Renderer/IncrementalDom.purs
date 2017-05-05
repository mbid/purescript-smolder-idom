module Text.Smolder.Renderer.IncrementalDom (render) where

import Prelude
import Control.Monad.Eff (Eff)
import DOM.Event.Event (Event)
import DOM.Event.EventTarget (eventListener)
import Data.Array (singleton)
import Data.CatList (CatList)
import Data.Foldable (foldMap)
import Data.Foreign (Foreign, toForeign)
import Data.StrMap (StrMap, delete, lookup, toUnfoldable)
import Data.Traversable (traverse)
import Data.Tuple (Tuple(..))
import Text.Smolder.Markup (EventHandler(..), Markup)
import Text.Smolder.Renderer.Util (Node(..), renderMarkup)
import Web.IncrementalDOM (IDOM, elementClose, elementOpen, text)

renderAttributes :: StrMap String -> Array (Tuple String Foreign)
renderAttributes = map toForeign >>> toUnfoldable

renderListener :: forall e. EventHandler (Event -> Eff e Unit) -> Tuple String Foreign
renderListener (EventHandler eventName callback) =
  Tuple ("on" <> eventName) (toForeign $ eventListener callback)

renderListeners ::
  forall e.
  CatList (EventHandler (Event -> Eff e Unit)) ->
  Array (Tuple String Foreign)
renderListeners = foldMap (renderListener >>> singleton)

renderNode :: forall e. Node (Event -> Eff e Unit) -> Eff (idom :: IDOM | e) Unit
renderNode (Text t) = text t *> pure unit
renderNode (Element name props listeners children) = do
  let
    key = lookup "key" props
    props' = delete "key" props

  _ <-
    elementOpen name key []
    (renderAttributes props' <> renderListeners listeners)
  _ <- traverse renderNode children
  _ <- elementClose name
  pure unit

render :: forall e. Markup (Event -> Eff e Unit) -> Eff (idom :: IDOM | e) Unit
render markup = do
  _ <- traverse renderNode $ renderMarkup markup
  pure unit
