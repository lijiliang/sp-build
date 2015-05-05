###
# HoverList.
# @author remiel.
# @module HoverList
# @example HoverList
#   js:
#   React.createElement(HoverList, {
#       extClass: class
#       layout: 'vertical/horizontal',
#       imgs: [imgs],
#       imgParam: '?imageView2/1/w/200'
#       height:50
#       width:(50+10)*6-10
#       margin: 10
#       callback: fn
#   }, document.getElementById('id'))
#
#   jsx:
#   <HoverList extClass layout imgs imgParam height width margin callback></HoverList>
#
# @param options {Object} the slider options
# @option extClass {String} add a class to the wrapper for style
# @option layout {String} direction of the layout
# @option imgParam {String}
# @option imgs {Array} the img array
# @option height {Number}
# @option width {Number}
# @option margin {Number}
# @option callback {Function} callback when the item hover
# @callback
#
###

Item = require("./item");

List = React.createClass

    getInitialState: ->
        activeIndex: 0


    componentDidMount: ->


    onLoadCallback: (img) ->
        # console.log img,img.height,img.width

    handleMouseEnterCallback: (index) ->
        # console.log index, 'handleMouseEnterCallback', @
        @setState activeIndex: index

        callback.call @, index, @props.imgs if typeof callback is 'function'

    # handleMouseEnter: (e) ->
    #     console.log 'onMouseEnter'
    #     e.stopPropagation()
    #     e.preventDefault()
    #
    #     el = e.target || e.srcElement
    #     $el = $ el
    #     $el = $el.closest '.ui-list-view__item' if !$el.hasClass 'ui-slider-list__item'
    #     index = $el.attr 'data-index'
    #
    #     $inner = $ @refs.inner.getDOMNode()
    #     $inner.find '._active'
    #     .removeClass '_active'
    #
    #     $el.addClass '_active'
    #
    #     callback = @props.callback
    #     callback.call @, index, @props.imgs if typeof callback is 'function'

    _imgList: (item, i)->
        src = item + @props.imgParam if @props.imgParam
        props = {}
        switch @props.layout
            when 'vertical'
                props.width = @props.width
                props.marginBottom = @props.margin
            when 'horizontal'
                props.height = @props.height
                props.marginRight = @props.margin

        <Item
            extClass="ui-list-view__item"
            src={src}
            key={i}
            {...props}
            onMouseEnter={@handleMouseEnter}
            onMouseEnterCallback={@handleMouseEnterCallback}
            onLoadCallback={@onLoadCallback}
            data-active={@state.activeIndex is i}
            data-index={i}/>

    # _initSize: () ->
    #
    #     list = React.refs.list.getDOMNode()
    #     $list = $ list
        # if @props.visible
        #     switch @props.layout
        #         when 'vertical' then $list.height @props.width * visible
        #         when 'horizontal' then $list.width @props.height * visible


    render: ->

        cx = React.addons.classSet
        layoutClass = '_'+@props.layout
        extClass = if @props.extClass then @props.extClass else ''
        classes = cx('ui-list-view', layoutClass, extClass);

        style =
            width: @props.width
            height: @props.height

        list = (@_imgList img,i for img, i in @props.imgs)


        <div className={classes} ref="list" style={style}>
            <div className="ui-list-view__inner u-clearfix" ref="inner">
                {list}
            </div>
        </div>

module.exports = List
