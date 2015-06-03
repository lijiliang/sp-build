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

opts =
    type: 'hbs'
    data:
        'aaa':
              'title': '好好学习'
              'des': '就是这样的好好学习就好了'
        'index':
              list

module.exports = (gulp,$)->
    return () ->
        require('../configs/webpack.config.js').build(config.dirs.src + '/hbs/',opts);
