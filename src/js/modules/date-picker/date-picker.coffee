# DatePicker
define ['./tpl-date-picker'], (tpl)->
    #console.log 'widget [DatePicker] loaded'
    Fn = (options)->
        @options = $.extend {}, @defaults, options
        @_init() if @options.el
        return @

    Fn.prototype =
        defaults:
            name: 'DatePicker'
            el: null
            initDate: new Date()
            delay: 0
            lastDate: 30
            time:
                am: "9:00-12:00"
                pm: "14:00-18:00"
            disabled:
                "1970-01-01":
                    "am": 0
                    "pm": 1
            shortDayNames: ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
            callback: (date, time)->
                #console.log date, time

        _init: ()->
            @_initDates()
            @_initElements()
            @_bindEvt()
            @_render @initDate, @options.delay
            @$el.attr '_datePicker_init',1
            return @$el

        _initDates: ()->
            @initDate = @_parse @_format new Date @options.initDate
            @firstDate = @_ahead @initDate, @options.delay, 0
            @lastDate = @_ahead @initDate, @options.delay + @options.lastDate, 0


        _initElements: ()->
            @$el = $(@options.el)
            @_createElements()
            @$prev = @$datePicker.find '.ui-date-picker__prev'
            @$next = @$datePicker.find '.ui-date-picker__next'
            return @$el


        _createElements: ()->
            @$datePicker = $ '<div class="ui-date-picker"></div>'
            hd = [
                '<div class="ui-date-picker__hd">'
                '<a class="ui-date-picker__prev" href="javascript:;">上一周</a>'
                '<div class="ui-date-picker__title">可选时间表</div>'
                '<a class="ui-date-picker__next" href="javascript:;">下一周</a>'
                '</div>'
                ].join ''
            @$bd = $ '<div class="ui-date-picker__bd"></div>'


            _offset = @$el.offset()
            _height = @$el.outerHeight()
            _offset.top += _height-1
            @$datePicker
                .append hd
                .append @$bd
                .appendTo $ 'body'
                .offset _offset
                .hide()
            return @$el

        _setDates: (date, days)->
            @startDate = @_ahead date, days, 0
            _dates = []
            _generate = (i)=>
                date = @_ahead @startDate, i, 0
                fomateDate = @_format date
                type = if date.valueOf() > @lastDate.valueOf() then 1 else 0
                _obj =
                    date: fomateDate
                    day: @options.shortDayNames[date.getDay()]
                    am: @options.time.am
                    pm: @options.time.pm
                    #text: if type then '不可选' else '可选'
                    text: '可选'
                if type
                    _obj.disabled = 1
                else
                    if @options.disabled[fomateDate]
                        _obj.disabledAM = 1 if @options.disabled[fomateDate].am
                        _obj.disabledPM = 1 if @options.disabled[fomateDate].pm
                _dates.push _obj

            _generate i for i in [0..6]

            if @startDate.valueOf() is @firstDate.valueOf()
                @$prev.addClass '_disabled'
            else
                @$prev.removeClass '_disabled'

            if @startDate.valueOf() > (@_ahead @lastDate, -6, 0).valueOf()
                @$next.addClass '_disabled'
            else
                @$next.removeClass '_disabled'

            _dates

        _render: (date, days)->
            _dates = @_setDates date, days
            _data =
                dates: _dates
                time: @options.time
            html = tpl _data
            @$bd
                .empty()
                .html html


        _bindEvt: ()->
            _this = @
            @$el
                .on 'click.' + @options.name, (e)->
                    $(@).blur()
                    _this.$datePicker.toggle()
                .on 'focus.' + @options.name, (e)->
                    $(@).blur()

            #checkbox event
            @$datePicker.on 'click.' + @options.name, '.ui-date-picker__checkbox', ()->
                $this = $ @
                if $this.hasClass '_disabled'
                    return false
                else
                    _this.$datePicker
                        .hide()
                        .find '.ui-date-picker__checkbox'
                        .removeClass '_active'
                    $this.addClass '_active'
                    _date = $this.attr '_date'
                    _dateObj = _this._parse _date
                    _time = $this.attr '_time'
                    _this.$el.val _date + ' ' + _time
                    _this.currentDate =
                        date: _dateObj
                        time: _time
                    _this.options.callback.call(@, _date, _time, _dateObj) if typeof _this.options.callback is 'function'

            #prev week & next week
            @$prev.on 'click.'+@options.name, ()=>
                if @$prev.hasClass '_disabled'
                    return false
                else
                    @_render @startDate, -7
            @$next.on 'click.'+@options.name, ()=>
                if @$next.hasClass '_disabled'
                    return false
                else
                    @_render @startDate, 7

            #hide it when click
            @$datePicker.on 'click.' + @options.name, (e)->
                e.stopPropagation()
            $ document
                .on 'click.' + @options.name, (e)->
                    if e.target.id isnt _this.$el[0].id
                        _this.$datePicker.hide()

            return @$el

        _ahead: (date, days, months)->
            return new Date(
                date.getFullYear()
                date.getMonth() + months
                date.getDate() + days
            )

        _parse: (s)->
            if m = s.match /^(\d{4,4})-(\d{2,2})-(\d{2,2})$/
                return new Date m[1], m[2] - 1, m[3]
            else
                return null

        _format: (date)->
            month = (date.getMonth() + 1).toString()
            dom = date.getDate().toString()
            if month.length is 1
                month = '0' + month
            if dom.length is 1
                dom = '0' + dom
            return date.getFullYear() + '-' + month + "-" + dom

        show: ()->
            @$datePicker.show()

        hide: ()->
            @$datePicker.hide()

        toggle: ()->
            @$datePicker.toggle()

        reset: (options)->
            @options = $.extend {}, @options, options
            @_initDates()
            @_render @initDate, @options.delay

        getCurrentDate: ()->
            @currentDate


            #export to JQ
    $.fn.datePicker = (options, options2)->
        ret = @
        @each ()->
            if typeof options is 'string' && @_datePicker
                switch options
                    when 'getCurrentDate' then ret = @_datePicker.getCurrentDate()
                    when 'show' then @_datePicker.show()
                    when 'hide' then @_datePicker.hide()
                    when 'toggle' then @_datePicker.toggle()
                    when 'reset' then @_datePicker.reset(options2)
            else
                opts = $.extend {},options,{el: @}
                datePicker = @_datePicker
                if !datePicker
                    datePicker = new Fn(opts)
                else
                    @_datePicker.reset(opts)
                @_datePicker = datePicker
        return ret

    return  Fn
