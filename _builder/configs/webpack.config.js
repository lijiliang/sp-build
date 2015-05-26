var fs = require('fs');
var path = require('path');
var webpack = require('webpack');
var alias = require('./webpack.alias.js');
var configs = require('./config');
var $extend = require('extend')

function getObjType(object){
    return Object.prototype.toString.call(object).match(/^\[object\s(.*)\]$/)[1];
};

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
config,
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


function readPageDir(subDir,isPack) {
    var dirs = (subDir && subDir.fs) || pagesDir;
    // var dirsPath = (subDir && subDir.path) || config.pages;
    var dirsPath = (subDir && subDir.path) || default_dir;

    var sameName = false;
    dirs.forEach(function(item) {

        var _filename = (subDir && subDir.filename) || item;
        var name = (subDir && subDir.name) || item;


        //如果是目录
        if (fs.statSync(dirsPath + '/' + item).isDirectory()) {
            //获取目录里的脚本合并

            // 忽略test目录
            if (item !== "_test") {

                var data = {
                    name: item,
                    path: dirsPath + '/' + item,
                    fs: fs.readdirSync(dirsPath + '/' + item),
                    filename: (subDir && subDir.filename + "-" + item) || item
                };

                readPageDir(data);
            }

        } else {
            var ext = path.extname(dirsPath + '/' + item);
            if (ext == ".coffee" || ext == ".js" || ext == ".cjsx" || ext == ".jsx") {

                // 如果存在同名js
                if (!sameName) {
                    if (name == item.replace(ext, '')) {
                        entry[_filename] = [dirsPath + '/' + item];
                        sameName = true;
                    } else {
                        entry[_filename] = entry[_filename] || [];
                        entry[_filename].push(dirsPath + '/' + item);
                    }
                }

            }

        }

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

// readPageDir();
//
// var plugins = [
//     //new webpack.HotModuleReplacementPlugin(),
//     new webpack.NoErrorsPlugin(),
//     new webpack.IgnorePlugin(/vertx/), // https://github.com/webpack/webpack/issues/353
//     new webpack.optimize.CommonsChunkPlugin({
//         chunks: entry,
//         filename: "_common.js",
//         minChunks: 2
//             //children: true
//             //minChunks: 5 //Infinity
//     }),
//     new webpack.optimize.DedupePlugin()
//     // function() {
//     //     this.plugin("done", function(stats) {
//     //       fs.writeFileSync(
//     //         path.join(__dirname, config.dist + '/js/' + pkg.version + '/' + pkg.config.distName.uncompressed + '/', "map.json"),
//     //         JSON.stringify(stats.toJson()));
//     //     })
//     // }
// ];


var plugins = function(dirname){
  var
  venders;
  common_name = "_common.js",
  min_Chunks = 2,
  common_trunk_config = {
      // chunks: entry,
      filename: common_name,
      minChunks: min_Chunks
      //children: true
      //minChunks: 5 //Infinity
  }

  var
  ret_plugins = [
      //new webpack.HotModuleReplacementPlugin(),
      new webpack.NoErrorsPlugin(),
      new webpack.IgnorePlugin(/vertx/) // https://github.com/webpack/webpack/issues/353
  ];

  if(getObjType(dirname)==='String' && dirname !== 'pages')
      common_trunk_config.filename = "_normal.js";

  if(getObjType(dirname)==='Object'){
      venders = dirname;
      common_trunk_config.minChunks = "Infinity";
  }

  //commonstrunk plugin
  if(dirname !== 'noCommon'){
    if(venders && getObjType(venders)==='Object'){
      for(var v in venders){
        (function(item){
          var vs = venders;
          ret_plugins.push(
            // new webpack.optimize.CommonsChunkPlugin(item+'.js',vs[item],'Infinity')
            new webpack.optimize.CommonsChunkPlugin(item,item+'.js','Infinity')
          );
        })(v)
      }
    }
    else{
      ret_plugins.push(
        new webpack.optimize.CommonsChunkPlugin(common_trunk_config)
      );
    }

    ret_plugins.push(
      new webpack.optimize.DedupePlugin()
      // function() {
      //     this.plugin("done", function(stats) {
      //       fs.writeFileSync(
      //         path.join(__dirname, config.dist + '/js/' + pkg.version + '/' + pkg.config.distName.uncompressed + '/', "map.json"),
      //         JSON.stringify(stats.toJson()));
      //     })
      // }
    )
  }
  return ret_plugins;
}

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
      },
      // {
      //     test: /\.js$/,
      //     exclude: /node_modules/,
      //     loader: "babel-loader",
      //     query:{ compact: 'auto' }
      // },
      {
          test: /[\/\\]src[\/\\]js[\/\\](vendor|global)[\/\\]/,   //http://stackoverflow.com/questions/28969861/managing-jquery-plugin-dependency-in-webpack
          loader: "script-loader"   //不做任何处理
      }, {
          test: /\.css$/,
          loader: "style-loader!css-loader"
      }, {
          test: /\.scss$/,
          loader: "style!css!sass"
      }, {
          test: /\.rt$/,
          loader: "react-templates-loader"
      },{
          test: /\.md$/,
          loader: "html!markdown"
      }]
  }
}

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
module.exports = function(dirname,isPack){
    var idf_plugins = plugins(dirname);
    var idf_externals = custom_externals;

    config = configs.dirs;
    if(getObjType(dirname)==='String'){
        for(var item in config){
            if(item == dirname){
                pagesDir = fs.readdirSync(config[item]);
                default_dir = config[item];
            }
        }
        if(!pagesDir){
            throw new Error("Error: you must identify a entry");
            return false;
        }
        package_name = isPack === true ? dirname : '';
        readPageDir(null,isPack);
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
        }
    }

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
            extensions: ['', '.js', '.jsx', '.cjsx', '.coffee', '.html', '.css', '.scss', '.hbs', '.rt','.md'],
            modulesDirectories: ["node_modules"],
        }
    };
}
