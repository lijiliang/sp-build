var fs = require('fs');
var path = require('path');
var gulp = require('gulp');
var __ = require('lodash');
var through = require('through2');
var gutil = require('gulp-util');
var $extend = require('extend');
var webpack = require('webpack');
var configs = require('./config');
var alias = require('./webpack.alias.js');
var ExtractTextPlugin = require("extract-text-webpack-plugin");

var $ = require('gulp-load-plugins')();

function getObjType(object){
    return Object.prototype.toString.call(object).match(/^\[object\s(.*)\]$/)[1];
}

function clone(target){
    var t = getObjType(target);
    return t === 'Object' ? $extend(true, {}, target) : t === 'Array' ? $extend(true, [], target) : target;
}

function guid(prefix) {
    prefix = prefix || "web-";
    return (prefix + Math.random() + Math.random()).replace(/0\./g, "");
}

function chkType(type){
    var all = {
        style: ['css', 'scss', 'sass', 'less', 'stylus', 'styl'],
        templet: ['hbs', 'swig', 'htm', 'html', 'php', 'jsp'],
        script: ['js', 'jsx', 'coffee', 'cjsx']
    }
    for(var item in all){
        var isType = item;
        var arys = all[item];
        if(__.indexOf(arys,type)>-1)
            return isType;
    }
    return false;
}

/**
 * 获取目录结构
 */
// var config = configs.dirs;
// var pagesDir = fs.readdirSync(config.pages);

// var entry = {};

/**
 * 获取目录结构
 */
var
config = configs.dirs,
default_dir,
pagesDir;

/*
 * author: ralf
 * 将目录打包成一个文件准备
*/
var
package_name,
package_ary = [];


var entry = {};

// make directory json
function readPageDir(subDir, isPack, depth) {
    package_ary = [];

    var dirs = (subDir && subDir.fs) || pagesDir;
    // var dirsPath = (subDir && subDir.path) || config.pages;
    var dirsPath = (subDir && subDir.path) || default_dir;

    var sameName = false;
    dirs.forEach(function(item) {

        var _filename = (subDir && subDir.filename) || item;
        var name = (subDir && subDir.name) || item;


        //如果是目录
        // 忽略下划线目录，如_test, _xxx
        if ( depth && fs.statSync(dirsPath + '/' + item).isDirectory() && item.indexOf('_')!=0) {
            //获取目录里的脚本合并
            var data = {
                name: item,
                path: dirsPath + '/' + item,
                fs: fs.readdirSync(dirsPath + '/' + item),
                filename: (subDir && subDir.filename + "-" + item) || item
            };
            readPageDir(data, isPack, depth);
        }

        else {
            var ext = path.extname(dirsPath + '/' + item);
            if(chkType(ext.replace('.',''))){
                // 如果存在同名js
                if (!sameName) {
                    if (name == item.replace(ext, '')) {
                        entry[_filename] = [dirsPath + '/' + item];
                        sameName = true;
                    }
                    else {
                        entry[_filename] = entry[_filename] || [];
                        entry[_filename].push(dirsPath + '/' + item);
                } }

        } }

    });


    if(isPack){
        for(var name in entry){
           if(entry[name].length){
                entry[name].map(function(item,i){
                   package_ary.push(item);
                });
           }
        }
        entry = {};
        entry[package_name] = package_ary;
    }
}

