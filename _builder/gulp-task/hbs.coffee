config = require '../configs/config.coffee'

opts =
    type: 'hbs'
    data:
        'aaa':
              'title': '好好学习'
              'des': '就是这样的好好学习就好了'
        'index':
              'title': "天天向上"
              'des': "必须要有这种精神才行阿！"

module.exports = (gulp,$)->
    return () ->
        require('../configs/webpack.config.js').build(config.dirs.src + '/hbs/',opts);
