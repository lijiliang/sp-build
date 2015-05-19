# cart
define ['Sp','Checkbox','CheckAll','Amount_v2','PlaceSelector','./cart-layout','./cart-empty','LoginModalBox', 'preLoad'], (Sp, Checkbox, CheckAll, Amount_v2, PlaceSelector, cartTpl, cartEmptyTpl, LoginModalBox)->
    Fn = ->

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
            Sp.post @baseUrl + @path.updateSku, data

        deleteSku: (data)->
            Sp.post @baseUrl + @path.deleteSku, data
        submit: (data)->
            Sp.post @baseUrl + @path.submit, data, @fn, @fn

    Fn.init = ()->
        #初始化
        cart = new Cart();

        #登录
        loginBox = null
        $(".main-title .j-login").on "click", (e)->
            console.log 1
            e.preventDefault();
            e.stopPropagation();
            if(!loginBox)
                loginBox = new LoginModalBox
                    width: 440
                    top: 250
                    mask: true
                    closeBtn: true
                    loginSuccessCallback: ()->
                        window.location.reload()
            loginBox.show()
            return false

    initCheckbox = ($el)->
        $el.checkAll(
            checkboxClass: '.ui-checkbox'
            callback: (checked, $el)->
                #console.log(checked, $el)
                $checked = $ '.cart-table__bd .cart-table__col-01'
                    .find '.ui-checkbox input:checked'
                if $checked.length
                    $ '.j-cart-submit'
                        .removeClass '_disable'
                else
                    $ '.j-cart-submit'
                        .addClass '_disable'

        )


    class Cart
        constructor: (options)->
            @getCart()


        getCart: ()->
            Action
                .getCart()
                .done (res)=>
                    if res.code is 0 && res.data.goods.length
                        @renderCart res.data
                    else
                        @renderEmptyCart()
            .fail (res)=>
                    #console.log res
                    @renderEmptyCart()

        deleteSku: (id)->
            if typeof id is 'object'
                _ids = id
                id = JSON.stringify(id)
            postData =
                goods_sku_id: id
            Action
                .deleteSku postData
                .done (res)=>
                    if res.code is 0
                        if _ids
                            $.each _ids, (i, item)->
                                $('#j-sku-id-'+item).remove()
                        else
                            $('#j-sku-id-'+id).remove()
                        if !res.data.goods.length
                            @renderEmptyCart()
                        ###if res.data.goods.length
                            @renderCart res.data
                        else
                            @renderEmptyCart()###
                    else
                        alert('删除失败')

        updateSku: (data)->
            postData = data
            Action
                .updateSku postData
                .done (res)=>
                    if res.code is 0
                        if res.data.goods.length
                            @renderCart res.data
                        else
                            @renderEmptyCart()
                    else
                        #console.log 'error: code='+res.code+' msg='+res.msg

        setCartTotalValue: (sku, price)->
            $ '#j-total-price'
                .html '¥ '+ price
            $ '#j-total-sku'
                .html sku

        checkedSku: ($cartBd)->
            _this = @
            @price = 0
            @quantity = 0
            $checked = $cartBd.find '.cart-table__col-01'
            .find '.ui-checkbox input:checked'
            if $checked.length
                $checked.each (i, item)->
                    $el = $ @
                    $parent = $el.closest '.cart-table__item'
                    # _this.price += +$parent.data 'total-price'
                    # _this.quantity += +$parent.data 'quantity'
                    _this.price = Sp.Calc.Add(_this.price,+$parent.data 'total-price')
                    _this.quantity = Sp.Calc.Add(_this.quantity,+$parent.data 'quantity')
                    _this.setCartTotalValue _this.quantity, _this.price
                $ '.j-cart-submit'
                .removeClass '_disable'
            else
                _this.setCartTotalValue 0,0
                $ '.j-cart-submit'
                .addClass '_disable'


        renderCart: (data)->
            _this = @
            loginBox = null
            $cart = $ '.cart-table'
            tpl = cartTpl data
            $cart.empty().html tpl
            $cartBd = $cart.find '.cart-table__bd'
            #初始化 checkbox
            $cart[0]._checkAll = null
            $cart.checkAll
                checkboxClass: '.ui-checkbox'
                callback: (checked, $el)->
                    #console.log(checked, $el)
                    _this.checkedSku($cartBd)
            @checkedSku($cartBd)
            #初始化 Amount
            $ '.amount-box'
            .amount
                callback: (value)->
                    $el = $ @
                    $el.amount 'off'
                    postData =
                        goods_sku_id: $el.closest('.cart-table__item').data 'sku-id'
                        goods_sku_quantity: value
                    #console.log postData
                    #修改数量
                    _this.updateSku postData
                    .done (res)->
                        #if res.code is 0
                            #if res.data.goods.length
                                #$el.find('input').val value
                                #$el.amount 'on'

            #单个删除
            $cart
                .find '.j-sku-delete'
                .on 'click', ()->
                    $el = $ @
                    id = $el.closest('.cart-table__item').data 'sku-id'
                    _this.deleteSku id
            #删除选中
            $cart
                .find '.j-delete-checked-sku'
                .on 'click', ()->
                    $el = $ @
                    $checked = $cartBd.find '.ui-checkbox input:checked'
                    if $checked.length
                        $el.off 'click'
                        ids = []
                        $checked.each (i, item)->
                            id = $ item
                                .closest('.cart-table__item').data 'sku-id'
                            ids.push id
                        _this.deleteSku ids
            # 地区选择
            placeSelect = new PlaceSelector
                target: "#stock-btn .btn"
                closeBtn: ".close"
            #提交
            $cart
                .find '.j-cart-submit'
                .on 'click', (e)->
                    #console.log 'submit'
                    $el = $ @
                    if $el.hasClass '_disable'
                        return
                    else if !_SP.member
                        #window.location.href = '/member/login'
                        # 登录框
                        if !loginBox
                            loginBox = new LoginModalBox
                                width: 440
                                top: 250
                                mask: true
                                closeBtn: true
                                loginSuccessCallback: (res)->
                                    _this.checkout($cartBd)
                        loginBox.show()
                    else
                        _this.checkout($cartBd)

        checkout: ($cartBd)->
            $checked = $cartBd.find '.ui-checkbox input:checked'
            ids = []

            $form = $ '<form action="/checkout" method="POST"></form>'

            $ipt = $ '<input type="hidden" name="goods_sku">'
            $form.append $ipt

            $checked.each (i, item)->
                id = $ item
                .closest('.cart-table__item').data 'sku-id'
                ids.push id

            #Action.submit goods_sku: JSON.stringify ids
            $ipt.val JSON.stringify ids
            $form.appendTo 'body'
            $form.submit()


        renderEmptyCart: ()->
            tpl = cartEmptyTpl {}
            $ '.cart-table'
                .html tpl


    Fn.init()
