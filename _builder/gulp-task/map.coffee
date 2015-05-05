fs = require 'fs'
path = require 'path'
gulp = require 'gulp'
gutil = require 'gulp-util'
config = require '../configs/config.coffee'

module.exports = (gulp,$)->

    mapJson =
        version: config.version
        name: "sipin-webstore"
        createdAt: (new Date()).toString()
        commonDependencies: {
            css: {}
            js: {}
        } ,
        dependencies: {
            css: {}
            js: {}
        }


    gulp.task 'buildMap:js',['buildCommon:dev','ie:dev'], ->
        gulp.src [config.jsDevPath + '/**/*.js','!'+config.jsDevPath+'/_common.js','!'+config.jsDevPath+'/ui - kits.js']
            .pipe $.md5({
                size: 10,
                separator: '.'
            } )
            .pipe $.uglify()
            .pipe $.size()
            .pipe gulp.dest(config.jsBuildPath)
            .pipe $.map (file)->
                _filename = path.basename(file.path).toString() ;
                _filename = _filename.slice(0, _filename.length) ;
                filename = _filename.slice(0, _filename.length - 14) ;
                filename = filename.replace(/-/g,"/") ;
                if(filename == "common" || filename == "ie")
                    mapJson['commonDependencies']['js'][filename] = _filename;
                else
                    mapJson['dependencies']['js'][filename] = _filename;
                return;


    gulp.task 'buildAdminCss',['images:build','buildMap:js'],->
        gulp.src [config.cssDevPath + '/common.css',config.cssDevPath + '/article.css',config.cssDevPath + '/goods.css']
            .pipe $.concat("style.css")
            .pipe $.minifyCss()
            .pipe $.size()
            .pipe gulp.dest(config.cssBuildPath+'/admin-css')

    gulp.task 'buildMap:css',['buildAdminCss'], ->
        gulp.src config.cssDevPath + '/**/*.css'
            .pipe $.md5({
                size: 10,
                separator: '.'
            } )
            .pipe $.minifyCss()
            .pipe $.size()
            .pipe gulp.dest(config.cssBuildPath)
            .pipe $.map (file) ->
                _filename = path.basename(file.path).toString() ;
                _filename = _filename.slice(0, _filename.length) ;
                filename = _filename.slice(0, _filename.length - 15) ;
                filename = filename.replace(/-/g,"/") ;
                if(filename == "common")
                    mapJson['commonDependencies']['css'][filename] = _filename;
                else
                    mapJson['dependencies']['css'][filename] = _filename;
                return;

    gulp.task 'buildMap:writeMap',['buildMap:css','fonts:build'], () ->
        fs.writeFileSync( config.staticPath + '/map.json', JSON.stringify(mapJson)) ;

    return ()->
        gulp.start 'buildMap:writeMap'
