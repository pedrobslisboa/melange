// Generated by Melange
'use strict';

const Caml_array = require("melange.js/caml_array.js");
const Caml_js_exceptions = require("melange.js/caml_js_exceptions.js");
const Stdlib = require("melange/stdlib.js");

const x = [
  1,
  2
];

let y;

try {
  y = Caml_array.get(x, 3);
}
catch (raw_msg){
  const msg = Caml_js_exceptions.internalToOCamlException(raw_msg);
  if (msg.MEL_EXN_ID === Stdlib.Invalid_argument) {
    console.log(msg._1);
    y = 0;
  } else {
    throw msg;
  }
}

module.exports = {
  x,
  y,
}
/* y Not a pure module */
