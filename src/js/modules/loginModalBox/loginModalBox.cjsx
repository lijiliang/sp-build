# 模态框
define ['Sp','ModalBox','./loginModalBox_tpl','modules/components/loginbox_modal'], (Sp,ModalBox,loginModalBox_tpl,Loginbox)->
    class loginModalBox extends ModalBox
        constructor: (@options)->
            @options.template = @options.template || loginModalBox_tpl({})
            super
            @_initModal()

        _initModal: ()->
            _this = @
            React.render <Loginbox success={_this.options.loginSuccessCallback||()->} />, @modal.find('#loginbox-pop-wrap')[0]

    return  loginModalBox
