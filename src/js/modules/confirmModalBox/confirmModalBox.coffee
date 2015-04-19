# 模态框
define ['ModalBox','./confirmModalBox_tpl'], (ModalBox,tpl)->
    class confirmModalBox extends ModalBox
        constructor: (@options)->
            text = $.extend {
                title: '操作提示'
                content: '您确认执行该操作吗?'
            },@options.text;
            @options.template = @options.template || tpl(text)
            super
        render: ()->
            super

            $ok = this.modal.find '.confirm-box__ok'
            $cancel = this.modal.find '.confirm-box__cancel'

            $ok.on 'click', ()=>
                @options.confirmCallback.call @ if typeof @options.confirmCallback is 'function'
                @modal.hide()
                return false



    return confirmModalBox
