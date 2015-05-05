fs = require 'fs'
path = require 'path'
gulp = require 'gulp'
gutil = require 'gulp-util'
config = require '../configs/config.coffee'
webpack = require 'webpack'

webpackDevConfig = require('../configs/webpack.config.js')
webpackDevCompiler = webpack(webpackDevConfig)

module.exports = (gulp,$)->
    return (callback) ->
        webpackDevCompiler.run (err, stats) ->
            if (err)
                throw new gutil.PluginError('[webpack]', err) ;
            gutil.log('[webpack]', stats.toString({ colors: true } )) ;
            callback() ;
            return
