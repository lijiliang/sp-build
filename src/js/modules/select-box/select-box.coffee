# 下拉选择框 SelectBox
define ['Sp','DropDown'], (Sp, DropDown)->
    name = 'SelectBox'
    $dropDownBoxs = $()
    class SelectBox extends DropDown
        constructor: (options)->
            if !options.el
                #console.log 'el is null'
                return false
            else
                options.target = options.el
                options.render = ()=>
                    # @dropDownBox 是首次点击才生成的
                    $dropDownBoxs = $dropDownBoxs.add @dropDownBox
                    @$container.appendTo @dropDownBox.find '.ui-drop-down-box__inner'
            super
            @options = $.extend {}, @defaults, @options, options
            @_init() if !@_selectBox


        defaults:
            el: null
            name: name
            callback: (value, text)->
                #console.log 'defaults.callback.' + 'value:' + value +  ', text:' + text


        _init: ()->
            @_initElements()
            @_bindEvt()
            @_selectBox = @
            @

        _initElements: ()->
            @$el = $ @options.el
            @_createElements()
            @$options = @$el.find '.ui-options'
            $active = @$el.find '._active'
            $active = @$options.eq(0).addClass '_active' if !$active.length
            @$container
                .css
                    minWidth: @$el.outerWidth() - 2
            @$options
                .appendTo @$container
            @_setValue $active
            @

        _createElements: ()->
            @$container = $ '<div class="ui-options-box"></div>'
            @$ipt = $ '<input type="hidden">'
                .attr 'name', @$el.attr '_name'
                .appendTo @$el
            @$value = $ '<span></span>'
                .appendTo @$el
            @


        _setValue: ($active)->
            @text = $active.html()
            @value = $active.attr '_value'
            @$ipt.val @value
            @$value.html @text
            @


        _render: ()->
            Sp.log '_renderHtml'
            @



        _bindEvt: ()->
            _this = @
            @$container.on 'click.' + @options.name, '.ui-options', ()->
                _this.hide()
                $active = $ @
                if $active.hasClass '_active'
                    return false
                else
                    _this.$options.removeClass '_active'
                    $active.addClass '_active'
                    _this._setValue $active
                    _this.options.callback.call(@, _this.value, _this.text) if typeof _this.options.callback is 'function'

            @$container
                .add @$el
                .on 'click.' + @options.name, (e)->
                    e.stopPropagation()

            @




        show: ()->
            super
            @

        hide: ()->
            if @dropDownBox
                @dropDownBox.hide()
            # super
            @

    #hide $dropDownBoxs when click
    $ document
        .on 'click.' + name, (e)->
            $dropDownBoxs.hide()

    #export to JQ
    $.fn.selectBox = (options, options2)->
        ret = @
        @each ()->
            if typeof options is 'string' && @_selectBox
                switch options
                    when 'show' then @_selectBox.show()
                    when 'hide' then @_selectBox.hide()
                    when 'toggle' then @_selectBox.toggle()
                    when 'reset' then @_selectBox.reset(options2)
            else
                opts = $.extend {},options,{el: @}
                selectBox = @_selectBox
                if !selectBox
                    selectBox = new SelectBox(opts)
                else
                    @_selectBox.reset(opts)
                @_selectBox = selectBox
        return ret



    Fn = (options)->
        if options.el
            $el = $ options.el
            return $el.each ()->
                opts = $.extend {},options,{el: @}
                selectBox = @_selectBox
                if !selectBox
                    selectBox = new SelectBox(opts)
#                else
#                    @_selectBox.reset(opts)
                @_selectBox = selectBox
        else
            Sy.log 'el is null'
            return false

    Fn
