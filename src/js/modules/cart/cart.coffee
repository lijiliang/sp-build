# 下拉选择框 SelectBox
define ['Sp','./cart','./cartEmpty','LightModalBox'], (Sp, cartTpl, cartEmptyTpl, LightModalBox)->
    name = 'cart'

    #API
    host = Sp.config.host + '/api/'
    #host = 'http://admin.sipin.benny:8000/api/'
    Api =
        getCart: 'cart'
        addGoods: 'cart/add'
        updateSku: 'cart/update'
        deleteSku: 'cart/delete'
        emptyCart: 'cart/empty',
        submit: 'checkout'

    Action =
        baseUrl: host
        path: Api
        fn: (res)->
            #console.log res
        getCart: ()->
            Sp.get @baseUrl + @path.getCart, null, @fn, @fn

        emptyCart: ()->
            Sp.post @baseUrl + @path.emptyCart

        updateSku: (data)->
            Sp.post @baseUrl + @path.updateSku, data, @fn, @fn

        deleteSku: (data)->
            Sp.post @baseUrl + @path.deleteSku, data, @fn, @fn
        submit: (data)->
            Sp.post @baseUrl + @path.submit, data, @fn, @fn



    showMsg = (text, status)->
        modal = new LightModalBox
            text: text
            status: status
            closedCallback: ()->
                $('#' + modal.id).remove()
                modal = null
        modal.show()

    class Cart
        constructor: (options)->
            if !options.el
                #console.log 'el is null'
                return false
            @options = $.extend {}, @defaults, @options, options
            @_init() if !@_cart
            @


        defaults:
            el: null
            member_id: _SP.member
            name: name
            callback: (value)->
                #console.log 'defaults.callback ' + 'value: ' + value


        _init: ()->
            @$el = $ @options.el
            @$container = @$el.parent()
            @$content = @$container.find '.header-cart__content'
            @shouldUpdate = 1
            @_renderEmptyCart()
            @$container.hover ()=>
                @_getCart()
            @_cart = @
            Sp.Cart = @
            @

        #获取列表
        _renderCart: (data)->
            _this = @
            @data = data
            if  data.goods.length
                tpl = cartTpl data
                @$content.html tpl
                @_initElements()
                @_bindEvt()
            else
                @_renderEmptyCart()
        _renderEmptyCart: ()->
            tpl = cartEmptyTpl {}
            @$content.html tpl

        _getCart: ()->
            if  !@data or @shouldUpdate
                @shouldUpdate = 0
                @getCartPromise = Action
                .getCart()
                .done (res)=>
                    if res.code is 0
                        @_renderCart res.data
                    else
                        @_renderEmptyCart()
                .fail (res)=>
                    @_renderEmptyCart()
            else
                @_renderCart @data


        _deleteSku: (id)->
            postData =
                goods_sku_id: id
            Action
            .deleteSku postData
            .done (res)=>
                if res.code is 0
                    @_renderCart res.data
                    showMsg '删除成功', 'success'
                else
                    showMsg '删除失败', 'error'


        _initElements: ()->
            @$item = @$container.find '.header-cart__item'
            @$del = @$item.find '.header-cart__item-del'
            @

        _bindEvt: ()->
            _this = @
            @$del.on 'click', (e)->
                $el = $ @
                id = $el.data 'sku-id'
                _this._deleteSku id
            @

        _offEvt: ()->

            @

        _onCallback: (value)->
            @options.callback.call(@$container, value) if typeof @options.callback is 'function'

        _destroy: ()->
            @$el.empty().remove()
            if @options.el._cart
                delete @options.el._cart

        setShouldUpdate: ()->
            #console.log 'cart will update'
            @shouldUpdate = 1


    #export to JQ
    $.fn.cart = (options, options2)->
        ret = @
        @each ()->
            if typeof options is 'string' && @_cart
                switch options
                    when 'off' then @_cart._offEvt()
                    when 'setShouldUpdate' then @_cart.setShouldUpdate()
            else
                opts = $.extend {},options,{el: @}
                cart = @_cart
                if !cart
                    cart = new Cart(opts)
                else
                    #@_cart.reset(opts)
                @_cart = cart
        return ret



    Fn = (options)->
        if options.el
            $el = $ options.el
            return $el.each ()->
                opts = $.extend {},options,{el: @}
                cart = @_cart
                if !cart
                    cart = new Cart(opts)
#                else
#                    @_cart.reset(opts)
                @_cart = cart
        else
            Sp.log 'el is null'
            return false

    Fn
