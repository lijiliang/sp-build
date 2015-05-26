var fs = require('fs');
var path = require('path');
var webpack = require('webpack');
// var alias = require('./webpack.alias.js');
// var configs = require('./config');

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
  var common_name = "_common.js";
  if(dirname !== 'pages')
    common_name = "_normal.js";

  var
  ret_plugins = [
      //new webpack.HotModuleReplacementPlugin(),
      new webpack.NoErrorsPlugin(),
      new webpack.IgnorePlugin(/vertx/) // https://github.com/webpack/webpack/issues/353
  ];

  if(dirname !== 'nocommon'){
    ret_plugins.push(
      new webpack.optimize.CommonsChunkPlugin({
          chunks: entry,
          filename: common_name,
          minChunks: 2
              //children: true
              //minChunks: 5 //Infinity
      })
    );

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
      }, {
          test: /\.js$/,
          exclude: /node_modules/,
          loader: "babel-loader",
          query:{ compact: 'auto' }
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

// module.exports = {

var kkk = function(dirname,isPack){
    var idf_plugins = plugins(dirname);

    if( getObjType(isPack)==='Object'){
        entry = isPack;
        idf_plugins = plugins('nocommon');
    }

    return {
        //cache: true,
        //debug: true,
        devtool: "source-map",
        recursive: true,
        entry: {},
        output: {
            path: path.join(__dirname,'/dist/dev/js/'),
            publicPath: '/dev/js/',
            filename: '[name].js',
        },
        plugins: idf_plugins,
        module: custom_modules(),
        resolve: {
            root: path.resolve(__dirname),
            extensions: ['', '.js', '.jsx', '.cjsx', '.coffee', '.html', '.css', '.scss', '.hbs', '.rt','.md'],
            modulesDirectories: ["node_modules"],
        }
    };
}

var testcommon = {
    common: [ '/home/yc/code/git/sp-build/src/js/vendor/jquery/dist/jquery.js',
  '/home/yc/code/git/sp-build/src/js/vendor/react/react-with-addons.js',
  '/home/yc/code/git/sp-build/src/js/global/libs.js',
  '/home/yc/code/git/sp-build/src/js/global/core.js',
  '/home/yc/code/git/sp-build/src/js/global/toolkits.js',
  './dist/1.0.0/dev/js/_common.js' ]
}

// module.exports = kkk(null,testcommon);
webpack(kkk(null,testcommon)).run(function(err,stats){
  return;
});
