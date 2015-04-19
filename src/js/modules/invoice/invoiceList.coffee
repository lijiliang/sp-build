# 下拉选择框 SelectBox
define ['Sp','./invoiceList','NewInvoice','Checkbox'], (Sp, invoiceListTpl, NewInvoice, Checkbox)->
    member_id = _SP.member

    #API
    host = Sp.config.host
    #host = 'http://admin.sipin.benny:8000'

    Api =
        getInvoiceList: 'member/invoice'
        deleteInvoice: 'member/invoice/delete'

    Action =
        baseUrl: host + '/api/'
        path: Api
        fn: (res)->
            #console.log res

        getInvoiceList: (id)->
            param = ''
            if id then param = '?member_id=' + id
            Sp.get @baseUrl + @path.getInvoiceList + param, {}, @fn, @fn

        deleteInvoice: (data)->
            Sp.post @baseUrl + @path.deleteInvoice, data, @fn, @fn

    class InvoiceList
        constructor: (options)->
            if !options.el
                #console.log 'el is null'
                return false
            @options = $.extend {}, @defaults, @options, options
            @_init() if !@_invoiceList


        defaults:
            el: null
            member_id: null
            name: name
            callback: (id)->
                #console.log 'defaults.callback ' + 'selected id : ' + id


        _init: ()->
            @$container = $ @options.el
            @_getInvoiceList @options.member_id
            .done (res)=>
                if res.code is 0 then @_renderInvoiceList res.data
            @_invoiceList = @
            @

        #获取列表
        _getInvoiceList: (member_id)->
            Action.getInvoiceList member_id
        _renderInvoiceList: (data)->
            @data = data
            tpl = invoiceListTpl data
            @$container.append tpl
            @_initElements()
            @_bindEvt()

        _initElements: ()->
            @$el = @$container.find '.order-info-address__box'
            @$items = @$el.find '.order-info-address__item'
            @$checkboxs = @$items.find '.order-info-address__checkbox'
            @$delBtn = @$items.find '.j-invoice-del'
            @$updateBtn = @$items.find '.j-invoice-update'

            @createInvoiceBtn = @$el.find '.j-invoice-create'
            @

        _bindEvt: ()->
            _this = @
            @$checkboxs.on 'click', (e)->
                $el = $ @
                $parent = $el.closest '.order-info-address__item'
                _this.$checkboxs.removeClass '_active'

                $el.addClass '_active'
                _this._onCallback $parent.data 'id'

            #del
            @$delBtn.on 'click', (e)->
                $el = $ @
                $parent = $el.closest '.order-info-address__item'
                id = $parent.data 'id'
                Action.deleteInvoice id: id
                .done (res)->
                    $parent.remove()

            #update
            @$updateBtn.on 'click', (e)->
                $el = $ @
                $parent = $el.closest '.order-info-address__item'
                $origin = $parent.children().hide()
                id = $parent.data 'id'
                $.each _this.data, (i,item)->
                    if item.id is id
                        $parent.newInvoice
                            type: 'update'
                            data: item
                            callback: (data)->
                                _this.$container.empty()
                                _this._renderInvoiceList data
                            cancelCallback: ()=>
                                $origin.show()

            #增加新发票btn
            @createInvoiceBtn.on 'click', (e)=>
                @createInvoiceBtn.hide()
                @$container.newInvoice
                    callback: (data)->
                        _this.$container.empty()
                        _this._renderInvoiceList data
                    cancelCallback: ()=>
                        @createInvoiceBtn.show()


            @

        _offEvt: ()->

            @

        _onCallback: (value)->
            @options.callback.call(@$container, value) if typeof @options.callback is 'function'

        _destroy: ()->
            @$el.empty().remove()
            if @options.el._invoiceList
                delete @options.el._invoiceList


    #export to JQ
    $.fn.invoiceList = (options, options2)->
        ret = @
        @each ()->
            if typeof options is 'string' && @_invoiceList
                switch options
                    when 'off' then @_invoiceList._offEvt()
            else
                opts = $.extend {},options,{el: @}
                invoiceList = @_invoiceList
                if !invoiceList
                    invoiceList = new InvoiceList(opts)
                else
                    #@_invoiceList.reset(opts)
                @_invoiceList = invoiceList
        return ret



    Fn = (options)->
        if options.el
            $el = $ options.el
            return $el.each ()->
                opts = $.extend {},options,{el: @}
                invoiceList = @_invoiceList
                if !invoiceList
                    invoiceList = new InvoiceList(opts)
#                else
#                    @_invoiceList.reset(opts)
                @_invoiceList = invoiceList
        else
            Sp.log 'el is null'
            return false

    Fn
