### Author James "The Jamesernator" Browning
    2016
###
"use strict"
GeneratorFunction = Object.getPrototypeOf(-> yield return).constructor

async = (genFunc) ->
    ### async converts a GeneratorFunction into a ES7 async function ###
    unless genFunc instanceof GeneratorFunction
        # If we don't have a generator stop and don't proceed
        throw new Error("Passed non-generator to async")

    return spawn = (args...) ->
        # This spawn function is the spawn function defined here:
        # https://tc39.github.io/ecmascript-asyncawait/#desugaring
        return new Promise (resolve, reject) =>
            # Initialize gen with the correct scope of this and pass in the
            # arguments given
            gen = genFunc.apply(this, args)
            step = (nextFunc) ->
                # This function will be called whenever a promise returned
                # from gen.next(...) resolves
                try
                    # Find out if passing the value back into the generator
                    # succeeds
                    next = nextFunc()
                catch err
                    # If it threw an error then we're done so reject with
                    # that error
                    reject(err)
                    return
                if next.done
                    # If the generator is done then this is the return value
                    # so just resolve our promise to it
                    resolve(next.value)
                    return

                # Take the value yielded and treat it as a promise
                Promise.resolve(next.value).then (val) ->
                    # If there's a value then step again with a function
                    # that tries to pass it to the generator
                    step ->
                        return gen.next(val)
                , (err) ->
                    # But if there's an error than try throwing it to the
                    # generator
                    step ->
                        return gen.throw(err)
            step ->
                # Start our generator
                return gen.next(undefined)


async.run = (func, errCallback=console.log) ->
    ### This tries running the async function given and if it
        fails it calls the errCallback with the error given
        by the async function
    ###
    do async ->
        try
            yield async(func)()
        catch err
            errCallback(err)

async.main = (func) ->
    ### Although async.run has errCallback as console.log we'll just print
        the stack
    ###
    async.run func, (err) ->
        console.log err.stack

async.from = (iterable) ->
    ### Creates a async function from an existing iterable ###
    genFunc = -> yield from iterable
    return async(genFunc)

async.do = async.run

Object.defineProperty(async, "name", value: "async")

if module?
    module.exports = async
else
    window.async = async
