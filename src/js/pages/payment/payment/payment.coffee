# for order-settlement Page
define ['Sp','DatePicker','AddressList','InvoiceList','Checkbox', 'PayOrderResultModalBox', 'preLoad'], (Sp, DatePicker, AddressList, InvoiceList, Checkbox, PayOrderResultModalBox)->
    member_id = _SP.member
    orderData =
        member_address_id: ''
        reserve_delivery_time: ''
        reserve_installation_time: ''
        invoice_id: ''
        note: ''

    #API
    host = Sp.config.host

    Api =
        submit: 'order/create'
        getTotalPrice: 'price/getSettlement'

    Action =
        baseUrl: host + '/api/'
        path: Api
        fn: (res)->
            #console.log res
        submit: (data)->
            Sp.post @baseUrl + @path.submit, data, @fn, @fn
        getTotalPrice: (region_id)->
            param = ''
            if region_id then param = '?region_id=' + region_id
            Sp.get @baseUrl + @path.getTotalPrice + param, {}, @fn, @fn


    Fn = ->

    Fn.init = ->
        new AddressList
            el:'#j-order-info-address'
            member_id: member_id
            callback: (address_id, region_id)->
                console.log address_id, region_id
                Action.getTotalPrice region_id
                .done (res)->
                    if res.code is 0 and res.data and res.data isnt -1
                        $('#j-total-price').html res.data.total_price
                        $('#j-total-delivery').html res.data.total_delivery
                        $('#j-total-installation').html res.data.total_installation
                        $('#j-total-amount').html res.data.total_amount
                        $('#j-total').html res.data.total

                        orderData.member_address_id = address_id
                        $el = $ '#j-order-submit'
                        $el.removeClass '_disable'
                    else
                        $('#j-total-price').html ''
                        $('#j-total-delivery').html ''
                        $('#j-total-installation').html ''
                        $('#j-total-amount').html ''
                        $('#j-total').html ''
                        $el = $ '#j-order-submit'
                        $el.addClass '_disable'
                        orderData.member_address_id = ''


        initDatePicker()
        initInvoice()
        initSubmit()
        initNote()

        # 支付弹窗
        payOrderResultModalBox= null
        $("#j-pay-btn").on "click", ->
            if !payOrderResultModalBox
                payOrderResultModalBox = new PayOrderResultModalBox
                    top: 250
                    mask: true
                    maskClose: true
                    closeBtn: true
            payOrderResultModalBox.show()

    initNote = ()->
        $box = $ '#j-order-comment-box'
        $note = $box.find '.form-textarea'
        $info = $ '<div class="u-text-right">还可以输入<span>200</span>字</div>'
        $info.css 'width',$note.outerWidth()
        $box.append $info
        $num = $info.find 'span'
        $note.on 'input', ()->
            val = $(@).val()
            $num.html 200 - val.length
            if val.length > 200
                $(@).val val.slice 0,200
                $num.html 0


    initInvoice = ()->
        $el = $ '#j-show-invoice'
        $box = $ '#j-order-invoice-box'
        new InvoiceList
            el:'#j-order-invoice-box'
            member_id: member_id
            callback: (value)->
                orderData.invoice_id = value
        $el.checkbox
            callback: (value)->
                if value
                    $box.show()
                else
                    $box.hide()
                    orderData.invoice_id = ''


    initDatePicker = ()->
        $deliver = $ '#j-date-deliver'
        $install = $ '#j-date-install'

        theDate = $deliver.data 'date'
        if theDate
            earliestDate =  Sp.date.parse theDate.split(' ')[0]
        else
            return theDate
        earliestDateFomated = Sp.date.format earliestDate

        #$deliver
            #.add $install
            #.val earliestDateFomated
        $install.on 'focus', ()->
            $(@).blur()

        $deliver.datePicker(
            initDate: earliestDate
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
                    initDate: date
                    delay: 0
                    disabled: disabled
                    callback: (date)->
                        #console.log date
                        orderData.reserve_installation_time = date
                )

                orderData.reserve_delivery_time = date
                orderData.reserve_installation_time = date
        )

    setData = ()->
        $note = $ '#j-order-comment-box .form-textarea'
        orderData.note = $note.val()
        orderData

    initSubmit = ()->
        $el = $ '#j-order-submit'
        postData = setData()
        $el.on 'click', ()->
            if $el.hasClass '_disable'
                return false
            else
                $el.addClass '_disable'
                if postData.member_address_id
                    #Action.submit postData

                    $form = $ '<form action="/order/create" method="POST"></form>'

                    for item of postData
                        $ipt = $ '<input type="hidden">'
                        $ipt.attr 'name',item
                        $ipt.val postData[item]
                        $form.append $ipt

                    $form.appendTo 'body'
                    $form.submit()


                else
                    return false


    Fn.init()
