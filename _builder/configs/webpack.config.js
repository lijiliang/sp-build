var fs = require('fs');
var path = require('path');
var gulp = require('gulp');
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
        if ( fs.statSync(dirsPath + '/' + item).isDirectory() && item.indexOf('_')!=0) {
            //获取目录里的脚本合并
            var data = {
                name: item,
                path: dirsPath + '/' + item,
                fs: fs.readdirSync(dirsPath + '/' + item),
                filename: (subDir && subDir.filename + "-" + item) || item
            };
            readPageDir(data);
        }

        else {
            var ext = path.extname(dirsPath + '/' + item);
            if (ext == ".coffee" || ext == ".js" || ext == ".cjsx" ||
                ext == ".jsx" || ext == ".scss" || ext == ".less" ||
                ext == ".css" || ext == "stylus") {
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
        // var tmp_entry = {};
        // var tmp_ary = Object.keys(entry);
        // for(var i=0; i<tmp_ary.length; i++){
        //     entry[i]
        // }
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
          test: /[\/\\]src[\/\\]js[\/\\](vendor|global)[\/\\]/,   //http://stackoverflow.com/questions/28969861/managing-jquery-plugin-dependency-in-webpack
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
          // loader: ExtractTextPlugin.extract('style-loader',"css!less")
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

      if(getObjType(dirname)==='String'){
          entry = this.readDir(dirname,isPack,options);
      }

      else if( getObjType(isPack)==='Object'){
          entry = $extend(true,{},isPack);
          if(entry.noCommon) {
              delete entry.noCommon;
              idf_plugins = plugins('noCommon');
          }
          else {
              delete entry.noCommon;
              idf_plugins = plugins(entry);
      } }

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

      if(getObjType(isPack)==='Function'){
          cb = isPack;
          isPack = undefined;
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
          type = (options && options.type) ? options.type : undefined,
          _webpackDevCompiler,
          _webpackDevConfig = this.create(dirname,isPack,options);

      if(entry){
          if(entry.key){
              tmpKey = clone(entry.key);
              tmpValue = clone(entry.value);
              delete entry.key;
              delete entry.value;
          }

          if(type && (type==='sass' || type==='scss')){
              //gulp deal with style
              if(isPack===true){

                  gulp.src([tmpValue])
                  .pipe($.newer(path.join(__dirname,'../../', config.dist + '/' + configs.version + '/dev/css/') + tmpKey +'.css'))
                  .pipe($.plumber())
                  // .pipe $.rimraf()
                  .pipe($.sass())
                  .pipe($.autoprefixer('last 2 version'))
                  .pipe($.size())
                  .pipe($.rename(tmpKey + ".css"))
                  .pipe(gulp.dest(path.join(__dirname,'../../', config.dist + '/' + configs.version + '/dev/css/')))
              }
          }else{
              //if webpack sass-loader has fixed , then can use this module,
              //node: edit fllow some code;
              _webpackDevCompiler = webpack(_webpackDevConfig);
              _webpackDevCompiler.run(function(err, stats){
                  if(err){
                      throw new gutil.PluginError('[webpack]', err) ;
                  }
                  gutil.log('[webpack]', stats.toString({ colors: true } )) ;
                  if(cb) cb();
                  return;
              });
          }
      }

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

      var prepend,
          append,
          requireCssList = '',
          rename = opts.rename ? opts.rename : undefined,
          type = opts.type ? opts.type : undefined;

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
              pagesDir = fs.readdirSync(dirname);
              package_name = isPack === true ? path.basename(dirname) : '';
      } }

      //生成entry 全局
      readPageDir(null, isPack, opts.depth);

      if(entry){
        if(type==='less' || type==='sass'|| type==='stylus'|| type==='css'|| type==='scss'){
            if(isPack){
                var ultimates = [];

                if(type=='less' ||type==='stylus' ||type==='css'){
                    /* for webpack
                    * but webpack sass-loader has problem,so maybe use it later
                    */
                    for(var item in entry){
                        package_name = item;
                        prepend = (opts.prepend && getObjType(opts.prepend)==='Array') ? opts.prepend : undefined,
                        append = (opts.append && getObjType(opts.append)==='Array') ? opts.append : undefined;
                        if(prepend){
                            ultimates = prepend.concat(entry[item]);
                        }
                        else if(append){
                            ultimates = entry[item].concat(append);
                        }
                        else{
                            ultimates = entry[item];
                        }

                        for(var i=0; i<ultimates.length; i++)
                            requireCssList += 'require("'+ultimates[i]+'");\n';
                    }
                    var tmpFile = guid(),
                        tmpDir = config.dist + '/_tmp',
                        tmpCss = config.dist + '/_tmp/'+tmpFile+'.js';

                    if (!fs.existsSync(tmpDir)) {
                        fs.mkdirSync(tmpDir);
                    }
                    fs.writeFileSync( tmpCss , requireCssList) ;

                    package_name = rename ? rename : package_name;
                    entry = {};
                    entry[package_name] = tmpCss;
                    // package_ary = tmpCss;
                    entry['key'] = package_name;
                    entry['value'] = tmpCss;
                }
                else{
                    /* for gulp
                    *  now gulp can parse it no error
                    */
                    for(var item in entry){
                        package_name = item;
                        prepend = (opts.prepend && getObjType(opts.prepend)==='Array') ? opts.prepend : undefined,
                        append = (opts.append && getObjType(opts.append)==='Array') ? opts.append : undefined;
                        if(prepend){
                            ultimates = prepend.concat(entry[item]);
                        }
                        else if(append){
                            ultimates = entry[item].concat(append);
                        }
                        else{
                            ultimates = entry[item];
                        }

                        for(var i=0; i<ultimates.length; i++)
                            requireCssList += '@import "'+ultimates[i]+'";\n';
                    }
                    var tmpFile = guid(),
                        tmpDir = config.dist + '/_tmp',
                        tmpCss = config.dist + '/_tmp/'+tmpFile+'.'+type;

                    if (!fs.existsSync(tmpDir)) {
                        fs.mkdirSync(tmpDir);
                    }
                    fs.writeFileSync( tmpCss , requireCssList) ;

                    package_name = rename ? rename : package_name;
                    entry = {};
                    entry[package_name] = tmpCss;
                    // package_ary = tmpCss;
                    entry['key'] = package_name;
                    entry['value'] = tmpCss;
                }
            }
            else{

            }
            // var tmpCss = config.dirs.src + '/css/_tmp.'+js;
            // fs.writeFileSync( tmpCss , requireCssList) ;
    } }

    return entry;
  }
}
