# 模态框
define ['ModalBox','./tpl-layout'], (ModalBox,agreementModalBox_tpl)->
    class loginModalBox extends ModalBox
        constructor: (@options)->
            @options.template = @options.template || agreementModalBox_tpl({})
            super
    return  loginModalBox
