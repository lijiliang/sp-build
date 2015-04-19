# 模态框
define ['ModalBox','./editOrderInfoModalBox_tpl'], (ModalBox,editOrderInfoModalBox_tpl)->
    class EditOrderInfoModalBox extends ModalBox
        constructor: (@options)->
            @options.template = editOrderInfoModalBox_tpl({})
            super
    return  EditOrderInfoModalBox
