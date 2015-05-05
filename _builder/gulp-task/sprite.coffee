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
                        entryArr.push config.cssDevPath + item + '.css'
                else
                    entryArr.push config.cssDevPath + item + '.css'

        gulp.src entryArr
            .pipe $.newer(config.imagesDevPath)
            .pipe $.plumber()
            .pipe $.cssSpritesmith({
                # sprite背景图源文件夹，只有匹配此路径才会处理，默认 images/slice/
                imagepath: config.imagesDevPath + 'slice/',
                # 映射CSS中背景路径，支持函数和数组，默认为 null
                imagepath_map: null,
                # 雪碧图输出目录，注意，会覆盖之前文件！默认 images/
                spritedest: 'sprite/',
                # 替换后的背景路径，默认 ../images/
                spritepath: '../images/sprite/',
                # 各图片间间距，如果设置为奇数，会强制+1以保证生成的2x图片为偶数宽高，默认 0
                padding: 20,
                # 是否使用 image-set 作为2x图片实现，默认不使用
                useimageset: false,
                # 是否以时间戳为文件名生成新的雪碧图文件，如果启用请注意清理之前生成的文件，默认不生成新文件
                newsprite: false,
                # 给雪碧图追加时间戳，默认不追加
                spritestamp: false,
                # 在CSS文件末尾追加时间戳，默认不追加
                cssstamp: false
            } )
            .pipe $.debug({title: 'sprite:'} )
            .pipe $.if('*.png', gulp.dest(config.imagesDevPath))
            .pipe $.if('*.css', gulp.dest('./'))
