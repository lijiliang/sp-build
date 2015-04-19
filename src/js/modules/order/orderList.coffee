# order-list
define ['Checkbox','CheckAll','SelectBox','./orderList'], (Checkbox, CheckAll, SelectBox, listTpl)->

    initCheckbox = ($el)->
        $el.checkAll(
            checkboxClass: '.ui-checkbox'
            callback: (checked, $el)->
                #console.log(checked, $el)
        )
    initSelectBox = ()->
        #console.log 1
        selectBox = new SelectBox el: $ '.ui-select-box'


    class OrderList
        constructor: (options)->
            @options = $.extend {}, @defaults, options
            @_setOrderData()
            @_init()

            @

        defaults:
            el: '.cart-table__bd'
            name: 'OrderList'


        _init: ()->
            @_initElements()
            @renderTpl @data


        _setOrderData: ()->
            $el = $ '#j-order-json'
            @data = JSON.parse $el.val()
            #console.log  @data

        _initElements: ()->
            @$bd = $ @options.el



        _bindEvt: ()->

        renderTpl: (data)->
            tpl = listTpl data
            @$bd.append tpl






    return  OrderList
