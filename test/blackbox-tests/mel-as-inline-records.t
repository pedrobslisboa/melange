Test `@mel.as` in inline records / record extensions

  $ . ./setup.sh
  $ cat > x.ml <<EOF
  > type user = { name : string [@mel.as "renamed"] }
  > let user = { name = "Corentin" }
  > type user2 = User of { name : string [@mel.as "renamed"] }
  > let user2 = User { name = "Corentin" }
  > exception UserException of { name : string [@mel.as "renamed"] }
  > let user3 () =
  >   try
  >     raise (UserException { name = "Corentin" })
  >   with | UserException { name } -> Js.log2 "name:" name
  > EOF
  $ melc -ppx melppx x.ml
  // Generated by Melange
  'use strict';
  
  const Caml_exceptions = require("melange.js/caml_exceptions.js");
  const Caml_js_exceptions = require("melange.js/caml_js_exceptions.js");
  
  const UserException = /* @__PURE__ */ Caml_exceptions.create("X.UserException");
  
  function user3(param) {
    try {
      throw new Caml_js_exceptions.MelangeError(UserException, {
          MEL_EXN_ID: UserException,
          renamed: "Corentin"
        });
    }
    catch (raw_exn){
      const exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
      if (exn.MEL_EXN_ID === UserException) {
        console.log("name:", exn.renamed);
        return;
      }
      throw exn;
    }
  }
  
  const user = {
    renamed: "Corentin"
  };
  
  const user2 = {
    TAG: /* User */ 0,
    renamed: "Corentin"
  };
  
  module.exports = {
    user,
    user2,
    UserException,
    user3,
  }
  /* No side effect */
