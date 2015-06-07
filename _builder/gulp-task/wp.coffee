module.exports = (gulp,$,pack)->
    return (cb) ->
        pack.build('pages',cb);
