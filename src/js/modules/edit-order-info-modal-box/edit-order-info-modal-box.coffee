# 模态框
define ['ModalBox','./tpl-layout'], (ModalBox,editOrderInfoModalBox_tpl)->
    class EditOrderInfoModalBox extends ModalBox
        constructor: (@options)->
            @options.template = editOrderInfoModalBox_tpl({})
            super
    return  EditOrderInfoModalBox
