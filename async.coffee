### Author James "The Jamesernator" Browning
    2016
###
"use strict"
async = (genFunc) -> asyncFunc = (args...) ->
    # This asyncFunc is simply a wrapper such that the function is not
    # immediately invoked
    return new Promise (resolve, reject) =>
        # Initialize gen with the correct scope of this and pass in the
        # arguments given
        gen = genFunc.apply(this, args)
        iter = do ->
            # Create an iterator that acts as the reentry point for the
            # awaited (yielded) promises
            result = undefined
            isError = false
            loop
                # Repeatedly get values from the generator
                unless isError
                    # If the result of the previous promise was a value
                    # send it into the generator
                    try
                        {value, done} = gen.next(result)
                    catch err
                        # But if there's an error from passing it to the
                        # generator then the generator raised an error
                        # so reject with the err given
                        reject(err)
                else
                    # If the result of the promise was an error however
                    # then throw it into the generator
                    try
                        {value, done} = gen.throw(result)
                    catch err
                        # But if the generator throws an error back then the
                        # generator either didn't handle the error
                        # or threw a new error so reject with that error
                        reject(err)

                if done
                    # If we managed to get to the done value of the generator
                    # then this is by definition the return value so we
                    # should resolve our promise for our asynchronous
                    # function with the value
                    resolve(value)
                    return

                # If we're not done then we'll convert what value we were given
                # into a promise (as per the async-await specification)
                awaiting = Promise.resolve(value)
                # We'll then suspend OUR OWN iterator on promise
                # and set the values for the next loop around appropriately
                {result, isError} = yield awaiting.then (_result) ->
                    iter.next({result: _result, isError: false})
                .catch (err) ->
                    iter.next({result: err, isError: true})
        # Start our own iterator to begin running the async function
        iter.next()

if module?
    module.exports = async
else
    window.async = async
