# DatePicker
define ['./tpl_datePicker_v2'], (tpl)->
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
            parent: 'body'
            disabled:
                "1970-01-01": 1
            shortDayNames: ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
            callback: (date)->
                #console.log date

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

            $parent = $ @options.parent
            @$datePicker
                .append hd
                .append @$bd
                .appendTo $parent
                .offset _offset
                .hide()
            return @$el

        _setOffset: ()->
            _offset = @$el.offset()
            _height = @$el.outerHeight()
            _offset.top += _height-1
            @$datePicker.offset _offset



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
                    text: if type then '不可选' else '可选'
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
                    _this._setOffset()
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
                    _this.$el.val _date
                    _this.currentDate =
                        date: _dateObj
                    _this.options.callback.call(@, _date) if typeof _this.options.callback is 'function'

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
