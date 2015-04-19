# 商品详情页面逻辑
define ['Sp','NewAddress','DatePicker','EditOrderInfoModalBox','LightModalBox','ConfirmModalBox'], (Sp,NewAddress, DatePicker, EditOrderInfoModalBox, LightModalBox, ConfirmModalBox)->

    #API
    host = Sp.config.host

    Api =
        updateOrderDelivery: '/order/updateOrderDelivery'
        cancelOrder: '/order/cancelOrder'

    Action =
        baseUrl: host + '/api'
        path: Api
        fn: (res)->
            #console.log res

        updateOrderDelivery: (data)->
            Sp.post @baseUrl + @path.updateOrderDelivery, data, @fn, @fn
        cancelOrder: (data)->
            Sp.post @baseUrl + @path.cancelOrder, data, @fn, @fn



    orderData = {}
    initData = null
    init_reserve_delivery_time = $('#j-predict-date').val()
    init_reserve_delivery_time = init_reserve_delivery_time.split(' ')[0]

    page = ->

    # 初始化页面
    page.init = ->
        order = null
        $edit = $ "#j-edit-order"
        $cancel = $ "#j-cancel-order"
        $print = $ "#j-print-order"
        setOrderData()
        if $edit.length
            $edit.on "click", =>
                order = new Order() if !order
                order.showWin()
        if $cancel.length
            confirmModalBox = null
            $cancel.on "click", =>
                if initData.id && !$cancel.hasClass '_disable'
                    if !confirmModalBox
                        confirmModalBox = new ConfirmModalBox
                            width: 400
                            top: 100
                            mask: true
                            confirmCallback: ()->
                                $cancel.addClass '_disable'
                                modal = new LightModalBox
                                    text: '正在取消订单'
                                    status: ''
                                modal.show()
                                Action.cancelOrder order_id: initData.id
                                .done (res)->
                                    if res.code == 0
                                        modal = new LightModalBox
                                            text: '取消订单成功'
                                            status: ''
                                        modal.show()
                                        reloadPage()
                            closedCallback: ()->
                                console.log 'cancel'
                            closeBtn: false
                    confirmModalBox.show()

        if $print.length && window.print
                $print.on "click", =>
                    window.print()




    setOrderData = ()->
        $el = $ '#j-order-json'
        initData = JSON.parse $el.val()
        #orderData.delivery_id = initData.delivery_id
        orderData.order_id = initData.id

    reloadPage = ()->
        setTimeout ()->
            window.location.reload()
        , 1000


    #order
    class Order
        constructor: (options)->
            @options = $.extend {}, @defaults, options
            @_setOrderData()
            @_initElements()
            @

        defaults:
            name: 'Order'

        _initElements: ()->

        _bindEvt: ()->



        _setOrderData: ()->
            $el = $ '#j-order-json'
            data = JSON.parse $el.val()
            if !data.id then return false
            @data = data
            delivery = @data.delivery
            @address = delivery.member_address
            @date =
                reserve_delivery_time: delivery.reserve_delivery_time.split(' ')[0]
                reserve_installation_time: delivery.reserve_installation_time.split(' ')[0]
            orderData = $.extend orderData, @date
            orderData.member_address_id = delivery.member_address_id
            orderData.delivery_id = @data.delivery_id

        showWin: ()->
            if !@editOrderInfoModalBox
                @editOrderInfoModalBox = new EditOrderInfoModalBox
                    top: 20
                    mask: true
                    closeBtn: true

                @editOrderInfoModalBox.show()
                @afterInitModal()
            else
                @editOrderInfoModalBox.show()
                #@newAddress.

        afterInitModal: ()->
            _this = @
            @$address = $ '.j-order-address-modified'
            @$save = $ '.j-order-save'
            @$address.newAddress
                data: @address
                type: 'updateOrder'
                order_id: @data.id
                saveSuccessThenDestroy: false
                validateFalseCallback: ()->
                    _this.$save.show().siblings().hide()
                callback: (data)->
                    orderData.member_address_id = data.id
                    Action.updateOrderDelivery orderData
                    .done (res)->
                        if res.code == 0
                            modal = new LightModalBox
                                text: '修改成功'
                                status: 'success'
                            modal.show()
                            reloadPage()
                        else
                            modal = new LightModalBox
                                text: '出错'
                                status: 'error'
                            modal.show()
                            _this.$save.show().siblings().hide()
                    .fail (res)->
                        _this.editOrderInfoModalBox.close()
                        modal = new LightModalBox
                            text: '出错'
                            status: 'error'
                        modal.show()
                        _this.$save.show().siblings().hide()


                cancelCallback: ()=>
            @newAddress = @$address[0]._newAddress
            @$save.on 'click', ()=>
                @$save.hide().parent().append '<div>正在保存...</div>'
                @newAddress.save()
            @initDatePicker()

        initDatePicker: ()->
            _this = @
            @$date = $ '.j-order-info-date'
            $deliver = @$date.find '#j-date-deliver'
            $install = @$date.find '#j-date-install'

            #console.log @date
            reserve_delivery_time = @date.reserve_delivery_time
            reserve_installation_time = @date.reserve_installation_time



            $install.on 'focus', ()->
                $(@).blur()

            if reserve_delivery_time is '0000-00-00'
                reserve_delivery_time = init_reserve_delivery_time
                orderData.reserve_delivery_time = ''
                orderData.reserve_installation_time = ''
            else
                $deliver.val reserve_delivery_time
                $install.val reserve_installation_time
                $install.datePicker(
                    parent: _this.editOrderInfoModalBox.modal
                    initDate: Sp.date.parse reserve_delivery_time
                    delay: 0
                    callback: (date)->
                        orderData.reserve_installation_time = date
                )

            $deliver.datePicker(
                parent: _this.editOrderInfoModalBox.modal
                initDate: Sp.date.parse init_reserve_delivery_time
                delay: 0
                callback: (date)->
                    disabled = {}
                    #dateObj = Sp.date.parse date
                    #newDate = Sp.date.ahead dateObj, 1, 0
                    #newDateString = Sp.date.format newDate
                    #$install.val newDateString
                    $install.val date
                    $install.off 'focus'
                    $install.datePicker(
                        parent: _this.editOrderInfoModalBox.modal
                        initDate: date
                        delay: 0
                        disabled: disabled
                        callback: (date)->
                            orderData.reserve_installation_time = date
                    )

                    orderData.reserve_delivery_time = date
                    orderData.reserve_installation_time = date
            )

    return  page
