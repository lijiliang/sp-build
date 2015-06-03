# cb是个神奇的东东，居然不能去掉，什么bug
# 我知道为嘛了，问我阿 295560757 微信
module.exports = (gulp,$)->
    return (cb) ->
        require('../configs/webpack.config.js').build('pages',cb);
