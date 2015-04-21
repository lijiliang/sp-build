fs                  = require('fs')
path                = require('path')
gulp                = require('gulp')
gutil               = require('gulp-util')
webpack             = require 'webpack'
#WebpackDevServer    = require("webpack-dev-server")
configs             = require './config'

webpackDevConfig = require('./webpack.config.js')
webpackProductionConfig    = require('./webpack.production.config.js')

webpackDevCompiler  = webpack(webpackDevConfig)
webpackProductionCompiler  = webpack(webpackProductionConfig)


browserSync = require 'browser-sync'
reload = browserSync.reload


# Load plugins
$ = require('gulp-load-plugins')()

# 静态目录
staticPath = configs.dirs.dist + '/' + configs.version
htmlPath = configs.dirs.dist + '/html'
jsBuildPath = configs.dirs.dist + '/' + configs.version + '/js/'
cssBuildPath = configs.dirs.dist + '/' + configs.version + '/css/'
imagesBuildPath = configs.dirs.dist + '/' + configs.version + '/images/'
fontsBuildPath = configs.dirs.dist + '/' + configs.version + '/fonts/'

###
 * Task: Clean
 * @author wilson
 * @description 将dist资源目录进行清理
 *
###
gulp.task 'clean', ->
    gulp.src [jsBuildPath,cssBuildPath,imagesBuildPath,fontsBuildPath]
        .pipe $.rimraf()


###
 * 合并ie8需要的脚本依赖
###
gulp.task 'ie', ->
    gulp.src configs.ieRequireList
        .pipe $.sourcemaps.init()
        .pipe $.concat("ie.dev.js")
        .pipe $.size()
        .pipe gulp.dest(jsBuildPath)
        .pipe $.sourcemaps.write('./')
        .pipe gulp.dest(jsBuildPath)

###
 * 合并ie8需要的脚本依赖min版
###
gulp.task 'ie:min', ->
    gulp.src configs.ieRequireList
        .pipe $.concat("ie.js")
        .pipe $.uglify()
        .pipe $.size()
        .pipe gulp.dest(jsBuildPath)


# 合并common.css
baseCssDir = configs.dirs.src+'/css/modules/base/';
uiCssDir = configs.dirs.src+'/css/modules/ui/';
utilCssDir = configs.dirs.src+'/css/modules/utils/';
pageCssDir = configs.dirs.src+'/css/pages/';

#common.css
gulp.task 'css:common',->
    requireCssList = '';

    #引进setting.scss
    requireCssList += '@import "modules/settings/_setting.scss";\n';

    #引进base css
    fs.readdirSync(baseCssDir).forEach (item)->
        requireCssList += '@import "modules/base/'+item+'";\n';

    #引进utils css
    fs.readdirSync(utilCssDir).forEach (item)->
        requireCssList += '@import "modules/utils/'+item+'";\n';

    #引进ui css
    fs.readdirSync(uiCssDir).forEach (item)->
        requireCssList += '@import "modules/ui/'+item+'";\n';

    tmpCss = configs.dirs.src + '/css/tmp.scss'
    fs.writeFileSync( tmpCss ,requireCssList);


    gulp.src [tmpCss]
    .pipe $.plumber()
    #.pipe $.sourcemaps.init()
    .pipe $.rimraf()
    .pipe $.sass()
    .pipe $.autoprefixer('last 2 version')
    .pipe $.rename("common.dev.css")
    .pipe $.size()
    .pipe gulp.dest(cssBuildPath)
    .pipe $.minifyCss()
    .pipe $.size()
    .pipe $.rename("common.css")
    .pipe gulp.dest(cssBuildPath)
    #.pipe $.sourcemaps.write('./')
    #.pipe gulp.dest(cssBuildPath)


