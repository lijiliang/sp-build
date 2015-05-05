###
# ImgView Demo.
###
ImgView = require("widgets/imgView/imgView");

console.log 'ImgView Demo'

$container = $ '#j-img-view'


onLoadCallback = (img)->
    console.log 'onLoadCallback', img.width, img.height
    console.log @props
onMouseEnter = ()->
    console.log 'onMouseEnter'

onClick = ()->
    console.log 'onClick'

React.render(
    <ImgView
        src='http://7viii7.com2.z0.glb.qiniucdn.com/2015/02/09/2964d272_pic_show01.jpg?imageView2/1/h/80/w/80'
        extClass='ui-remiel1'
        onLoadCallback={onLoadCallback}
        onClick={onClick}
    ></ImgView>
    $container[0]
);

module.exports = {}
