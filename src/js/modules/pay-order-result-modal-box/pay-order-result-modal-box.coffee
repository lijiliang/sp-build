# 模态框
define ['ModalBox', './tpl-layout',
        './tpl-confirm'], (ModalBox, payOrderResultModalBox_tpl, payOrderResultConfirmModalBox_tpl)->
    class PayOrderResultModalBox extends ModalBox
        constructor: (@options)->
            @options.template = @options.template || payOrderResultModalBox_tpl({})
            super
            confirmTpl = payOrderResultConfirmModalBox_tpl({})
            $(document).on "click", "#j-finish-pay", =>
                $("#"+@id).find(".ui-modal__box").remove()
                $("#"+@id).find(".ui-modal__content").append(confirmTpl)
                time = 60
                timeElement = $("#"+@id).find(".u-color_darkred")
                timer = setInterval =>
                        if(time<=1)
                            clearInterval timer
                            @jump()
                        timeElement.text --time
                    ,1000
                return false;
        jump: ->
            #console.log "compete"
            window.location.href = '/order/detail?order_id=' + $('.order-info-compete').data 'order-id'
    return  PayOrderResultModalBox
