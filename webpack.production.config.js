var fs = require('fs');
var path = require('path');
var webpack = require('webpack');
var alias = require('./webpack.alias.js');
var configs = require('./config');

var config = configs.dirs;

var entry = {};
var entryArr = [];

/**
 * 遍历Modules目录取入口文件
 * 如果有index.coffee，则直接取index.coffee有入口文件
 * 没有则直接取目录内文件遍历打包
 */
var modulesDir = fs.readdirSync(config.pages);
modulesDir.forEach(function(item) {
    //只取目录
    if (fs.statSync(config.pages + '/' + item).isDirectory()) {
        var modulesDirPath = config.pages + '/' + item
        // 如果不存在入口文件
        if( !fs.existsSync(modulesDirPath+'/index.coffee') &&!fs.existsSync(modulesDirPath+'/index.cjsx') && !fs.existsSync(modulesDirPath+'/index.js') ){
            var modulesFilesArr = [];
            var modulesFiles = fs.readdirSync(modulesDirPath);
            // 取里面的所有文件打包
            modulesFiles.forEach(function(item){
                var ext = path.extname(modulesDirPath + '/'+item);
                // 只取js、coffee文件
                if( fs.statSync(modulesDirPath + '/'+item).isFile() && ( ext==".js" ||ext==".cjsx" || ext=='.coffee' ) ){
                    modulesFilesArr.push(modulesDirPath + '/'+item);
                }
            });
            // 取于入口文件，忽略空目录
            if(modulesFilesArr.length){
                //modulesFilesArr.push(config.modules+'/commonPage/index');  // 兼容旧项目的commonPage.js
                entry[item] = modulesFilesArr;
                entryArr.push(item);
            }
        }else{
            //entry[item] = [config.pages + '/' + item + '/index',config.modules+'/commonPage/index'];
            entry[item] = [config.pages + '/' + item + '/index'];
            entryArr.push(item);
        }
    }
});

var plugins = [
    new webpack.optimize.CommonsChunkPlugin( {
        chunks: entry,
        filename: "_common.min.js",
        minChunks: 2
        //minChunks: 5 //Infinity
    }),
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.UglifyJsPlugin({
            compress: {
                warnings: false
            }
        })
];

module.exports = {
    //cache: true,
    //debug: true,
    devtool: "source-map",
    recursive: true,
    entry: entry,
    output: {
        path: path.join( __dirname, config.dist + '/' + configs.version + '/js/'),
        publicPath: '/' + configs.version + '/js/',
        filename: configs.hash ? '[name]_[hash].js' : '[name].js'
    },
    externals: {
        "jquery": "jQuery",
        "$": "jQuery",
        "React": "React"
    },
    plugins: plugins,
    module: {
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
            test: /\.css$/,
            loader: "style-loader!css-loader"
        }, {
            test: /\.scss$/,
            loader: 'style!css!sass'
        }]
    },
    resolve: {
        root:  path.resolve(__dirname),
        alias: alias,
        extensions: ['', '.js', '.jsx', '.cjsx', '.coffee', '.html', '.css', '.scss', '.hbs'],
        modulesDirectories: ["node_modules"],
    }
};
