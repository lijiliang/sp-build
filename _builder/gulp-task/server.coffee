fs = require 'fs'
path = require 'path'
gulp = require 'gulp'
gutil = require 'gulp-util'
config = require '../configs/config.coffee'
browserSync = require 'browser-sync'
reload = browserSync.reload

module.exports = (gulp,$)->
    return ()->
        browserSync(
            port: 9000
            ui:
                port: 9001
            server:
                baseDir: [ config.htmlDevPath, config.staticPath + '/dev']
            files: [ config.htmlDevPath + '/*.html', config.staticPath+ '/dev/**']
            logFileChanges: false
        )

        #css and sprite
        gulp.watch [config.dirs.src + '/css/**/*.scss',config.dirs.src + '/images/slice/*.png'], ['sprite:dev']
        #js
        gulp.watch config.dirs.src + '/js/?(modules|pages|widgets)/**/*.?(coffee|js|jsx|cjsx|hbs|scss|css)', ['buildCommon:dev']
        #html
        gulp.watch config.dirs.src + '/html/**/*.html', ['html','html:list']
        gulp.watch config.dirs.src + '/html/index.hbs', ['html:list']
