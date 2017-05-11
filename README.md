# purescript-smolder-idom

Smolder renderer for [Incremental DOM](https://github.com/google/incremental-dom).

## Extensions

The renderer supports the following extensions to plain smolder/HTML:

* The value of the "key" attribute is used as key in the reconcilement algorithm of incremental dom.
* A "render" event will be dispatched on an element each time it is (re)rendered.
