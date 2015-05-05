# 模态框
define ['Sp', 'ModalBox', './tpl-layout','./tpl-success', 'LightModalBox'], (Sp, ModalBox, verifyPhoneModalBox_tpl,verifyPhoneModalBox_success,LightModalBox)->
    class verifyPhoneModalBox extends ModalBox
        constructor: (@options)->
            @options.template = verifyPhoneModalBox_tpl({})

            @options.success = @options.success || ()->

            validatored = {}
            validatored.code = false
            validatored.phonecode = false

            _sendSms = (captcha,phone,callback)->
                Sp.post Sp.config.host+ "/api/member/sendSms", {
                    captcha:captcha
                    type: 2,
                    mobile: phone
                },(res)->
                    if(res && res.code ==0)
                        callback true
                    else
                        callback false

            $(document).on "click", "#j-close-model", =>
                $("#"+@id).remove()

            send = =>


                tipsElement = $("#"+@id).find(".tips")
                resendHtml = '短信验证码已发送，请注意查收，如果没有收到，<a id="resend" href="#">重新获取短信验证码</a>'
                defaultHtml = '短信验证码已发送，请注意查收，如果没有收到，可在<span class="u-color_darkred">120</span>秒后要求系统重新发送'

                tipsElement.html defaultHtml
                timeElement = $("#"+@id).find(".u-color_darkred")

                _timerFn = =>
                    clearInterval timer
                    time = 120
                    timer = setInterval =>
                        if(time<=1)
                            clearInterval timer
                            tipsElement.html resendHtml
                        timeElement = $("#"+@id).find(".u-color_darkred")
                        timeElement.text --time
                    ,1000

                _timerFn()

                $(document).on "click","#resend",=>
                    _sendSms $("#reg-captcha input[name='captcha']").val(),this.options.phone,(res)->
                        if res
                            tipsElement.html defaultHtml
                            time = 120
                            _timerFn()
                        else
                            alert("手机号验证码发送失败，请重试")
                    return false;

                ischeck = false
                $(document).on "click","#j-verify-phone",=>
                    that = this
                    $textVerifyphonecode = $(".text-verifyphonecode")
                    $id = $("#"+@id)
                    if  !ischeck and $textVerifyphonecode.val().length == 6
                        data = {}
                        data['sms_code'] = $(".text-verifyphonecode").val()
                        data.mobile = that.options.phone
                        data.member_id = _SP.member
                        data.sms_code = $textVerifyphonecode.val()
                        ischeck = true
                        Sp.post Sp.config.host + "/api/member/changeMobile", data, (res)->
                            if res and res.code ==0
                                confirmTpl = verifyPhoneModalBox_success({})
                                $id.find(".ui-modal__box").remove()
                                $id.find(".ui-modal__content").append(confirmTpl)
                                $("#j-phone-tips").show()
                                that.options.success()
                            else
                                $id.find(".tips_error").html("验证码错误，请重试!")
                    else
                        ischeck = false
                        $id.find(".tips_error").html("验证码长度有误，请重试!")
                    return false;

            @options.init = =>
                that = this
                $(".text-captcha").focus()


                _successFn = ->
                    _sendSms $("#reg-captcha input[name='captcha']").val(),that.options.phone,(res)->
                        if res
                            $("#reg-captcha").hide()
                            $(".phone-verify-code-box").show()
                            $(".text-verifyphonecode").focus()
                            $(".is_captcha_error").hide()
                        else
                            $(".is_captcha_error").show().html '手机验证码发送失败，<a id="reSendMobileCode" href="javascript:void(0)">点击重发</a>'
                    send()

                $(document).on "click","#reSendMobileCode",->
                    _successFn()

                checkSetp1 = ->
                    if validatored.code == true
                        _successFn()

                code_error = ->
                    $(".is_captcha_error").show().html "请输入正确的图形验证码"
                    validatored.code = false
                    checkSetp1()

                code_success = ->
                    $(".is_captcha_error").hide()
                    validatored.code = true
                    checkSetp1()

                # 输入验证码
                issend = false
                $(".text-captcha").on "keyup blur",->
                    if !issend and $(this).val().length == 5
                        data = {}
                        data.captcha = $("#reg-captcha input[name='captcha']").val()
                        issend = true
                        Sp.get Sp.config.host + "/api/member/checkCaptcha", data, (res)->
                            if res and res.code ==0
                                code_success()
                            else
                                code_error()
                    else if $(this).val().length > 5
                        issend = false
                        code_error()
                    else
                        issend = false
                        #$(".is_captcha_error").hide().text ""
                        validatored.code = false

            super

        phone: (val)->
            /^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$/.test val
    return  verifyPhoneModalBox
