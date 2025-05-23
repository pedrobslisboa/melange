// Generated by Melange
'use strict';

const Caml_js_exceptions = require("melange.js/caml_js_exceptions.js");
const Curry = require("melange.js/curry.js");
const Stdlib = require("melange/stdlib.js");

function f(g, x) {
  try {
    return Curry._1(g, x);
  }
  catch (raw_exn){
    const exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
    if (exn.MEL_EXN_ID === Stdlib.Not_found) {
      return 3;
    }
    throw exn;
  }
}

module.exports = {
  f,
}
/* No side effect */
