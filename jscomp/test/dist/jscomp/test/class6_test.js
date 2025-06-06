// Generated by Melange
'use strict';

const Caml_js_exceptions = require("melange.js/caml_js_exceptions.js");
const Caml_obj = require("melange.js/caml_obj.js");
const Caml_oo = require("melange.js/caml_oo.js");
const Caml_oo_curry = require("melange.js/caml_oo_curry.js");
const CamlinternalOO = require("melange/camlinternalOO.js");
const Curry = require("melange.js/curry.js");
const Mt = require("./mt.js");
const Stdlib = require("melange/stdlib.js");

const shared = [
  "move",
  "get_x"
];

const shared$1 = ["m"];

const shared$2 = ["x"];

const suites = {
  contents: /* [] */ 0
};

const test_id = {
  contents: 0
};

function eq(loc, x, y) {
  test_id.contents = test_id.contents + 1 | 0;
  suites.contents = {
    hd: [
      loc + (" id " + String(test_id.contents)),
      (function (param) {
        return {
          TAG: /* Eq */ 0,
          _0: x,
          _1: y
        };
      })
    ],
    tl: suites.contents
  };
}

function point_init($$class) {
  const ids = CamlinternalOO.new_methods_variables($$class, shared, shared$2);
  const move = ids[0];
  const get_x = ids[1];
  const x = ids[2];
  CamlinternalOO.set_methods($$class, [
    get_x,
    (function (self$1) {
      return self$1[x];
    }),
    move,
    (function (self$1, d) {
      self$1[x] = self$1[x] + d | 0;
    })
  ]);
  return function (env, self, x_init) {
    const self$1 = CamlinternalOO.create_object_opt(self, $$class);
    self$1[x] = x_init;
    return self$1;
  };
}

const point = CamlinternalOO.make_class(shared, point_init);

function colored_point_init($$class) {
  const ids = CamlinternalOO.new_methods_variables($$class, [
    "move",
    "get_x",
    "color"
  ], ["c"]);
  const color = ids[2];
  const c = ids[3];
  const inh = CamlinternalOO.inherits($$class, shared$2, 0, [
    "get_x",
    "move"
  ], point, true);
  const obj_init = inh[0];
  CamlinternalOO.set_method($$class, color, (function (self$2) {
    return self$2[c];
  }));
  return function (env, self, x, c$1) {
    const self$1 = CamlinternalOO.create_object_opt(self, $$class);
    Curry._2(obj_init, self$1, x);
    self$1[c] = c$1;
    return CamlinternalOO.run_initializers_opt(self, self$1, $$class);
  };
}

const colored_point = CamlinternalOO.make_class([
  "move",
  "color",
  "get_x"
], colored_point_init);

function colored_point_to_point(cp) {
  return cp;
}

const p = Curry._2(point[0], undefined, 3);

const q = Curry._3(colored_point[0], undefined, 4, "blue");

function lookup_obj(obj, _param) {
  while (true) {
    const param = _param;
    if (param) {
      const obj$p = param.hd;
      if (Caml_obj.caml_equal(obj, obj$p)) {
        return obj$p;
      }
      _param = param.tl;
      continue;
    }
    throw new Caml_js_exceptions.MelangeError(Stdlib.Not_found, {
        MEL_EXN_ID: Stdlib.Not_found
      });
  };
}

function c_init($$class) {
  const m = CamlinternalOO.get_method_label($$class, "m");
  CamlinternalOO.set_method($$class, m, (function (self$3) {
    return 1;
  }));
  return function (env, self) {
    return CamlinternalOO.create_object_opt(self, $$class);
  };
}

const c = CamlinternalOO.make_class(shared$1, c_init);

