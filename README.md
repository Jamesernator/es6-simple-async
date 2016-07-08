# Install

Using NPM:

`npm install es6-simple-async`

# Async

This is a basic wrapper around generators to create async functions:

```javascript
var async = require('es6-simple-async');

var timer = function(time) {
    return new Promise(function(resolve) {
        setTimeout(resolve, time);
    });
};

var delay = async(function*(time, message) {
    yield timer(time);
    console.log(message);
});

async.main(function*() {
    yield delay(1000, "Hello");
    yield delay(2000, "Goodbye");
});

```

## Functions

##### async(genFunction)
This function takes a generator function and returns a function that will return a promise. Inside the generator whenever a yield is reached the value will be turned into a Promise then when the Promise is resolved it will resume the generator sending the value to the generator.

```javascript
var async = require('es6-simple-async');

var timer = function(time) {
    return new Promise(function(resolve) {
        setTimeout(resolve, time);
    });
};

var delay = async(function*(value, time) {
    yield timer(1000); // Asynchrously completes the promise then
                       // resumes the generator at this position
    return value; // Resolves the promise of the async function so any
                  // async function yielding on a Promise returned by this
                  // function will recieve value when it resumes
});

async.main(function*() {
    var value = yield delay('cats', 1000); // recieves value cat after
                                           // 1000 milliseconds
    console.log("Value");
});
```

Errors are thrown back into the generator so:
```javascript

var task = async(function*() {
    try {
        var data = yield request('www.google.com');
    } catch (err) {
        // If request('www.google.com') rejects for whatever reason we'll
        // an error will be thrown at the yield statement so we can just
        // wrap it in a try/catch block as usual
        console.log("Couldn't get data");
    };
});

```



##### async.run(genFunc) / async.do(genFunc)
async.run (or the async.do alias) immediately invokes the given async function and returns a Promise for the value returned:
```javascript
var timer = function(time) {
    return new Promise(function(resolve) {
        setTimeout(resolve, time);
    });
};

async.run(function*() {
    yield timer(1000);
    return 3;
}).then(function(value) {
    console.log(value); // Prints 3 after 1000 seconds
});

```


##### async.main(genFunc)
async.main is much like async.run but if there's an error it will print it to the console.


##### async.from(iterable)
async.from converts an iterable into an async function, this could be useful if creating custom iterators instead of using generators.

```javascript

var async = require('es6-simple-async');

var timer = function(time) {
    return new Promise(function(resolve) {
        setTimeout(resolve, time);
    });
};

var delay = async(function*(value, time) {
    yield timer(1000); // Asynchrously completes the promise then
                       // resumes the generator at this position
    return value; // Resolves the promise of the async function so any
                  // async function yielding on a Promise returned by this
                  // function will recieve value when it resumes
});

var CustomIterator = function() {
    this.value = 0;
};

CustomIterator.prototype.next = function() {
    if (this.value < 10) {
        this.value = this.value + 1;
        var result = delay('cats', 1000);
        return {value: result, done: false};
    } else {
        return {value: 10, done: true};
    };
};

CustomIterator.prototype[Symbol.iterator] = function() {
    return this;
};

var task = async.from(new CustomIterator());
task().then(function(value) {
    console.log(value); // Prints 10 after 10 seconds
});


```
