###
# EventView.
# @author remiel.
# @module EventView
# @example EventView
#
#   jsx:
#   <EventView extClass callback></EventView>
#
# @param options {Object} the options
# @option extClass {String} add a class to the wrapper for style
#
###

EventView = React.createClass
    propTypes:
        extClass:  React.PropTypes.string

    getInitialState: ->
        # console.log 'getInitialState~', @props
        {}

    componentDidMount: ->
        # console.log 'componentDidMount~'

    render: ->
        # console.log 'render~'
        cx = React.addons.classSet
        extClass = if @props.extClass then @props.extClass else ''
        classes = cx('ui-event-view', extClass);

        <div
            className={classes}
            {...this.props}
        >
            {@props.children}
        </div>

module.exports = EventView
