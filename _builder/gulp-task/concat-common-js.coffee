fs = require 'fs'
path = require 'path'
gulp = require 'gulp'
gutil = require 'gulp-util'
config = require '../configs/config.coffee'


module.exports = (gulp,$)->
    return ()->
        commonFilsMap = [];
        commonFilsMap = config.vendorList.concat(config.globalList) ;
        commonFilsMap.push( config.jsDevPath + '_common.js' ) ;
        #输出正常的common.js
        
        gulp.src commonFilsMap
            .pipe $.newer(config.jsDevPath + 'common.js')
            .pipe $.plumber()
            .pipe $.sourcemaps.init()
            .pipe $.concat("common.js")
            .pipe $.size()
            .pipe gulp.dest(config.jsDevPath)
            .pipe $.sourcemaps.write('./')
            .pipe gulp.dest(config.jsDevPath)
