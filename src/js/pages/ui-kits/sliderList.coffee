###
# SliderList Demo.
###
SliderList = require("modules/sliderList/sliderList");

console.log 'SliderList Demo'

$sliderList = $ '#j-slider-list'
.append '<div>'
.append '<div>'

imgs = [
        'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/2964d272_pic_show01.jpg'
        'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/beb60bfa_pic_show02.jpg'
        'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/cadf9ec6_pic_show04.jpg'
        'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/2964d272_pic_show01.jpg'
        'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/beb60bfa_pic_show02.jpg'
        'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/cadf9ec6_pic_show04.jpg'
        'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/2964d272_pic_show01.jpg'
        'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/beb60bfa_pic_show02.jpg'
        'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/cadf9ec6_pic_show04.jpg'
        'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/2964d272_pic_show01.jpg'
        'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/beb60bfa_pic_show02.jpg'
        'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/cadf9ec6_pic_show04.jpg'
        'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/2964d272_pic_show01.jpg'
        'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/beb60bfa_pic_show02.jpg'
        'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/cadf9ec6_pic_show04.jpg'
        'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/2964d272_pic_show01.jpg'
        'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/beb60bfa_pic_show02.jpg'
        'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/cadf9ec6_pic_show04.jpg'
]

React.render(
    React.createElement(SliderList,
        extClass: 'ui-remiel'
        layout: 'vertical',
        imgs: imgs
        speed: 100
        callback: (index, imgs)->
            console.log index
    ),
    $sliderList.children()[0]
);
React.render(
    React.createElement(SliderList,
        layout: 'horizontal'
        imgs: imgs
        speed: 200
        callback: (index, imgs)->
            console.log index
    ),
    $sliderList.children()[1]
);

module.exports = {}
