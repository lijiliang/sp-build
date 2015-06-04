# path = require 'path';
# config = require '../configs/config.coffee';
#
# module.exports = (gulp,$)->
#     return () ->
#         require('../configs/webpack.config.js').build(path.join(__dirname,'../..', './src/css/modules'),true,{
#             type: 'sass',
#             rename: 'common',
#             prepend: [path.join(__dirname,'../..',config.modulesCssDir+'_settings/_setting.scss')]
#         });



path = require 'path';
config = require '../configs/config.coffee';

module.exports = (gulp,$)->
    return () ->
        require('../configs/webpack.config.js').build(config.modulesCssDir,true,{
            type: 'sass',
            rename: 'common',
            prepend: [path.join(config.modulesCssDir+'/_settings/_setting.scss')]
        });
