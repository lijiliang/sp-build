# fs = require 'fs';
# path = require 'path';
# gulp = require 'gulp';
# gutil = require 'gulp-util';
# config = require '../configs/config.coffee';
# webpack = require 'webpack';
#
# webpackDevConfig = require('../configs/webpack.config.js').create('pages',false);
# webpackDevCompiler = webpack(webpackDevConfig);
#
# module.exports = (gulp,$)->
#     return (a) ->
#         webpackDevCompiler.run (err, stats) ->
#             if(err)
#                 throw new gutil.PluginError('[webpack]', err) ;
#             gutil.log('[webpack]', stats.toString({ colors: true } )) ;
#             a()


# cb是个神奇的东东，居然不能去掉，什么bug
module.exports = (gulp,$)->
    return (cb) ->
        require('../configs/webpack.config.js').build('pages',cb);