#page.css
gulp.task 'css:pages',->
    entryArr = [];
    fs_pageCssDir = fs.readdirSync(pageCssDir);
    fs_pageCssDir.forEach (item)->
        if (fs.statSync(pageCssDir + item).isDirectory())
            pageCssDirPath = pageCssDir + item
            if( !fs.existsSync(pageCssDirPath+'/'+item+'.scss') )
                pageCssDirFiles = fs.readdirSync(pageCssDirPath);
                pageCssDirFilesPaths = [];
                pageCssDirFiles.forEach (file)->
                    pageCssDirFilesPaths.push(pageCssDirPath+'/'+file)
                if(pageCssDirFilesPaths.length)
                    gulp.src pageCssDirFilesPaths
                    .pipe $.plumber()
                    #.pipe $.sourcemaps.init()
                    .pipe $.concat(item+".dev.scss")
                    .pipe $.sass()
                    .pipe $.autoprefixer('last 2 version', 'safari 5', 'ie 8', 'ie 9', 'opera 12.1', 'ios 6', 'android 4')
                    .pipe $.size()
                    .pipe gulp.dest(cssBuildPath)
                    .pipe $.minifyCss()
                    .pipe $.size()
                    .pipe $.rename(item+'.css')
                    .pipe gulp.dest(cssBuildPath)
                    #.pipe $.sourcemaps.write('./')
                    #.pipe gulp.dest(cssBuildPath)
            else
                entryArr.push(pageCssDirPath+'/'+item+'.scss');

    gulp.src entryArr
    .pipe $.plumber()
    .pipe $.sass()
    .pipe $.autoprefixer('last 2 version', 'safari 5', 'ie 8', 'ie 9', 'opera 12.1', 'ios 6', 'android 4')
    .pipe $.size()
    .pipe $.rename({ suffix: '.dev' })
    .pipe gulp.dest(cssBuildPath)

    # min css
    gulp.src entryArr
    .pipe $.plumber()
    .pipe $.sass()
    .pipe $.autoprefixer('last 2 version', 'safari 5', 'ie 8', 'ie 9', 'opera 12.1', 'ios 6', 'android 4')
    .pipe $.minifyCss()
    .pipe $.size()
    .pipe gulp.dest(cssBuildPath)




###
 * 对CSS进行合并
###
gulp.task 'styles', ->
    gulp.src [configs.dirs.src + '/css/style.scss',configs.dirs.src + '/css/style_ie8.scss']
        .pipe $.plumber()
        .pipe $.sass()
        .pipe $.autoprefixer('last 2 version', 'safari 5', 'ie 8', 'ie 9', 'opera 12.1', 'ios 6', 'android 4')
        .pipe $.size()
        .pipe gulp.dest(cssBuildPath)


# 雪碧图
gulp.task 'sprite', ['css:common','css:pages','images'], (callback)->

    entryArr = [];
    fs_pageCssDir = fs.readdirSync(pageCssDir);
    fs_pageCssDir.forEach (item)->
        if (fs.statSync(pageCssDir + item).isDirectory())
            pageCssDirPath = pageCssDir + item
            if( !fs.existsSync(pageCssDirPath+'/'+item+'.scss') )
                pageCssDirFiles = fs.readdirSync(pageCssDirPath);
                pageCssDirFilesPaths = [];
                pageCssDirFiles.forEach (file)->
                    pageCssDirFilesPaths.push(pageCssDirPath+'/'+file)
                if(pageCssDirFilesPaths.length)
                    entryArr.push cssBuildPath+item+'.css'
            else
                entryArr.push cssBuildPath+item+'.css'

    gulp.src entryArr
        .pipe $.plumber()
        .pipe $.cssSpritesmith({
            # sprite背景图源文件夹，只有匹配此路径才会处理，默认 images/slice/
            imagepath: configs.dirs.dist + '/' + configs.version+'/images/slice/',
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
            spritestamp: true,
            # 在CSS文件末尾追加时间戳，默认不追加
            cssstamp: true
        })
        .pipe $.debug({title: 'sprite:'})
        .pipe $.if('*.png',gulp.dest(imagesBuildPath))
        .pipe $.if('*.css', gulp.dest('./'))
        .pipe $.if('*.css', $.minifyCss())
        .pipe $.if('*.css', $.rename({ suffix: '.min' }))
        .pipe $.if('*.css', gulp.dest('./'))

###
 * Task: Copyed images
 * @author wilson
 * @description 对图像资源复制至dist
 *
###
gulp.task 'images', ->
    gulp.src configs.dirs.src + '/images/**/*.*'
        .pipe $.size()
        .pipe $.copyExt()
        .pipe gulp.dest(imagesBuildPath)

