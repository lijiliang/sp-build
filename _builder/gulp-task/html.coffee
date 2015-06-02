# fs = require 'fs'
# path = require 'path'
# gulp = require 'gulp'
# gutil = require 'gulp-util'
# config = require '../configs/config.coffee'
#
#
# module.exports = (gulp,$)->
#     return ()->
#         gulp.src config.dirs.src + '/html/**/*.html'
#             .pipe $.newer(config.htmlDevPath)
#             .pipe $.plumber()
#             .pipe $.fileInclude({
#                 prefix: '@@',
#                 basepath: '@file',
#                 context: {
#                     dev: !gutil.env.production
#                 }
#             } )
#             .pipe $.size()
#             .pipe gulp.dest( config.htmlDevPath )


config = require '../configs/config.coffee'
module.exports = (gulp,$)->
    return () ->
        require('../configs/webpack.config.js').build(config.dirs.src + '/html/',{type: 'html'});
