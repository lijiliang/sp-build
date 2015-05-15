# 模态框
# 警告提示框
define ['ModalBox','./tpl-layout'], (ModalBox,tpl)->
    class AlertModalBox extends ModalBox
        constructor: (@options)->
            text = $.extend {
                title: '操作提示'
                content: '您当前的操作无法继续！'
                width: 400
                top: 100
                mask: true
                closeBtn: false
            },@options.text;

            @options.template = @options.template || tpl(text)
            super
        render: ()->
            super
            $ok = this.modal.find '.confirm-modal-box__ok'

            $ok.on 'click', ()=>
                @options.callback.call @ if typeof @options.callback is 'function'
                @modal.hide()
                return false

    return AlertModalBox
