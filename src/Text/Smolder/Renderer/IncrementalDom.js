"use strict";

try {
  var IDOM = require("incremental-dom");
} catch (ex) {
  var IDOM = IncrementalDOM;
}

exports.embedRenderedElement = function (el) {
  return function () {
    if (IDOM.currentPointer() != el) {
      IDOM.currentElement().insertBefore(el, IDOM.currentPointer());
    }
    console.assert(IDOM.currentPointer() === el);
    IDOM.skipNode();
  };
};
