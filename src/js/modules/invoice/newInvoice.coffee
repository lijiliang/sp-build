# 下拉选择框 SelectBox
define ['Sp','./newInvoice','Validator','Checkbox'], (Sp, newInvoiceTpl, Validator,Checkbox)->
    name = 'newInvoice'

    #API
    host = Sp.config.host
    #host = 'http://admin.sipin.benny:8000'

    Api =
        createInvoice: 'member/invoice/create'
        updateInvoice: 'member/invoice/update'

    Action =
        baseUrl: host + '/api/'
        path: Api
        fn: (res)->
            #console.log res

        createInvoice: (data)->
            Sp.post @baseUrl + @path.createInvoice, data, @fn, @fn

        updateInvoice: (data)->
            Sp.post @baseUrl + @path.updateInvoice, data, @fn, @fn

    class NewInvoice
        constructor: (options)->
            if !options.el
                #console.log 'el is null'
                return false
            @options = $.extend {}, @defaults, @options, options
            @_init() #if !@_newInvoice


        defaults:
            el: null
            name: name
            type: 'create' # 'create','update'
            data: {}
            successTpl: '<span class="form-success-tips u-ml_5 iconfont u-color_green">&#xe615;</span>'
            callback: (value)->
                #console.log 'defaults.callback ' + 'value: ' + value
            cancelCallback: ()->
                #console.log 'defaults.callback cancel'


        _init: ()->
            #console.log 1231231323
            @_initElements()
            @_initValue() if @options.type is 'create'
            if @options.type is 'create' || @options.data.title_type is 0
                @$invoice_company_name.hide()
            @_bindEvt()
            @_newInvoice = @
            @

        _initElements: ()->
            @$container = $ @options.el
            tpl = newInvoiceTpl @options.data
            @$container.append tpl
            @$el = @$container.find '.order-cart-table__options-bd'

            @$save = @$el.find '.j-invoice-save'
            @$cancel = @$el.find '.j-invoice-cancel'

            @$checkbox = @$el.find '.ui-checkbox'

            @$invoice_company_name = @$el.find '.invoice_company_name'
            @$formIpts = @$el.find '.form-text'
            @$formIptsRequired = @$el.find '.form-text._required'
            @$formIptsNotRequired = @$el.find('.form-text').not '._required'

            @

        _initValue: ()->
            @options.data.title_type = 0


        _rules: ()->
            rules =
                invoice_company_name:[
                    filter: 'required'
                    msg: '不能为空'
                ]

        _validate: (val, filters)->
            @validator = new Validator if !@validator
            ret = [true]
            isRequired = false
            if filters && filters.length
                for item in filters
                    isRequired = true if item.filter is 'required'
                    ret[0] = @validator.methods[item.filter] val
                    if !ret[0]
                        ret[1] = item.msg
                        break
            if !isRequired and val is ''
                ret = [true]
            ret

        _iptValidate: (el, filters)->
            _this = @
            ret = true
            $el = $ el
            value = $el.val()
            $parent = $el.parent()
            $error = $parent.find '.error'
            $success = $parent.find '.form-success-tips'
            if !$error.length
                $parent.append '<span class="error u-color_red u-ml_10"></span>'
                $error = $parent.find '.error'
            validation = @_validate value, filters[$el.attr 'name']
            if !validation[0]
                $success.remove()
                $error.html validation[1]
                ret = false
            else
                $error.remove()
                $parent.append @options.successTpl if !$success.length and value isnt ''
            ret

        _othersValidate: (el, value, filters)->

        _bindEvt: ()->
            _this = @
            @$formIpts
            .on 'blur', (e)->
                _this._iptValidate @, _this._rules()
#            @$formIptsRequired
#            .on 'blur', (e)->
#                _this._iptValidate @, _this._rules()
#            @$formIptsNotRequired
#            .on 'blur', (e)->
#                if @value isnt ''
#                    _this._iptValidate @, _this._rules()
#                else
#                    $ @
            @$checkbox.checkbox
                callback: (value, $el)->
                    _this.$checkbox.siblings().not(_this.$checkbox).not(_this.$invoice_company_name).remove()
                    $parent = $el.closest '.form-field'
                    $.each _this.$checkbox, (i, item)->
                        if item == $el[0]
                            $(item).checkbox 'on', true
                        else
                            $(item).checkbox 'off', true
                    if $el.attr('_name') is 'invoice_company'
                        _this.$invoice_company_name.show().focus()
                        _this.options.data.title_type = 1
                    else
                        _this.$invoice_company_name.hide()
                        _this.options.data.title_type = 0

            @$invoice_company_name.on 'blur', (e)->
                _this._iptValidate @, _this._rules()



            @$save.on 'click', ()->
                success = true
                if _this.options.data.title_type
                    _this.$invoice_company_name.each (i, item)->
                        if !_this._iptValidate item, _this._rules()
                            success = false
                        @
                #console.log success
                if success
                    postData = $.extend _this.options.data,
                        member_id:  _SP.member,
                        type: 0,
                        title_type: _this.options.data.title_type,
                        content_type: 0,
                        company_name: _this.$invoice_company_name.val()
                    if !_this.options.data.title_type then postData.company_name = ''
                    if _this.options.type is 'create'
                        action = 'createInvoice'
                    else
                        action = 'updateInvoice'
                        postData.id = _this.options.data.id

                    Action[action](postData)
                    .done (res)->
                        if res.code is 0
                            _this._destroy()
                            _this._onCallback res.data
            #取消
            @$cancel.on 'click', ()=>
                _this._destroy()
                _this._onCallback null,'cancel'


            @

        _offEvt: ()->

            @

        _onCallback: (value, type)->
            switch type
                when 'cancel' then @options.cancelCallback.call(@$container) if typeof @options.cancelCallback is 'function'
                else @options.callback.call(@$container, value) if typeof @options.callback is 'function'

        _destroy: ()->
            @$el.empty().remove()
            if @options.el._newInvoice
                delete @options.el._newInvoice


    #export to JQ
    $.fn.newInvoice = (options, options2)->
        ret = @
        @each ()->
            if typeof options is 'string' && @_newInvoice
                switch options
                    when 'off' then @_newInvoice._offEvt()
            else
                opts = $.extend {},options,{el: @}
                newInvoice = @_newInvoice
                if !newInvoice
                    newInvoice = new NewInvoice(opts)
                else
                    #@_newInvoice.reset(opts)
                @_newInvoice = newInvoice
        return ret



    Fn = (options)->
        if options.el
            $el = $ options.el
            return $el.each ()->
                opts = $.extend {},options,{el: @}
                newInvoice = @_newInvoice
                if !newInvoice
                    newInvoice = new NewInvoice(opts)
#                else
#                    @_newInvoice.reset(opts)
                @_newInvoice = newInvoice
        else
            Sp.log 'el is null'
            return false

    Fn
