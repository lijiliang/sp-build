config = require '../configs/config.coffee'
module.exports = (gulp,$,pack)->
    return () ->
        pack.build(config.pageCssDir,false,{type: 'sass'});
