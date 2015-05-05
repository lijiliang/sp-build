###
# HoverList Demo.
###
HoverList = require("modules/hoverList/list");

console.log 'HoverListView Demo'

$hoverList = $ '#j-hover-list'
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
    React.createElement(HoverList,
        extClass: 'ui-remiel'
        layout: 'vertical',
        imgs: imgs
        imgParam: '?imageView2/1/w/200'
        speed: 100
        width:100
        height:200+20
        margin: 20
        callback: (index, imgs)->
            console.log index
    ),
    $hoverList.children()[0]
);
React.render(
    React.createElement(HoverList,
        layout: 'horizontal'
        imgs: imgs
        imgParam: '?imageView2/1/w/200'
        speed: 200
        height:50
        width:(50+10)*6-10
        margin: 10
        callback: (index, imgs)->
            console.log index
    ),
    $hoverList.children()[1]
);

module.exports = {}
