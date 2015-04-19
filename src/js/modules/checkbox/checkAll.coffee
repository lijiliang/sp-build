# checkbox
define ['Checkbox'], (Checkbox)->
    Fn = (options)->
        @options = $.extend {}, @defaults, options
        @_init() if @options.el
        return @

    Fn.prototype =
        defaults:
            el: null
            checkboxClass: '.j-checkbox-check-self'
            checkAllClass: '.j-checkbox-check-all'
            callback: ()->

        _init: ()->
            @_initElements()
            @_bindEvt()
            @$el.attr('_init_checkAll',1)
            return @$el

        _initElements: ()->
            @$el = $(@options.el)
            @$checkbox = @$el.find(@options.checkboxClass).not @options.checkAllClass
            @$checkAll = @$el.find @options.checkAllClass
            return @$el

        _bindEvt: ()->
            _ = @
            @$checkbox.checkbox(
                callback: (checked, $el)->
                    allChecked = yes
                    _.$checkbox.each ()->
                        if !($(@).checkbox 'check')
                            allChecked = no
                    status = if allChecked then 'on' else 'off'
                    _.$checkAll.checkbox status, 1
                    _.options.callback.call(@, checked, $el) if typeof _.options.callback is 'function'
            )
            @$checkAll.checkbox(
                callback: (checked, $el)->
                    status = if checked then 'on' else 'off'
                    _.$checkbox.checkbox status, 1
                    _.$checkAll.checkbox status, 1
                    _.options.callback.call(@, checked, $el) if typeof _.options.callback is 'function'
            )
            return @$el


    #export to JQ
    $.fn.checkAll = (options)->
        ret = @
        @each ()->
            opts = $.extend {},options,{el: @}
            checkAll = @_checkAll
            checkAll = new Fn(opts) if !checkAll
            @_checkAll= checkAll
        return ret

    return Fn
