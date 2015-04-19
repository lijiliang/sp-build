###
# SliderList Demo.
###
SliderList = require("modules/sliderList/sliderList");

console.log 'SliderList Demo'

$sliderList = $ '#j-slider-list'
.append '<div>'
.append '<div>'

imgs = [
    'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/6dd58a8f_B3-WLF-CJ004.jpg'
    'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/6dd58a8f_B3-WLF-CJ004.jpg'
    'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/6dd58a8f_B3-WLF-CJ004.jpg'
    'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/6dd58a8f_B3-WLF-CJ004.jpg'
    'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/6dd58a8f_B3-WLF-CJ004.jpg'
    'http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/6dd58a8f_B3-WLF-CJ004.jpg'
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