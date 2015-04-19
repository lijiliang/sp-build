# order-list
define ['Sp','Checkbox','CheckAll','SelectBox','ConfirmModalBox'], (Sp, Checkbox, CheckAll, SelectBox, ConfirmModalBox)->


    #API
    host = Sp.config.host

    Api =
        cancelOrder: '/order/cancelOrder'

    Action =
        baseUrl: host + '/api'
        path: Api
        fn: (res)->
            #console.log res

        cancelOrder: (data)->
            Sp.post @baseUrl + @path.cancelOrder, data, @fn, @fn



    Fn = ->

    Fn.init = ->
        initCheckbox $ '.order-list-table'
        initSelectBox()
        #new OrderList()
        initSearch()
        bindEvt()

    initCheckbox = ($el)->
        #多选
        $el.checkAll(
            checkboxClass: '.ui-checkbox'
            callback: (checked, $el)->
                #console.log(checked, $el)
        )
        #单选
        ###$checkbox = $el.find('.ui-checkbox')
        $checkbox.checkbox(
            callback: (checked, $el)->
                #console.log(checked, $el)
                action = if checked then 'on' else 'off'
                $checkbox.checkbox 'off',true
                $el.checkbox action,true
        )###
        #$el.find('.ui-checkbox').hide()
    initSelectBox = ()->
        selectBox = new SelectBox
            el: $ '.ui-select-box'
            callback: (value, text)->
                window.location.href = value

    bindEvt = ()->
        $bd = $ '.cart-table__bd'
        $item = $bd.find '.cart-table__item'
        $cancel = $item.find '.j-order-cancel'
        $delete = $item.find '.j-order-delete'
        $buy = $item.find '.j-order-buy'
        $rebuy = $item.find '.j-order-rebuy'

        $tracking = $item.find '.j-order-tracking'


        $pay = $ '#j-order-pay'
        $go = $ '#j-page-go'
        $number = $ '#j-page-number'

        confirmModalBox = null
        $cancel.on 'click', ()->
            $el = $ @
            $parent = $el.closest '.cart-table__item'
            id = $parent.data 'id'

            confirmModalBox = new ConfirmModalBox
                width: 400
                top: 100
                mask: true
                confirmCallback: ()->
                    Action.cancelOrder
                        order_id: id
                    .done (res)->
                        if res.code is 0
                            window.location.reload()
                closedCallback: ()->
                    console.log 'cancel'
                closeBtn: false
            confirmModalBox.show()



        $pay.on 'click', ()->
            ids = []
            $checkbox = $bd.find '.ui-checkbox'
            $.each $checkbox, ()->
                $el = $ @
                $parent = $el.closest '.cart-table__item'
                id = $parent.data 'id'
                ids.push id if $el.checkbox 'check'

            #TODO
            #提交
            #console.log '合并付款操作, 待完善', ids

        $tracking.hover ()->
            $el = $ @
            $parent = $el.closest '.cart-table__item'
            $log = $parent.find '.order-list-log'
            $log.show()
            $log.offset
                top:  $el.offset().top + 30
        , ()->
            $el = $ @
            $parent = $el.closest '.cart-table__item'
            $log = $parent.find '.order-list-log'
            $log.hide()

        $go.on 'click', ()->
            $el = $ @
        $number.on 'blur', (e)->
            $el = $ @
            value = $el.val()|0
            max = $el.data 'max'
            max = max|0
            if value > max then value = max
            $el.val value

            url = $go.attr 'href'

            reg = /page=([0-9])*/g

            url = url.replace reg, 'page='+value

            $go.attr 'href', url



    initSearch = ()->
        $el = $ '.ui-search'
        $ipt = $el.find '.ui-search__ipt'
        $ipt.on 'focus', (e)->
            $el.addClass '_active'
        .on 'blur', (e)->
            $el.removeClass '_active'








    return  Fn
