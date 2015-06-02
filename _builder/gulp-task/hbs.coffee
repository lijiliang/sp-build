config = require '../configs/config.coffee'
module.exports = (gulp,$)->
    return () ->
        require('../configs/webpack.config.js').build(config.dirs.src + '/hbs/',{type: 'hbs'});