###
 * Task: Copyed fonts
 * @author wilson
 * @description 对字体图标资源复制至dist
 *
###
gulp.task 'fonts', ->
    gulp.src configs.dirs.src + '/fonts/**/*.*'
        .pipe $.size()
        .pipe $.copyExt()
        .pipe gulp.dest(fontsBuildPath)



#生成页面列表
listJson = {};
gulp.task 'html:listJson', ->
    listJson = {};
    gulp.src configs.dirs.src + '/html/*/*.html'
        .pipe $.plumber()
        .pipe $.map (file)->
            _filePath = file.path.split(path.sep).join('/');
            filePath = _filePath.split("/html/")[1];
            filePathArr = filePath.split("/");
            if(filePathArr.length>1 && filePathArr[0]!="common")
                html = file.contents.toString('utf-8');
                title = html.match(/<title>([\s\S]*?)<\/title>/ig)[0];
                newtitle = title.replace("<title>",'').replace("</title>",'');
                listJson[filePathArr[0]] = listJson[filePathArr[0]] || {}
                listJson[filePathArr[0]].group = listJson[filePathArr[0]].group || filePathArr[0];
                listJson[filePathArr[0]].list = listJson[filePathArr[0]].list || [];
                listJson[filePathArr[0]].list.push({
                    group: filePathArr[0],
                    title: newtitle,
                    fileName: filePathArr[filePathArr.length-1],
                    fullpath: file.path
                })

gulp.task 'html:list', ['html:listJson'], ->
    gulp.src configs.dirs.src + '/html/index.hbs'
        .pipe $.plumber()
        .pipe $.size()
        .pipe $.compileHandlebars(listJson)
        .pipe $.rename('index.html')
        .pipe gulp.dest(configs.dirs.dist + '/html')


###
 * Task: Html
 * @author wilson
 * @description 对静态页面进行编译
 *
###
gulp.task 'html', ->
    gulp.src configs.dirs.src + '/html/**/*.html'
        .pipe $.plumber()
        .pipe $.fileInclude({
            prefix: '@@',
            basepath: '@file',
            context: {
                dev: !gutil.env.production
            }
        })
        .pipe $.size()
        .pipe gulp.dest( './dist/html' )

###
 * Task: Dev
 * @author wilson
 * @description 用于reload时，合并webpack的资源
 *
###
gulp.task 'dev',['webpack:dev'], ->

    gutil.log('-------- 开始合并common.js/common.min.js --------');
    commonFilsMap = [];
    commonFilsMap = configs.vendorList.concat(configs.globalList);
    commonFilsMap.push(jsBuildPath+'_common.dev.js');
    #输出正常的common.js
    gulp.src commonFilsMap
        .pipe $.plumber()
        .pipe $.sourcemaps.init()
        .pipe $.concat("common.dev.js")
        .pipe $.size()
        .pipe gulp.dest(jsBuildPath)


###
 * Task: Doc
 * @author wilson
 * @description 生成API文档，有待改良
 *
###
gulp.task 'doc', ->
    gulp.src ['gulpfile.coffee',configs.dirs.src + '/js/global/*.coffee']
        .pipe $.coffee({bare: true})
        .pipe $.doxit()
        .pipe gulp.dest( './doc/global' )

    # gulp.src [config.src + '/js/']
    #     .pipe $.coffee({bare: true})
    #     .pipe $.apiDoc({markdown: true})
    #     .pipe gulp.dest( './doc' )


###
 * Task: Server
 * @author wilson
 * @description 本地资源静态DEMO服务器
 *
###
gulp.task "server", ['buildCommon:dev','html','html:list','ie','ie:min','fonts','sprite'] , ->
    browserSync(
        port: 9000
        ui:
            port: 9001
        server:
            baseDir: [htmlPath,staticPath]
        files: [htmlPath + '/*.html',staticPath+ '/**']
        logFileChanges: false
    )

    #css and sprite
    gulp.watch [configs.dirs.src + '/css/**/*.scss',configs.dirs.src + '/images/slice/*.png'], ['sprite']
    #js
    gulp.watch configs.dirs.src + '/js/?(modules|pages|widgets)/**/*.?(coffee|js|jsx|cjsx|hbs|scss|css)', ['dev']
    #html
    gulp.watch configs.dirs.src + '/html/**/*.html', ['html','html:list']
    gulp.watch configs.dirs.src + '/html/index.hbs', ['html:list']


