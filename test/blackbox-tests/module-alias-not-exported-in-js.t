Test empty modules when including aliases (related to Dune wrapped libraries)

  $ . ./setup.sh
  $ mkdir -p app
  $ mkdir -p app/.objs/melange
  $ mkdir -p output/app

  $ echo "let t = 1" > app/b.ml

  $ cat >  app/app.ml << EOF
  > module B_alias = B
  > module App = struct end
  > EOF

Build artifacts

  $ melc -bs-package-output app/ -bs-stop-after-cmj -nopervasives app/b.ml -o app/.objs/melange/b.cmj

  $ melc -bs-package-output app/ -I app/.objs/melange app/app.ml -nopervasives -bs-stop-after-cmj -o app/.objs/melange/app.cmj

  $ melc -bs-module-type commonjs -nopervasives app/.objs/melange/b.cmj -o output/app/b.js

  $ melc -bs-module-type commonjs -nopervasives app/.objs/melange/app.cmj -o output/app/app.js

Output does not contain B_alias

  $ cat output/app/app.js
  // Generated by Melange
  'use strict';
  
  
  const App = {};
  
  module.exports = {
    App,
  }
  /* No side effect */

Make another lib that uses `App`

  $ mkdir -p uses_app
  $ mkdir -p uses_app/.objs/melange
  $ mkdir -p output/uses_app

  $ echo "let () = Js.log App.B_alias.t" > uses_app/uses_app.ml

Build the `uses_app` library

  $ melc -bs-package-output uses_app/ -bs-stop-after-cmj -I app/.objs/melange uses_app/uses_app.ml -o uses_app/.objs/melange/uses_app.cmj

  $ melc -bs-module-type commonjs uses_app/.objs/melange/uses_app.cmj -I app/.objs/melange -o output/uses_app/uses_app.js

Output does not contain B_alias

  $ cat output/uses_app/uses_app.js
  // Generated by Melange
  'use strict';
  
  const B = require("../app/b.js");
  
  console.log(B.t);
  /*  Not a pure module */

