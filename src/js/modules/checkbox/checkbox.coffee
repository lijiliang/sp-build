# checkbox
define ()->
    Checkbox = (options)->
        @options = $.extend {}, @defaults, options
        @_init() if !($(@options.el).attr('_init')) if @options.el
        return @

    Checkbox.prototype =
        defaults:
            el: null
            callback: ()->

        _init: ()->
            @_initElements()
            @_bindEvt()
            @$el.attr('_init',1)
            return @$el

        _initElements: ()->
            @$el = $(@options.el)
            if @$el.attr('_checked') is "true"
                @checked = yes
            else
                @checked = no
            @$el.addClass '_active' if @checked
            @_createElements()
            return @$el


        _createElements: ()->
            @$ipt = $('<input type="checkbox" style="display: none;">')
            @$ipt[0].name = @$el.attr('_name') if @$el.attr('_name')
            @$ipt[0].checked = true if @checked
            @$ipt.appendTo @$el
            return @$el

        _bindEvt: ()->
            @$el.on 'click.checkbox', $.proxy @_toggle, @
            return @$el

        _toggle: (e)->
            #@$el.toggleClass '_active'
            if @checked then @$el.removeClass '_active' else @$el.addClass '_active'
            @$el.attr('_checked',!(@checked))
            @$ipt[0].checked = !(@checked)
            @checked = !(@checked)
            @options.callback.call(@, @checked, @$el) if typeof @options.callback is 'function' && !@withoutCallback
            return @$el

        on: (withoutCallback)->
            @withoutCallback = withoutCallback
            @checked = false
            @_toggle()
            @withoutCallback = 0

        off: (withoutCallback)->
            @withoutCallback = withoutCallback
            @checked = true
            @_toggle()
            @withoutCallback =0

        check: ()->
            @checked



    #export to JQ
    $.fn.checkbox = (options, withoutCallback)->
        ret = @
        @each ()->
            if typeof options is 'string' && @_checkbox
                switch options
                    when 'on' then @_checkbox.on(withoutCallback)
                    when 'off' then @_checkbox.off(withoutCallback)
                    when 'check' then ret = @_checkbox.check()
            else
                opts = $.extend {},options,{el: @}
                checkbox = @_checkbox
                checkbox = new Checkbox(opts) if !checkbox
                @_checkbox = checkbox
        return ret

    return  Checkbox
