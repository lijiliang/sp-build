# 模态框
define ['Sp', 'ModalBox', './tpl-layout','./tpl-success'], (Sp, ModalBox, setEmailModalBox_tpl,setEmailModalBox_success)->
    class setEmailModalBox extends ModalBox
        constructor: (@options)->
            self = this
            @options.template = setEmailModalBox_tpl({})
            @options.init = =>

                tipsElement = $("#"+@id).find(".tips")
                defaultHtml = '请填写你要设置的登录邮箱'

                tipsElement.html defaultHtml

                $(document).on "click","#j-verify-email",=>
                    $id = $("#"+this.id)
                    @jump($id.find(".email_url").text())
                    return false;

                $(document).on "click","#j-setmail-now",=>
                    that = this
                    $id = $("#"+that.id)
                    confirmTpl = setEmailModalBox_success({})
                    email_val = $("#"+@id).find("input[name='newmail']").val()

                    if(self.email(email_val))
                        Sp.post Sp.config.host + '/api/member/setEmail',{
                            member_id: _SP.member,
                            email: email_val
                        },(res)->
                            if res and res.code ==0
                                $id.find(".ui-modal__box").remove()
                                $id.find(".ui-modal__content").append(confirmTpl)
                                $id.find(".email_url").html email_val
                            else
                                $id.find(".tips_error").html("发送设置登录邮箱不成功，请重试")
                    else
                        $id.find(".tips_error").html("邮箱格式不正确")
                    return false;
            super

        jump: (url)->
            switch url
                when "gmail.com"
                    window.location.href = "https://mail.google.com";
                else
                    window.location.href = "http://mail."+url;

        email: (val) ->
            /^(?:\w+\.?\+?)*\w+@(?:\w+\.)+\w+$/.test val

    return  setEmailModalBox