//make webpack plugins
var plugins = function(dirname, isPack, options){

    var venders,
        common_trunk_config = {
            // chunks: entry,
            filename: '_common.js',
            minChunks: 2,
            async: false
            //children: true
            //minChunks: 5 //Infinity
        }

    if(options && options.type){
        if(options.type.toString().indexOf('ss')>-1 || options.type === 'stylus'){
            dirname = 'noCommon';
        }
    }

    var ExtractTextPlugin_allChunks = isPack === true ? true : false;
        ret_plugins = [
            //new webpack.HotModuleReplacementPlugin(),
            new webpack.NoErrorsPlugin(),
            new webpack.IgnorePlugin(/vertx/), // https://github.com/webpack/webpack/issues/353
            new ExtractTextPlugin("../css/[name].css", {
                allChunks: ExtractTextPlugin_allChunks,
            })
        ];

    if(getObjType(dirname)==='String' && dirname !== 'pages')
        common_trunk_config.filename = "_normal.js";

    if(dirname && getObjType(dirname)==='Object'){
        venders = dirname;
        // common_trunk_config.minChunks = "Infinity";
    }

    //commonstrunk plugin
    if(dirname !== 'noCommon'){
        if(venders && getObjType(venders)==='Object'){
            for(var v in venders){
                (function(item){
                    var vs = venders;
                    ret_plugins.push(
                        // new webpack.optimize.CommonsChunkPlugin(item+'.js',vs[item],'Infinity')
                        new webpack.optimize.CommonsChunkPlugin(item,item+'.js',2)
                    );
            })(v)
        } }

        else{
          ret_plugins.push(
            new webpack.optimize.CommonsChunkPlugin(common_trunk_config)
        ) }

        ret_plugins.push(
            new webpack.optimize.DedupePlugin()
            // function() {
            //     this.plugin("done", function(stats) {
            //       fs.writeFileSync(
            //         path.join(__dirname, config.dist + '/js/' + pkg.version + '/' + pkg.config.distName.uncompressed + '/', "map.json"),
            //         JSON.stringify(stats.toJson()));
            //     })
            // }
        );
    }

    return ret_plugins;
}

//make webpack loaders
var custom_modules = function(){
  return {
      loaders: [{
          test: /\.cjsx$/,
          loaders: ['react-hot', 'coffee', 'cjsx']
      }, {
          test: /\.coffee$/,
          loader: 'coffee',
          //exclude: [/common/, /node_modules/]
      }, {
          test: /\.hbs$/,
          loader: "handlebars-loader"
      }, {
          test: /\.jsx$/,
          loader: "jsx-loader"
      }, {
          test: /[\/\\]js[\/\\](vendor|global)[\/\\]/,   //http://stackoverflow.com/questions/28969861/managing-jquery-plugin-dependency-in-webpack
          loader: "script-loader"   //不做任何处理
      }, {
          test: /\.css$/,
          loader: ExtractTextPlugin.extract("css-loader")
      }, {
          test: /\.scss$/,
          loader: ExtractTextPlugin.extract('style-loader',"raw!sass")
          // loader: "style!css!sass"
      }, {
          test: /\.less$/,
          loader: ExtractTextPlugin.extract('style-loader',"raw!less")
      }, {
          test: /\.rt$/,
          loader: "react-templates-loader"
      },{
          test: /\.md$/,
          loader: "html!markdown"
      }
      // {
      //     test: /\.js$/,
      //     exclude: /node_modules/,
      //     loader: "babel-loader",
      //     query:{ compact: 'auto' }
      // }
      ]
  }
}

//webpack externals
custom_externals = {
    "jquery": "jQuery",
    "$": "jQuery",
    "React": "React"
}

