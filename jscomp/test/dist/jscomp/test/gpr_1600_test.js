// Generated by Melange
'use strict';


const obj = {
  hi: (function (x) {
    console.log(x);
  })
};

const eventObj = {
  events: [],
  empty: (function () {
    
  }),
  push: (function (a) {
    let self = this;
    self.events[0] = a;
  }),
  needRebuild: (function () {
    let self = this;
    return self.events.length !== 0;
  }),
  currentEvents: (function () {
    let self = this;
    return self.events;
  })
};

function f(param) {
  return eventObj;
}

module.exports = {
  obj,
  eventObj,
  f,
}
/* obj Not a pure module */
