# 模态框
define ['Sp','ModalBox','./tpl-layout'], (Sp,ModalBox,liteModalBox_tpl)->
    class liteModalBox extends ModalBox
        constructor: (@options)->
            @options.template = @options.template || liteModalBox_tpl({
                title: @options.title,
                contents: @options.contents
            })
            super
            @_initModal()

        _initModal: ()->
            _this = @


    return  liteModalBox
