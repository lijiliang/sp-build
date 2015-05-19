# order-list
define ['Sp','Checkbox','CheckAll','SelectBox','ConfirmModalBox', 'AlertModalBox', 'preLoad'], (Sp, Checkbox, CheckAll, SelectBox, ConfirmModalBox, AlertModalBox)->


    #API
    host = Sp.config.host

    Api =
        cancelOrder: '/order/cancelOrder'
        deleteOrder: '/order/deleteOrder'

    Action =
        baseUrl: host + '/api'
        path: Api
        fn: (res)->
            #console.log res

        cancelOrder: (data)->
            Sp.post @baseUrl + @path.cancelOrder, data, @fn, @fn
        deleteOrder: (data)->
            Sp.post @baseUrl + @path.deleteOrder, data, @fn, @fn



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
                getQuery = ()->
                    ret = {}
                    seg = location.search.replace(/^\?/,'').split('&')
                    for item in seg
                        if !item
                            continue; 
                        s = item.split '=';
                        ret[s[0]] = s[1];
                    
                    return ret

                path = location.pathname
                params = getQuery()
                    
                # 算时间
                now = new Date().getTime()
                half_year = 1000 * 60 * 60 * 24 * 182.5
                times = 
                    'half_year': half_year
                    'one_year': half_year * 2

                begin_at_type = $('#j-select-time input').val()
                status_id = $('#j-select-status input').val()

                if begin_at_type != 'all'
                    params.begin_at_type = begin_at_type #Sp.date.format(new Date(now - times[begin_at]))
                else 
                    delete params.begin_at_type
                if status_id != 'all'
                    params.status_id = status_id
                else 
                    delete params.status_id

                params = $.param params
                
                path += '?' + params
                console.log('filter path: ', path)
                location.href = path

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


        $item.on 'click', '.j-order-delete', ()->
            $this = $ @
            $item = $this.closest '.cart-table__item'
            id = $item.data 'id'

            confirmModalBox = new ConfirmModalBox
                width: 400
                top: 100
                mask: true
                confirmCallback: ()->
                    Action.deleteOrder
                        order_id: id
                    .done (res)->
                        if res.code is 0
                            $item.remove()
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

            if !ids.length
                alertModal = new AlertModalBox
                    content: '您未选择需要合并付款的订单！'
                return false

            #提交, melo说用form post提交，这里用js触发页面的form
            $('#j-order-pay-ids').val ids.join ','
            $('#j-order-pay-form').submit()

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


    Fn.init()
