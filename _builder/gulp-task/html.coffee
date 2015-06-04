fs = require 'fs'
path = require 'path'
gulp = require 'gulp'
gutil = require 'gulp-util'
config = require '../configs/config.coffee'


list = {}
htmlDirPath = config.dirs.src + '/html'
htmlDir = fs.readdirSync( htmlDirPath );
htmlDir.map (filename)->
    firstPath = htmlDirPath + '/' + filename
    if (fs.statSync(firstPath).isDirectory() && filename.indexOf('_')!=0 )
        list[filename] = list[filename] || {}
        list[filename].group = list[filename].group || filename
        list[filename].list = list[filename].list || []
        includeDir = fs.readdirSync(firstPath)
        includeDir.map (_filename)->
            secondPath = firstPath + '/' + _filename
            if ( !fs.statSync(secondPath).isDirectory() )
                content = fs.readFileSync(secondPath,'utf8')
                title = content.match(/<title>([\s\S]*?)<\/title>/ig)
                if(title!=null && title[0])
                    title = title[0].replace(/\<(\/?)title\>/g,'')
                    list[filename].list.push({
                        group: filename,
                        title: title,
                        fileName: _filename
                        fullpath: secondPath
                    })



module.exports = (gulp,$,pack)->
    return () ->
        if(fs.statSync(config.dirs.src + '/html/index.hbs').isFile() )
            gulp.src config.dirs.src + '/html/index.hbs'
                .pipe $.plumber()
                .pipe $.size()
                .pipe $.compileHandlebars(list)
                .pipe $.rename('index.html')
                .pipe gulp.dest(config.htmlDevPath)

        pack.build(config.dirs.src + '/html/',{type: 'html'});
