# Cookie
define ()->
    class Cookie
        constructor: (@options)->
            this.options = options
            this.options.expires = options.expires || -1


        set: (name,value)->

        get: (name)->


    return Cookie
