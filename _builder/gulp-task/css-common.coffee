fs = require 'fs'
path = require 'path'
gulp = require 'gulp'
gutil = require 'gulp-util'
config = require '../configs/config.coffee'


createCommonCss = () ->
    requireCssList = '';

    #引进setting.scss
    requireCssList += '@import "modules/settings/_setting.scss";\n';

    #引进base css
    fs.readdirSync(config.baseCssDir).forEach (item) ->
        requireCssList += '@import "modules/base/'+item+'";\n';

    #引进utils css
    fs.readdirSync(config.utilCssDir).forEach (item) ->
        requireCssList += '@import "modules/utils/'+item+'";\n';

    #引进ui css
    fs.readdirSync(config.uiCssDir).forEach (item) ->
        requireCssList += '@import "modules/ui/'+item+'";\n';

    tmpCss = config.dirs.src + '/css/tmp.scss'
    fs.writeFileSync( tmpCss , requireCssList) ;


module.exports = (gulp,$)->
    return ()->

        createCommonCss();

        gulp.src [config.dirs.src + '/css/tmp.scss']
        .pipe $.newer(config.cssDevPath + 'common.css')
        .pipe $.plumber()
        .pipe $.rimraf()
        .pipe $.sass()
        .pipe $.autoprefixer('last 2 version')
        .pipe $.size()
        .pipe $.rename("common.css")
        .pipe gulp.dest(config.cssDevPath)
