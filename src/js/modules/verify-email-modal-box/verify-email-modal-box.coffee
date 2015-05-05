# 模态框
define ['ModalBox', './tpl-layout'], (ModalBox, verifyEmailModalBox_tpl)->
    class verifyEmailModalBox extends ModalBox
        constructor: (@options)->
            @options.template = verifyEmailModalBox_tpl({})
            @options.init = =>
                $("#"+@id).find(".email_url").html(@options.email)
            super
            $(document).on "click", "#j-verify-email", =>
                @jump()
                return false;
        jump: ->
            url = @options.email.split('@')[1];
            switch url
                when "gmail.com"
                    window.open "https://mail.google.com";
                else
                    window.open "http://mail."+url;
    return  verifyEmailModalBox
