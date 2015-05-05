var src_dir = './src';
var global_dir = './src/js/global';
var path = require('path');
module.exports = {
    name: "斯品家居",
    version: "1.0.0",
    description: "斯品家居的前端项目",
    dirs: {
        src: src_dir,
        dist: "./dist",
        pages: src_dir + "/js/pages",
        modules: src_dir + "/js/modules",
        widgets: src_dir + "/js/widgets",
        global: src_dir + "/js/global",
        vendor: src_dir + "/js/vendor"
    },
    hash: false,
    vendorList: [
        path.join(__dirname, src_dir, '/js/vendor/jquery/dist/jquery.js'),
        path.join(__dirname, src_dir, '/js/vendor/react/react-with-addons.js')
    ],
    globalList: [
        path.join(__dirname, src_dir, '/js/global/libs.js'),
        path.join(__dirname, src_dir, '/js/global/core.js'),
        path.join(__dirname, src_dir, '/js/global/toolkits.js')
    ],
    ieRequireList: [
        path.join(__dirname, src_dir, '/js/vendor/console-shim/console-shim.js'),
        path.join(__dirname, src_dir, '/js/vendor/html5shiv/dist/html5shiv.js'),
        path.join(__dirname, src_dir, '/js/vendor/respond/dest/respond.js'),
        path.join(__dirname, src_dir, '/js/vendor/es5-shim/es5-shim.js'),
        path.join(__dirname, src_dir, '/js/vendor/es5-shim/es5-sham.js'),
        path.join(__dirname, src_dir, '/js/vendor/json2/json2.js')
    ]
};
