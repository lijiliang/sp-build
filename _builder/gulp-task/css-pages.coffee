fs = require 'fs'
path = require 'path'
gulp = require 'gulp'
gutil = require 'gulp-util'
config = require '../configs/config.coffee'


module.exports = (gulp,$)->
    return ()->

        entryArr = [];
        fs_pageCssDir = fs.readdirSync(config.pageCssDir) ;
        fs_pageCssDir.forEach (item) ->
            if (fs.statSync(config.pageCssDir + item).isDirectory())
                pageCssDirPath = config.pageCssDir + item
                if( !fs.existsSync(pageCssDirPath + '/'+item+'.scss') )
                    pageCssDirFiles = fs.readdirSync(pageCssDirPath) ;
                    pageCssDirFilesPaths = [];
                    pageCssDirFiles.forEach (file) ->
                        pageCssDirFilesPaths.push(pageCssDirPath + '/' + file)
                    if(pageCssDirFilesPaths.length)
                        gulp.src pageCssDirFilesPaths
                        .pipe $.newer(config.cssDevPath + item + ".scss")
                        .pipe $.plumber()
                        #.pipe $.sourcemaps.init()
                        .pipe $.concat(item + ".scss")
                        .pipe $.sass()
                        .pipe $.autoprefixer('last 2 version', 'safari 5', 'ie 8', 'ie 9', 'opera 12.1', 'ios 6', 'android 4')
                        .pipe $.size()
                        .pipe gulp.dest(config.cssDevPath)
                else
                    entryArr.push(pageCssDirPath + '/'+item+'.scss') ;

        gulp.src entryArr
        .pipe $.newer(config.cssDevPath)
        .pipe $.plumber()
        .pipe $.sass()
        .pipe $.autoprefixer('last 2 version', 'safari 5', 'ie 8', 'ie 9', 'opera 12.1', 'ios 6', 'android 4')
        .pipe $.size()
        .pipe gulp.dest(config.cssDevPath)