function d_init($$class) {
  const ids = CamlinternalOO.get_method_labels($$class, [
    "n",
    "m",
    "as_c"
  ]);
  const n = ids[0];
  const as_c = ids[2];
  const inh = CamlinternalOO.inherits($$class, 0, 0, shared$1, c, true);
  const obj_init = inh[0];
  CamlinternalOO.set_methods($$class, [
    n,
    (function (self$4) {
      return 2;
    }),
    as_c,
    (function (self$4) {
      return self$4;
    })
  ]);
  return function (env, self) {
    const self$1 = CamlinternalOO.create_object_opt(self, $$class);
    Curry._1(obj_init, self$1);
    return CamlinternalOO.run_initializers_opt(self, self$1, $$class);
  };
}

const table = CamlinternalOO.create_table([
  "as_c",
  "m",
  "n"
]);

const env_init = d_init(table);

CamlinternalOO.init_class(table);

const d_0 = Curry._1(env_init, undefined);

const d = [
  d_0,
  d_init,
  undefined
];

function c2$p_1($$class) {
  CamlinternalOO.get_method_label($$class, "m");
  return function (env, self) {
    return CamlinternalOO.create_object_opt(self, $$class);
  };
}

const c2$p = [
  undefined,
  c2$p_1,
  undefined
];

function functional_point_init($$class) {
  const ids = CamlinternalOO.new_methods_variables($$class, shared, shared$2);
  const move = ids[0];
  const get_x = ids[1];
  const x = ids[2];
  CamlinternalOO.set_methods($$class, [
    get_x,
    (function (self$6) {
      return self$6[x];
    }),
    move,
    (function (self$6, d) {
      const copy = Caml_oo.caml_set_oo_id(Caml_obj.caml_obj_dup(self$6));
      copy[x] = self$6[x] + d | 0;
      return copy;
    })
  ]);
  return function (env, self, y) {
    const self$1 = CamlinternalOO.create_object_opt(self, $$class);
    self$1[x] = y;
    return self$1;
  };
}

const functional_point = CamlinternalOO.make_class(shared, functional_point_init);

const p$1 = Curry._2(functional_point[0], undefined, 7);

const tmp = Caml_oo_curry.js2(-933174511, 2, p$1, 3);

eq("File \"jscomp/test/class6_test.ml\", line 60, characters 5-12", [
  7,
  10,
  7
], [
  Caml_oo_curry.js1(291546447, 1, p$1),
  Caml_oo_curry.js1(291546447, 3, tmp),
  Caml_oo_curry.js1(291546447, 4, p$1)
]);

function bad_functional_point_init($$class) {
  const ids = CamlinternalOO.new_methods_variables($$class, shared, shared$2);
  const move = ids[0];
  const get_x = ids[1];
  const x = ids[2];
  CamlinternalOO.set_methods($$class, [
    get_x,
    (function (self$7) {
      return self$7[x];
    }),
    move,
    (function (self$7, d) {
      return Curry._2(bad_functional_point[0], undefined, self$7[x] + d | 0);
    })
  ]);
  return function (env, self, y) {
    const self$1 = CamlinternalOO.create_object_opt(self, $$class);
    self$1[x] = y;
    return self$1;
  };
}

const table$1 = CamlinternalOO.create_table(shared);

const env_init$1 = bad_functional_point_init(table$1);

CamlinternalOO.init_class(table$1);

const bad_functional_point_0 = Curry._1(env_init$1, undefined);

const bad_functional_point = [
  bad_functional_point_0,
  bad_functional_point_init,
  undefined
];

const p$2 = Curry._2(bad_functional_point_0, undefined, 7);

const tmp$1 = Caml_oo_curry.js2(-933174511, 6, p$2, 3);

eq("File \"jscomp/test/class6_test.ml\", line 74, characters 5-12", [
  7,
  10,
  7
], [
  Caml_oo_curry.js1(291546447, 5, p$2),
  Caml_oo_curry.js1(291546447, 7, tmp$1),
  Caml_oo_curry.js1(291546447, 8, p$2)
]);

Mt.from_pair_suites("Class6_test", suites.contents);

module.exports = {
  suites,
  test_id,
  eq,
  point,
  colored_point,
  colored_point_to_point,
  p,
  q,
  lookup_obj,
  c,
  d,
  c2$p,
  functional_point,
  bad_functional_point,
}
/* point Not a pure module */
