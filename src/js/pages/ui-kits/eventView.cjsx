###
# EventView Demo.
###
EventView = require("widgets/eventView/eventView");

console.log 'EventView Demo'

$eventView = $ '#j-event-view'


callback = (index)->
    console.log index
onMouseEnter = ()->
    console.log 'onMouseEnter'

onClick = ()->
    console.log 'onClick'

React.render(
    <EventView
        extClass='ui-remiel'
        callback={callback}
        onMouseEnter={onMouseEnter}
        onClick={onClick}
    >
        EventView Childeren
    </EventView>
    $eventView[0]
);

module.exports = {}
