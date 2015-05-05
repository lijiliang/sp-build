###
# HoverList.
# @author remiel.
# @module HoverList
# @example HoverList
#   js:
#   React.createElement(HoverList, {
#       extClass: class
#       layout: 'vertical',
#       imgs: [imgs],
#       speed: 500,
#       callback: fn
#   }, document.getElementById('id'))
#
#   jsx:
#   <HoverList layout imgs speed callback></HoverList>
#
# @param options {Object} the slider options
# @option extClass {String} add a class to the wrapper for style
# @option layout {String} direction of the layout
# @option imgs {Array} the img array
# @option speed {Number} the speed in slider
# @option callback {Function} callback when the item hover
# @callback
#
###

List = require("./list");


HoverList = React.createClass
    propTypes:
        extClass:  React.PropTypes.string
        layout:  React.PropTypes.string
        imgs:  React.PropTypes.array
        speed:  React.PropTypes.number
        callback:  React.PropTypes.func


    getInitialState: ->
        # console.log 'getInitialState~', @props

        timer = null
        $(window).on "resize.HoverList", () =>
            clearTimeout timer if timer isnt null
            setTimeout @_initSize, 500

        {}

    componentDidMount: ->
        # console.log 'componentDidMount~'
        @_initSize()

    #
    # componentWillMount: () ->
    #     # console.log 'componentWillMount~'
    #
    # componentWillReceiveProps: (nextProps) ->
    #     # console.log 'componentWillReceiveProps~'
    #     # console.log nextProps
    #
    # shouldComponentUpdate: (nextProps, nextState) ->
    #     # console.log 'shouldComponentUpdate~'
    #     # console.log nextProps, nextState
    #     true
    #
    # componentWillUpdate: (nextProps, nextState) ->
    #     # console.log 'componentWillUpdate~'
    #     # console.log nextProps, nextState
    #
    # componentDidUpdate: (prevProps, prevState) ->
    #     # console.log 'componentDidUpdate~'
    #     # console.log prevProps, prevState

    handleMouseEnter: (e) ->
        e.stopPropagation()
        e.preventDefault()

        el = e.target || e.srcElement
        $el = $ el
        $el = $el.closest '.ui-slider-list__item' if !$el.hasClass 'ui-slider-list__item'
        index = $el.attr 'data-index'

        $inner = $ @refs.inner.getDOMNode()
        $inner.find '._active'
        .removeClass '_active'

        $el.addClass '_active'

        callback = @props.callback
        callback.call @, index, @props.imgs if typeof callback is 'function'



    handlePrev: (e)->
        @_move e, 'prev'

    handleNext: (e)->
        @_move e, 'next'

    _move: (e, dir)->
        # console.log 'click', dir
        el = e.target || e.srcElement
        $el = $ el
        return 1 if $el.hasClass '_disabled'

        $prev = $ @refs.prev.getDOMNode()
        $next = $ @refs.next.getDOMNode()

        # ul = @refs.ul.getDOMNode()
        # $ul = $ ul

        $wrapper = $ @refs.wrapper.getDOMNode()
        $ul = $wrapper.find '.ui-slider-list__ul'
        $inner = $ul.find '.ui-slider-list__ul-inner'
        $item = $ul.find '.ui-slider-list__item'

        length = $item.length

        # TODO
        # transform3D
        switch @props.layout
            when 'vertical'

                ulHeight = $ul.height()
                innerHeight = $inner.height()
                itemHeight = $item.eq(0).outerHeight()

                if ulHeight >= innerHeight
                    $prev.addClass '_disabled'
                    $next.addClass '_disabled'
                    return 1

                offset = $inner.css 'marginTop'
                offset = if offset is 'auto' then 0 else parseInt offset, 10
                marginTop = $item.eq(0).css 'marginTop'
                marginTop = parseInt marginTop, 10
                marginBottom = $item.eq(0).css 'marginBottom'
                marginBottom = parseInt marginBottom, 10

                itemOffset = itemHeight + marginTop + marginBottom

                switch dir
                    when 'prev'
                        offset = offset + itemOffset

                        if offset > 0
                            offset = 0
                            $prev.addClass '_disabled'

                        $next.removeClass '_disabled'

                    when 'next'
                        offset = offset - itemOffset
                        if -offset + ulHeight > innerHeight
                            offset = ulHeight - innerHeight
                            $next.addClass '_disabled'

                        $prev.removeClass '_disabled'

                animate = marginTop: offset

            when 'horizontal'

                ulWidth = $ul.width()
                innerWidth = $inner.width()
                itemWidth = $item.eq(0).outerWidth()

                if ulWidth >= innerWidth
                    $prev.addClass '_disabled'
                    $next.addClass '_disabled'
                    return 1

                offset = $inner.css 'marginLeft'
                offset = if offset is 'auto' then 0 else parseInt offset, 10
                marginLeft = $item.eq(0).css 'marginLeft'
                marginLeft = parseInt marginLeft, 10
                marginRight = $item.eq(0).css 'marginRight'
                marginRight = parseInt marginRight, 10
                itemOffset = itemWidth + marginLeft + marginRight


                if -offset + ulWidth > innerWidth
                    offset = ulWidth - innerWidth
                    $el.addClass '_disabled'

                switch dir
                    when 'prev'
                        offset = offset + itemOffset

                        if offset > 0
                            offset = 0
                            $prev.addClass '_disabled'

                        $next.removeClass '_disabled'

                    when 'next'
                        offset = offset - itemOffset

                        if -offset + ulWidth > innerWidth
                            offset = ulWidth - innerWidth
                            $next.addClass '_disabled'

                        $prev.removeClass '_disabled'
                animate = marginLeft: offset

        $inner.stop().animate animate, @props.speed || 200

    _initSize: () ->
        # console.log '_initSize~~'

        #
        # $win = $ window
        # winWidth = $win.width()
        #
        # if winWidth < @props.small
        #     console.log 'small'

        #
        $wrapper = $ @refs.wrapper.getDOMNode()
        height = $wrapper.height()
        width = $wrapper.width()

        $prev = $ @refs.prev.getDOMNode()
        $next = $ @refs.next.getDOMNode()

        $prev.removeClass '_disabled'
        $next.removeClass '_disabled'

        # ul = @refs.ul.getDOMNode()
        # $ul = $ ul
        $ul = $wrapper.find '.ui-slider-list__ul'
        $inner = $ul.find '.ui-slider-list__ul-inner'
        $item = $ul.find '.ui-slider-list__item'

        length = $item.length



        switch @props.layout
            when 'vertical'
                #fixed horizontal to vertical
                $ul.height ''
                $inner.height ''
                $item.outerHeight ''
                $inner.css 'marginLeft',''

                $ul.width width
                $inner.width width
                $item.outerWidth width

                $img = $item.eq(0).find 'img'
                if !$img[0].complete
                    $img[0].onload = =>
                        @_initSize()
                    return 1
                ulHeight = $ul.height()
                innerHeight = $inner.height()

                # console.log 'ulHeight >= innerHeight',ulHeight,innerHeight
                if ulHeight >= innerHeight
                    $prev.addClass '_disabled'
                    $next.addClass '_disabled'

                offset = $inner.css 'marginTop'

            when 'horizontal'

                #fixed vertical to horizontal
                $ul.width ''
                $inner.width ''
                $item.outerWidth ''
                $inner.css 'marginTop',''

                $ul.height height
                $inner.height height
                $item.outerHeight height

                $img = $item.eq(0).find 'img'
                if !$img[0].complete
                    $img[0].onload = =>
                        @_initSize()
                    return 1
                itemWidth = $item.eq(0).outerWidth()

                marginLeft = $item.eq(0).css 'marginLeft'
                marginLeft = parseInt marginLeft, 10
                marginRight = $item.eq(0).css 'marginRight'
                marginRight = parseInt marginRight, 10

                itemOffset = itemWidth + marginLeft + marginRight

                $inner.width itemOffset*length

                ulWidth = $ul.width()
                innerWidth = $inner.width()
                if ulWidth >= innerWidth
                    $prev.addClass '_disabled'
                    $next.addClass '_disabled'

                offset = $inner.css 'marginLeft'

        offset = parseInt offset, 10
        $prev.addClass '_disabled' if offset >= 0


    _imgList: (item, i)->
        item = item + @props.imgParam if @props.imgParam
        <EventView extClass="ui-slider-list__item" key={i} onMouseEnter={@handleMouseEnter} data-index={i}>
            <img src={item} />
        </EventView>

    handleTest: (e) ->
      # body...
      console.log e

    render: ->
        # console.log 'render~'
        cx = React.addons.classSet
        layoutClass = '_'+@props.layout
        extClass = if @props.extClass then @props.extClass else ''
        classes = cx('ui-slider-list', layoutClass, extClass);

        imgList = (@_imgList img,i for img, i in @props.imgs)

        # <div ref="wrapper" className={classes}>
        #     <div
        #     ref="prev"
        #     className="ui-slider-list__prev u-text-center"
        #     onClick={@handlePrev}></div>
        #     <div className="ui-slider-list__ul" ref="ul">
        #         <div className="ui-slider-list__ul-inner u-clearfix" ref="inner">
        #             {imgList}
        #         </div>
        #     </div>
        #     <div
        #     ref="next"
        #     className="ui-slider-list__next u-text-center"
        #     onClick={@handleNext}></div>
        # </div>

        <div ref="wrapper" className={classes}>
            <div
            ref="prev"
            className="ui-slider-list__prev u-text-center"
            onClick={@handlePrev}></div>
                <List {...@props} />
            <div
            ref="next"
            className="ui-slider-list__next u-text-center"
            onClick={@handleNext}></div>
        </div>



module.exports = List
