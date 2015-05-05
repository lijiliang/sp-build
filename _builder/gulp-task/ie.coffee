gulp = require 'gulp'
gutil = require 'gulp-util'
config = require '../configs/config.coffee'

module.exports = (gulp,$)->
    return ()->
        gulp.src config.ieRequireList
            .pipe $.newer(config.jsDevPath + 'ie.js')
            .pipe $.sourcemaps.init()
            .pipe $.concat("ie.js")
            .pipe $.size()
            .pipe gulp.dest(config.jsDevPath)
            .pipe $.sourcemaps.write('./')
            .pipe gulp.dest(config.jsDevPath)
