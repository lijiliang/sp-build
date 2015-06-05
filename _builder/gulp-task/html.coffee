fs = require 'fs'
path = require 'path'
gulp = require 'gulp'
gutil = require 'gulp-util'
config = require '../configs/config.coffee'


# 首页列表数据
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
            ext = path.extname(_filename)
            if ( ext == '.hbs' || ext == '.html')
                secondPath = firstPath + '/' + _filename
                if ( !fs.statSync(secondPath).isDirectory() )
                    content = fs.readFileSync(secondPath,'utf8')
                    title = content.match(/<title>([\s\S]*?)<\/title>/ig)
                    if(title!=null && title[0])
                        title = title[0].replace(/\<(\/?)title\>/g,'')
                        list[filename].list.push({
                            group: filename,
                            title: title,
                            fileName: _filename.replace(ext,'.html')
                            fullpath: secondPath
                        })



module.exports = (gulp,$,pack)->
    return () ->
        # 生成分页并生成列表页
        datas = {
            index: list
        }
        pack.build(config.dirs.src + '/html/',{type: 'hbs',data: datas});
        # pack.build(config.dirs.src + '/html/index.hbs',{type: 'hbs',data: datas});
