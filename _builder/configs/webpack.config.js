var fs = require('fs');
var path = require('path');
var webpack = require('webpack');
var alias = require('./webpack.alias.js');
var configs = require('./config');

/**
 * 获取目录结构
 */
var config = configs.dirs;
var pagesDir = fs.readdirSync(config.pages);

var entry = {};

function readPageDir(subDir) {
    var dirs = (subDir && subDir.fs) || pagesDir;
    var dirsPath = (subDir && subDir.path) || config.pages;

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

}

readPageDir();

var plugins = [
    //new webpack.HotModuleReplacementPlugin(),
    new webpack.NoErrorsPlugin(),
    new webpack.IgnorePlugin(/vertx/), // https://github.com/webpack/webpack/issues/353
    new webpack.optimize.CommonsChunkPlugin({
        chunks: entry,
        filename: "_common.js",
        minChunks: 2
            //children: true
            //minChunks: 5 //Infinity
    }),
    new webpack.optimize.DedupePlugin()
    // function() {
    //     this.plugin("done", function(stats) {
    //       fs.writeFileSync(
    //         path.join(__dirname, config.dist + '/js/' + pkg.version + '/' + pkg.config.distName.uncompressed + '/', "map.json"),
    //         JSON.stringify(stats.toJson()));
    //     })
    // }
];

module.exports = {
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
            test: /\.js$/,
            exclude: /node_modules/,
            loader: "babel-loader"
        }, {
            test: /\.css$/,
            loader: "style-loader!css-loader"
        }, {
            test: /\.scss$/,
            loader: "style!css!sass"
        }, {
            test: /\.rt$/,
            loader: "react-templates-loader"
        }]
    },
    resolve: {
        root: path.resolve(__dirname),
        alias: alias,
        extensions: ['', '.js', '.jsx', '.cjsx', '.coffee', '.html', '.css', '.scss', '.hbs', '.rt'],
        modulesDirectories: ["node_modules"],
    }
};