// module.exports = {
/*
* isPack  boolean   为true 将会对比 dirname和configs.dirs，如果匹配，会将该目录下所有文件打包为一个文件
* isPack  jsonObject  指定打包的文件
* sample   concat-common-js.js / webpack.js
*/
module.exports = {
  create: function(dirname,isPack,options){

      var idf_plugins = plugins(dirname, isPack, options),
          idf_externals = custom_externals;

      if(dirname && getObjType(dirname)==='String'){
          entry = this.readDir(dirname,isPack,options);
      }

      else if( dirname && getObjType(dirname)==='Object'){
          entry = $extend(true,{},dirname);
          if(entry.noCommon || options.noCommon) {
              delete entry.noCommon;
              idf_plugins = plugins('noCommon');
          }
          else {
              delete entry.noCommon;
              idf_plugins = plugins(entry);
      } }

      else if( dirname && getObjType(dirname)==='Array'){
          idf_plugins = plugins('noCommon');
          entry = {'_ary': dirname};
      }

      // console.log(entry);

      return {
          //cache: true,
          //debug: true,
          devtool: "source-map",
          recursive: true,
          entry: entry,
          output: {
              path: path.join(__dirname,'../../', config.dist + '/' + configs.version + '/dev/js/'),
              publicPath: '../../' + configs.version + '/dev/js/',
              filename: configs.hash ? '[name]_[hash].js' : '[name].js',
          },
          externals: idf_externals,
          plugins: idf_plugins,
          module: custom_modules(),
          resolve: {
              root: path.resolve(__dirname),
              alias: alias,
              extensions: ['', '.js', '.jsx', '.cjsx', '.coffee', '.html', '.css', '.scss','.less','.hbs', '.rt','.md'],
              modulesDirectories: ["node_modules"],
      } } },

  build: function(dirname,isPack,options,cb){

      if(!isPack)
          isPack = false;

      if(getObjType(isPack)==='Object'){
          options = clone(isPack);
          isPack = false;
      }

      if(getObjType(isPack)==='Function'){
          cb = isPack;
          isPack = false;
      }

      if(!options)
          options = {};

      if(getObjType(options)==='Function'){
          cb = options;
          options = {};
      }

      if(getObjType(cb)!=='Function')
          cb = undefined;

      var tmpKey, tmpValue,
          type = (options && options.type) ? options.type : 'js',
          staticType = chkType(type),
          _webpackDevCompiler,
          _webpackDevConfig = staticType !== 'templet' ? this.create(dirname,isPack,options) : this.create(dirname,true,options),
          entrys = clone(entry);



      //数组或单文件，强制不进行合并，分别生成
      //如果需要合并，用json传进来
      // js css
      if(entrys._ary || entrys._src)
          isPack = false;


      //html hbs php
      if( staticType === 'templet')
          isPack = true;


      if (entrys){
          if(entrys.key){
              tmpKey = clone(entrys.key);
              tmpValue = clone(entrys.value);
              delete entrys.key;
              delete entrys.value;

              delete entry.key;
              delete entry.value;
          }

          //parse sass scss less css stylus
          function doStyle(){
              if(isPack===true){
                  // combo css
                  gulp.src([tmpValue])
                  .pipe($.newer(configs.cssDevPath + tmpKey +'.css'))
                  .pipe($.plumber())
                  // .pipe $.rimraf()
                  .pipe ($.if('*.sass', $.sass() ))
                  .pipe ($.if('*.scss', $.sass() ))
                  .pipe ($.if('*.less', $.less() ))
                  .pipe ($.if('*.styl', $.stylus() ))
                  .pipe ($.if('*.stylus', $.stylus() ))
                  .pipe($.autoprefixer('last 2 version', 'safari 5', 'ie 8', 'ie 9', 'opera 12.1', 'ios 6', 'android 4'))
                  .pipe($.size())
                  .pipe($.rename(tmpKey + ".css"))
                  // .pipe(gulp.dest(path.join(__dirname,'../../', config.dist + '/' + configs.version + '/dev/css/')))
                  .pipe(gulp.dest(configs.cssDevPath))
              }else{
                  //splite css
                  for(var file in entrys){
                      if(entrys[file].length){
                          (function(item){
                              gulp.src(entrys[item])
                              .pipe($.newer(configs.cssDevPath + item +'.css'))
                              .pipe($.plumber())
                              // .pipe $.rimraf()
                              .pipe ($.if('*.sass', $.sass() ))
                              .pipe ($.if('*.scss', $.sass() ))
                              .pipe ($.if('*.less', $.less() ))
                              .pipe ($.if('*.styl', $.stylus() ))
                              .pipe ($.if('*.stylus', $.stylus() ))
                              .pipe($.autoprefixer('last 2 version', 'safari 5', 'ie 8', 'ie 9', 'opera 12.1', 'ios 6', 'android 4'))
                              .pipe($.size())
                              .pipe($.rename(item + ".css"))
                              .pipe(gulp.dest(configs.cssDevPath))


                              //雪碧图
                              //config 是 configs 的子集
                              .pipe ($.newer(configs.imagesDevPath))
                              .pipe ($.plumber())
                              .pipe ($.cssSpritesmith({
                                  // sprite背景图源文件夹，只有匹配此路径才会处理，默认 images/slice/
                                  imagepath: configs.imagesDevPath + 'slice/',
                                  // 映射CSS中背景路径，支持函数和数组，默认为 null
                                  imagepath_map: null,
                                  // 雪碧图输出目录，注意，会覆盖之前文件！默认 images/
                                  spritedest: 'sprite/',
                                  // 替换后的背景路径，默认 ../images/
                                  spritepath: '../images/sprite/',
                                  // 各图片间间距，如果设置为奇数，会强制+1以保证生成的2x图片为偶数宽高，默认 0
                                  padding: 20,
                                  // 是否使用 image-set 作为2x图片实现，默认不使用
                                  useimageset: false,
                                  // 是否以时间戳为文件名生成新的雪碧图文件，如果启用请注意清理之前生成的文件，默认不生成新文件
                                  newsprite: false,
                                  // 给雪碧图追加时间戳，默认不追加
                                  spritestamp: false,
                                  // 在CSS文件末尾追加时间戳，默认不追加
                                  cssstamp: false
                              } ))
                              .pipe ($.debug({title: 'sprite:'} ))
                              .pipe ($.if('*.png', gulp.dest(configs.imagesDevPath)))
                              .pipe ($.if('*.css', gulp.dest('./')))

                          })(file);
                  } }
              }

              // if(type && (type==='sass' || type==='scss')){
              //     //gulp deal with style
              //     //something on up
              // }
              // else{
              //     //if webpack sass-loader has fixed , then can use this module,
              //     //node: edit fllow some code;
              //     _webpackDevCompiler = webpack(_webpackDevConfig);
              //     _webpackDevCompiler.run(function(err, stats){
              //         if(err){
              //             throw new gutil.PluginError('[webpack]', err) ;
              //         }
              //         gutil.log('[webpack]', stats.toString({ colors: true } )) ;
              //         if(cb) cb();
              //     });
              // }
          }



          //parse js jsx cjsx coffee ...
          function doScript(){

              _webpackDevCompiler = webpack(_webpackDevConfig);
              _webpackDevCompiler.run(function(err, stats){
                  if(err){
                      throw new gutil.PluginError('[webpack]', err) ;
                  }
                  gutil.log('[webpack]', stats.toString({ colors: true } )) ;
                  if(cb) cb();
              });
          }

          


          //parse html hbs swig ...
          function doTemplet(){
              var list = {};
              var indexList = {};
              var tmpObj;

              tmpValue = entry[tmpKey];

              //获取数据
              function getHtmlData(){

                  function fileProfile(file, enc, cb){
                      //json数据可以在这里导入
                      //md文件扫描

                      var data, api,
                          // _filename = file.path.replace(file.base,'').replace('.'+type,'');
                          _filename = file.path.replace(path.dirname(file.path),'').replace('.'+type,'').replace(/[\/\\]/g,'');

                      if (typeof options.data !=='undefined'){
                          data = clone(options.data);
                      }

                      if (typeof options.api !=='undefined'){
                          api = clone(options.api);
                      }

                      if(data && (_filename in data)){
                          file.data = data[_filename];
                      }else{
                          if( _filename === 'index' || _filename==='list' ){
                              //列表数据，还是应该放到外面生成
                          }
                      }

                      if(api && (_filename in api)){
                          /*todo something*/
                      }

                      this.push(file);
                      cb();
                  }
                  return through.obj(fileProfile);
              }


              /*
              * parse hbs to html
              * make index list
              */
              function parseHbs(){
                  gulp.src(tmpValue,{ base: path.join(config.src,'html/') })
                  .pipe (function(){
                      function testfun(file,enc,cb){
                          var ext_name = path.extname(file.path);
                          if(ext_name==='.md'||ext_name==='.markdown'||ext_name==='.json'){
                              cb();
                          }else{
                              this.push(file);
                              cb();
                          }
                      }
                      return through.obj(testfun)
                  }())
                  .pipe ($.newer(configs.htmlDevPath))
                  .pipe ($.plumber())
                  .pipe ($.fileInclude({
                      prefix: '@@',
                      basepath: '@file',
                      context: {
                          dev: !gutil.env.production
                      }
                  }))
                  .pipe ($.size())
                  .pipe ( getHtmlData())
                  .pipe ($.compileHandlebars())
                  .pipe ($.rename(function(path){
                      if(path.extname!=='.php' || path.extname!=='.jsp'){
                          path.extname = '.html'
                      }
                  }))
                  .pipe (gulp.dest(configs.htmlDevPath))
              }

              /*
              * parse html and build it
              * make index list
              */
              // function parseHtml(){
              //
              //     gulp.src (tmpValue,{ base: path.join(config.src,'html/') })
              //       .pipe (function(){
              //           function testfun(file,enc,cb){
              //               var ext_name = path.extname(file.path);
              //               if(ext_name!=='.html'){
              //                   cb();
              //               }else{
              //                   this.push(file);
              //                   cb();
              //               }
              //           }
              //           return through.obj(testfun)
              //       }())
              //       .pipe ($.newer(configs.htmlDevPath))
              //       .pipe ($.plumber())
              //       .pipe ($.fileInclude({
              //           prefix: '@@',
              //           basepath: '@file',
              //           context: {
              //               dev: !gutil.env.production
              //           }
              //       }))
              //       .pipe ($.size())
              //       .pipe (gulp.dest( configs.htmlDevPath ))
              // }

              switch(type){
                  case 'hbs':
                      parseHbs();
                      break;
                  case 'html':
                      parseHbs();
                      break;
              }
          }

          switch(staticType){
              case 'script':
                  doScript();
                  break;
              case 'style':
                  doStyle();
                  break;
              case 'templet':
                  doTemplet();
                  break;
              default:
                  doScript();
          }
      }//end if entry

  },

  readDir: function(dirname,isPack,options){
      opts = {
          reanme: undefined,
          type: undefined,
          prepend: undefined,
          prepend: undefined,
          append: undefined,
          depth: true
      };

      if(options && getObjType(options) === 'Object'){
          opts = $extend(true,opts,options);
      }

      var prepend=[],
          append=[],
          styleType = false,
          requireCssList = '',
          rename = opts.rename ? opts.rename : undefined,
          type = opts.type ? opts.type : undefined,
          staticType = chkType(type);


          //全局变量
          pagesDir=undefined;
          package_name='';
          entry = {};
          default_dir = dirname;

      //匹配configs.dirs
      for(var item in config){
          if(item === dirname){
              pagesDir = fs.readdirSync(config[item]);
              default_dir = config[item];
              package_name = isPack === true ? dirname : '';
      } }

      if(!pagesDir){
          //直接匹配目录
          if (!fs.existsSync(dirname)) {
              throw new Error("==============Error: you must identify a entry");
              return false;
          }else{
              if(fs.statSync(dirname).isDirectory()){
                  pagesDir = fs.readdirSync(dirname);
                  package_name = isPack === true ? path.basename(dirname) : '';
              }else if(fs.statSync(dirname).isFile()){
                  //todoo something
                  return {
                      '_src': dirname,
                      'key': '_src',
                      'value': dirname
                  }
              }
      } }

      //生成entry 全局
      readPageDir(null, isPack, opts.depth);

      if(entry){
        // if(type==='less' || type==='sass'|| type==='stylus'|| type==='css'|| type==='scss'){
            var ultimates = [],
                ext = styleType ? 'js' : type;

            //sass使用gulp解析，其他使用webpack解析
            if(type=='less' ||type==='stylus' ||type==='css' ||type==='styl')
                styleType = true;

            if(isPack){

                //merge prepend or append
                for(var item in entry){
                    package_name = item;
                    prepend = (opts.prepend && getObjType(opts.prepend)==='Array') ? opts.prepend : [],
                    append = (opts.append && getObjType(opts.append)==='Array') ? opts.append : [];
                    ultimates = prepend.concat(entry[item]).concat(append);
                }

                package_name = rename ? rename : package_name;

                if(staticType==='style'){
                    for(var i=0; i<ultimates.length; i++){
                        if(styleType)
                            requireCssList += 'require("'+ultimates[i]+'");\n';
                        else
                            requireCssList += '@import "'+ultimates[i]+'";\n';
                    }

                    var tmpFile = guid(),
                        tmpDir = config.dist + '/_tmp',
                        tmpCss = config.dist + '/_tmp/'+tmpFile+'.'+ext;

                    if (!fs.existsSync(tmpDir)) {
                        fs.mkdirSync(tmpDir);
                    }

                    fs.writeFileSync( tmpCss , requireCssList) ;

                    entry = {};
                    entry[package_name] = tmpCss;
                    entry['key'] = package_name;
                    entry['value'] = tmpCss;
                }
                else{
                    var tmpkey = Object.keys(entry)[0];
                    var tmpobj = clone(entry[tmpkey]);
                    entry = {};
                    entry[tmpkey] = tmpobj;
                    entry['key'] = package_name;
                    entry['value'] = '';
                }
            }

            //isPack===false
            else{ }

        // }
    }

    return entry;
  }
}