###
 * Task: Webpack:dev
 * @author wilson
 * @description 编译webpack未压缩的资源
 *
###
gulp.task 'webpack:dev',(callback)->
    webpackDevCompiler  = webpack(webpackDevConfig)
    webpackDevCompiler.run (err, stats)->
        if (err)
            throw new gutil.PluginError('[webpack:dev]', err);
        gutil.log('[webpack:dev]', stats.toString({ colors: true }));
        callback();
        return

###
 * Task: Webpack:dev
 * @author wilson
 * @description 编译webpack压缩后资源
 *
###
gulp.task 'webpack:pro',(callback)->
    webpackProductionCompiler.run (err, stats)->
        if (err)
            throw new gutil.PluginError('[webpack:pro]', err);
        gutil.log('[webpack:production]', stats.toString({ colors: true }));
        callback();
        return


###
 * Task: default
 * @author wilson
 * @description 默认启动本地DEMO服务器
 *
###
gulp.task 'default',['clean'], ->
    gulp.start 'server'


# 构建任务，生成未压缩版
gulp.task 'buildCommon:dev',['webpack:dev'],()->
    commonFilsMap = [];
    commonFilsMap = configs.vendorList.concat(configs.globalList);
    commonFilsMap.push(jsBuildPath+'_common.dev.js');
    #console.log(commonFilsMap);

    #输出正常的common.js
    gulp.src commonFilsMap
        .pipe $.plumber()
        .pipe $.sourcemaps.init()
        .pipe $.concat("common.dev.js")
        .pipe $.size()
        .pipe gulp.dest(jsBuildPath)
        .pipe $.uglify()
        .pipe $.size()
        .pipe $.rename("common.js")
        .pipe gulp.dest(jsBuildPath)
        .pipe $.sourcemaps.write('./')
        .pipe gulp.dest(jsBuildPath)


# 构建任务，生成压缩版与未压缩版
gulp.task 'build',['clean'],()->
    gulp.start 'buildCommon'


gulp.task 'buildCommon',['webpack:dev','webpack:pro','ie','ie:min','fonts','sprite'],->

    commonFilsMap = [];
    commonFilsMap = configs.vendorList.concat(configs.globalList);
    commonFilsMap.push(jsBuildPath+'_common.dev.js');
    #console.log(commonFilsMap);

    #输出正常的common.js
    gulp.src commonFilsMap
        .pipe $.plumber()
        .pipe $.sourcemaps.init()
        .pipe $.concat("common.dev.js")
        .pipe $.size()
        .pipe gulp.dest(jsBuildPath)
        .pipe $.uglify()
        .pipe $.size()
        .pipe $.rename("common.js")
        .pipe gulp.dest(jsBuildPath)
        .pipe $.sourcemaps.write('./')
        .pipe gulp.dest(jsBuildPath)

###
 * Task: Map
 * @author wilson
 * @description 创建map.json文件
 *
###
mapJson =
    version: configs.version
    css:{}
    js:{}

gulp.task 'map:js', ->
    gulp.src jsBuildPath+'/**/*.js'
        .pipe $.md5(5)
        .pipe $.map (file)->
            filename = path.basename(file.path).toString();
            index = filename.lastIndexOf("_");
            #奇异的BUG，非要加console.log才能执行，why
            console.log(mapJson['js'][filename.substr(0,index)] = filename);
        .pipe gulp.dest(jsBuildPath)


gulp.task 'map:css',['map:js'], ->
    gulp.src cssBuildPath+'/**/*.css'
        .pipe $.md5(5)
        .pipe $.map (file)->
            filename = path.basename(file.path).toString();
            index = filename.lastIndexOf("_");
            # 奇异的BUG，非要加console.log才能执行，why
            console.log(mapJson.css[filename.substr(0,index)] = filename)
        .pipe gulp.dest(cssBuildPath)

gulp.task 'writeJson',['map:css'],->
    fs.writeFileSync( staticPath + '/map.json', JSON.stringify(mapJson));
    #console.log(mapJson)
