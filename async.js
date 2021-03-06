// Generated by CoffeeScript 1.10.0

/* Author James "The Jamesernator" Browning
    2016
 */

(function() {
  "use strict";
  var GeneratorFunction, async,
    slice = [].slice;

  GeneratorFunction = Object.getPrototypeOf(function*() {
    return;
  }).constructor;

  async = function(genFunc) {

    /* async converts a GeneratorFunction into a ES7 async function */
    var spawn;
    if (!(genFunc instanceof GeneratorFunction)) {
      throw new Error("Passed non-generator to async");
    }
    return spawn = function() {
      var args;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      return new Promise((function(_this) {
        return function(resolve, reject) {
          var gen, step;
          gen = genFunc.apply(_this, args);
          step = function(nextFunc) {
            var err, error, next;
            try {
              next = nextFunc();
            } catch (error) {
              err = error;
              reject(err);
              return;
            }
            if (next.done) {
              resolve(next.value);
              return;
            }
            return Promise.resolve(next.value).then(function(val) {
              return step(function() {
                return gen.next(val);
              });
            }, function(err) {
              return step(function() {
                return gen["throw"](err);
              });
            });
          };
          return step(function() {
            return gen.next(void 0);
          });
        };
      })(this));
    };
  };

  async.run = function(func, errCallback) {
    if (errCallback == null) {
      errCallback = console.log;
    }

    /* This tries running the async function given and if it
        fails it calls the errCallback with the error given
        by the async function
     */
    return async(function*() {
      var err, error;
      try {
        return (yield async(func)());
      } catch (error) {
        err = error;
        return errCallback(err);
      }
    })();
  };

  async.main = function(func) {

    /* Although async.run has errCallback as console.log we'll just print
        the stack
     */
    return async.run(func, function(err) {
      return console.log(err.stack);
    });
  };

  async.from = function(iterable) {

    /* Creates a async function from an existing iterable */
    var genFunc;
    genFunc = function*() {
      return (yield* iterable);
    };
    return async(genFunc);
  };

  async["do"] = async.run;

  Object.defineProperty(async, "name", {
    value: "async"
  });

  if (typeof module !== "undefined" && module !== null) {
    module.exports = async;
  } else {
    window.async = async;
  }

}).call(this);
