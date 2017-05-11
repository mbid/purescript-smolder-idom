module Text.Smolder.Renderer.IncrementalDom (render) where

import Prelude
import Control.Monad.Eff (Eff)
import DOM (DOM)
import DOM.Event.Event (Event)
import DOM.Event.EventTarget (addEventListener, dispatchEvent, eventListener)
import DOM.Event.Types (EventType(..))
import DOM.HTML.Types (HTMLElement, htmlElementToEventTarget)
import Data.Foreign (Foreign, toForeign)
import Data.StrMap (StrMap, delete, lookup, toUnfoldable)
import Data.Traversable (traverse, traverse_)
import Data.Tuple (Tuple)
import Text.Smolder.Markup (EventHandler(..), Markup)
import Text.Smolder.Renderer.Util (Node(..), renderMarkup)
import Unsafe.Coerce (unsafeCoerce)
import Web.IncrementalDOM (IDOM, elementClose, elementOpen, text)

foreign import createEvent :: String -> Foreign -> Event

renderAttributes :: StrMap String -> Array (Tuple String Foreign)
renderAttributes = map toForeign >>> toUnfoldable

attachHandler ::
  forall e.
  HTMLElement ->
  EventHandler (Event -> Eff e Unit) ->
  Eff (dom :: DOM | e ) Unit
attachHandler el (EventHandler eventName callback) =
  addEventListener
  (EventType eventName)
  (eventListener $ unsafeCoerce callback)
  false
  (htmlElementToEventTarget el)

renderNode :: forall e. Node (Event -> Eff e Unit) -> Eff (idom :: IDOM | e) Unit
renderNode (Text t) = text t *> pure unit
renderNode (Element name props handlers children) = do
  let
    key = lookup "key" props
    props' = delete "key" $ props
  el <-
    elementOpen name key []
    (renderAttributes props')
  traverse_ (unsafeCoerce <<< attachHandler el) handlers
  traverse_ renderNode children
  _ <- elementClose name
  _ <-
    unsafeCoerce $ 
    dispatchEvent
    (createEvent "render" $ toForeign {})
    (htmlElementToEventTarget el)
  pure unit

render :: forall e. Markup (Event -> Eff e Unit) -> Eff (idom :: IDOM | e) Unit
render markup = do
  _ <- traverse renderNode $ renderMarkup markup
  pure unit
