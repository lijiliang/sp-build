###
# Item.
# @author remiel.
# @module Item
# @example Item
#
###

EventView = require("widgets/eventView/eventView");
ImgView = require("widgets/imgView/imgView");


Item = React.createClass
    getInitialState: ->
        @active = @props['data-active']

        active: @props['data-active']

    componentDidMount: ->

    componentWillReceiveProps: (nextProps) ->
        # console.log 'nextProps'
        # @setState active:@props['data-active']

    componentWillUpdate: (nextProps, nextState) ->
        # console.log 'will update', nextProps, nextState
        @active = nextProps['data-active']



    handleMouseEnter: ->
        # console.log 'enter'
        if typeof @props.onMouseEnterCallback is 'function'
            @props.onMouseEnterCallback.call @, @props['data-index']
        else
            @active = true
            @setState active : true

    render: ->

        cx = React.addons.classSet
        active = ''
        if @active
            active = '_active'
        extClass = if @props.extClass then @props.extClass else ''
        classes = cx(extClass, active);

        style =
            width: @props.width
            height: @props.height
            marginBottom: @props.marginBottom
            marginRight: @props.marginRight

        <EventView
            {...@props}
            onMouseEnter={@handleMouseEnter}
            className={classes}
            style={style}>
            <ImgView src={@props.src} onLoadCallback={@props.onLoadCallback}/>
        </EventView>


module.exports = Item
