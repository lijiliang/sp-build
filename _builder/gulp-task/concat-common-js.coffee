# fs = require 'fs'
# path = require 'path'
# gulp = require 'gulp'
# gutil = require 'gulp-util'
# config = require '../configs/config.coffee'
#
#
# module.exports = (gulp,$)->
#     return ()->
#         commonFilsMap = [];
#         commonFilsMap = config.vendorList.concat(config.globalList) ;
#         commonFilsMap.push( config.jsDevPath + '_common.js' ) ;
#         #输出正常的common.js
#
#         gulp.src commonFilsMap
#             .pipe $.newer(config.jsDevPath + 'common.js')
#             .pipe $.plumber()
#             .pipe $.sourcemaps.init()
#             .pipe $.concat("common.js")
#             .pipe $.size()
#             .pipe gulp.dest(config.jsDevPath)
#             .pipe $.sourcemaps.write('./')
#             .pipe gulp.dest(config.jsDevPath)


path = require 'path';
config = require '../configs/config.coffee';

# 组装数组，用来打包成common.js
# 常用库，如jquery, react等
commonJs = {};
commonFilsMap = [];
commonFilsMap = config.vendorList.concat(config.globalList) ;
commonFilsMap.push( config.jsDevPath + '_common.js' ) ;
commonJs = {'common': commonFilsMap };

webpackDevConfig = require('../configs/webpack.config.js');
module.exports = (gulp,$)->
    return () ->
        webpackDevConfig.build(null,commonJs);




# fs = require 'fs';
# path = require 'path';
# gulp = require 'gulp';
# gutil = require 'gulp-util';
# config = require '../configs/config.coffee';
# webpack = require 'webpack';

# webpackDevConfig = require('../configs/webpack.config.js').create(null,commonJs);
# webpackDevCompiler = webpack(webpackDevConfig);
#
# module.exports = (gulp,$)->
#     return (callback) ->
#         webpackDevCompiler.run (err, stats) ->
#             if (err)
#                 throw new gutil.PluginError('[webpack]', err) ;
#             gutil.log('[webpack]', stats.toString({ colors: true } )) ;
#             callback() ;

#
