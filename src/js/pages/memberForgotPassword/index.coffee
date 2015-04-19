# 商品详情页面逻辑
define ['Sp', 'SelectBox','./phone_tpl','./email_tpl','./email_complete_tpl','Validator'], ( Sp, SelectBox, phone_tpl, email_tpl, email_complete_tpl, Validator )->

    validator = new Validator()
    success_text = '<span class="form-success-tips u-ml_5 iconfont u-color_green">&#xe615;</span>'

    page = ->

    page.step1 = () ->

        validatored = {}
        validatored.account = false
        validatored.code = false

        $(".formbtn").on "click",->
            if $(this).hasClass("_disable")
                return

        checkSetp1 = ->
            console.log validatored.account, validatored.code
            if validatored.account and validatored.code
                $(".j-step1-formbtn").removeClass("_disable").removeAttr("disabled")
            else
                $(".j-step1-formbtn").addClass("_disable").attr("disabled","disabled")

        account_error = ->
            $(".is_account_error").show().html "该账号不存在，请检查后再尝试!"
            validatored.account = false
            checkSetp1()

        account_success = ->
            $(".is_account_error").hide()
            validatored.account = true
            checkSetp1()

        code_error = ->
            $(".is_captcha_error").show().html "请输入正确的图形验证码"
            validatored.code = false
            checkSetp1()

        code_success = ->
            $(".is_captcha_error").hide()
            validatored.code = true
            checkSetp1()

        $("input[name='account']").on "blur",->
            self = this
            account = $(this).val()
            account = $.trim(account)

            if validator.methods.email(account)
                Sp.get Sp.config.host + "/api/member/checkEmail",{
                    email: account
                },(res)->
                    if res && res.code == 0
                        account_success()
                    else if res && res.code == 1
                        account_error()
                    else
                        account_error()
            else if validator.methods.phone(account)
                Sp.get Sp.config.host + "/api/member/checkMobile",{
                    mobile: account
                },(res)->
                    if res && res.code == 0
                        account_success()
                    else if res && res.code == 1
                        account_error()
                    else
                        account_error()
            else
                Sp.get Sp.config.host + "/api/member/checkName",{
                    name: account
                },(res)->
                    if res && res.code == 0
                        account_success()
                    else if res && res.code == 1
                        account_error()
                    else
                        account_error()



        # 输入验证码
        issend = false
        $(".text-captcha").on "keyup blur",->
            if validatored.code
                $("#reg-captcha").hide()
                $(".is_captcha_error").hide().text ""
                return
            if !issend and $(this).val().length == 5
                data = {}
                data.captcha = $(".register-box input[name='captcha']").val()
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
                $(".is_captcha_error").hide().text ""
                validatored.code = false


    page.step2 = (data)->

        time = 0
        timer = null

        validatored = {}
        validatored.captcha = false
        validatored.phonecode = false

        checkSetp2 = ->
            console.log validatored.captcha, validatored.phonecode
            if validatored.captcha and validatored.phonecode
                $("#j-phone-next").removeClass("_disable").removeAttr("disabled")
            else
                $("#j-phone-next").addClass("_disable").attr("disabled","disabled")

        code_error = ->
            $(".is_code_error").show().html "请输入正确的短信验证码"
            validatored.phonecode = false
            checkSetp2()

        code_success = ->
            if !$(".text-verifyphonecode").siblings(".form-success-tips").length
                $(".text-verifyphonecode").after success_text
            $(".is_code_error").hide()
            $(".form-verifycode").hide()
            validatored.phonecode = true
            checkSetp2()

        captcha_error = ->
            $(".is_captcha_error").show().html "请输入正确的图形验证码"
            validatored.captcha = false
            checkSetp2()

        captcha_success = ->
            validatored.captcha = true
            $(".is_captcha_error").hide()
            $("#reg-captcha").hide()
            $("#phone-code-box").show()
            $(".text-verifyphonecode").focus()
            if(!time)
                #$("#j-phone-verify-time").text "该手机还有还可获取2次验证码，请尽快完成验证"
                $(".form-verifycode .btn").html '<span class="u-color_darkred u-fl">120</span> <span class="u-color_black">秒后重新获取</span>'
                $(".form-verifycode .btn").addClass "_disable"
                _timerFn()
            checkSetp2()

        render = (type)->
            if (type == "email")
                tpl = email_tpl(data)
            else if(type=="phone")
                tpl = phone_tpl(data)
            else tpl = "<p>手机或邮箱没有通过验证</p>"
            $(".validate_forgetpass_box").html(tpl)

        jump = (url)->
            url = url.split('@')[1];
            switch url
                when "gmail.com"
                    window.location.href = "https://mail.google.com";
                else
                    window.location.href = "http://mail."+url;

        $('#j-select-validate').selectBox
            callback: (type,text)->
                render(type)

        # 初始化
        if($('#j-select-validate').length)
            type = $('#j-select-validate')[0]._selectBox.value
            render(type)

        _timerFn = =>
            time = 120
            timer = setInterval =>
                if(time<=1)
                    clearInterval timer
                    #$(".form-regetcode").hide();
                    $(".form-verifycode .btn").removeClass "_disable"
                    $(".form-verifycode .btn").html("重新获取验证码")
                timeElement = $(".form-verifycode").find(".u-color_darkred")
                timeElement.text --time
            ,1000

        # 输入验证码
        issend = false
        $(".text-captcha").on "keyup blur",->
            if validatored.code
                $("#reg-captcha").hide()
                $(".is_captcha_error").hide().text ""
                return
            if !issend and $(this).val().length == 5
                data = {}
                data.captcha = $(".register-box input[name='captcha']").val()
                issend = true
                Sp.get Sp.config.host + "/api/member/checkCaptcha", data, (res)->
                    if res and res.code ==0

                        Sp.post Sp.config.host + "/api/member/sendSms",{
                            mobile: $("#verify-mobile").text(),
                            type: 1,
                            captcha: data.captcha
                        },(res)->
                            if(res && res.code == 0 )
                                if(!time)
                                    $(".form-verifycode .btn").html '<span class="u-color_darkred u-fl">120</span> <span class="u-color_black">秒后重新获取</span>'
                                    $(".form-verifycode .btn").addClass "_disable"
                                    _timerFn()
                                captcha_success()
                    else
                        captcha_error()
            else if $(this).val().length > 5
                issend = false
                captcha_error()
            else
                issend = false
                $(".is_captcha_error").hide().text ""
                validatored.code = false


        # 验证手机验证码
        ischeck = false
        $(".text-verifyphonecode").on "keyup blur",->
            if validatored.phonecode
                return
            if  !ischeck and $(this).val().length == 6
                data = {}
                data['sms_code'] = $(this).val()
                data.mobile = $("#verify-mobile").text()
                data.type = 1
                ischeck = true
                Sp.get Sp.config.host + "/api/member/checkSms", data, (res)->
                    if res and res.code ==0
                        code_success()
                        $("input[name='sms_code']").val data['sms_code']
                    else
                        code_error()
            else if $(this).val().length > 6
                ischeck = false
                code_error()
            else
                ischeck = false
                $(this).siblings(".form-success-tips").remove()
                code_error()

        $(document).on "click","#j-phone-next", ->
            $("#j-setp2-form").submit()
            return false

        # 获取邮箱验证码
        $(document).on "click",".j-forgetpass-next",->
            Sp.post Sp.config.host + '/api/member/sendMail', {
                email: $("#verify-email").text(),
                type: 3
            },(res)->
                if(res && res.code == 0)
                    tpl = email_complete_tpl()
                    $(".getbackpassword-box__content").html(tpl)
                else
                    console.log "邮箱发送验证码失败"

            return false

        $(document).on "click","#j-email-complete",->
            jump(data.email)


    # 初始化页面
    page.init = ->

        data = _SP.memberdata;

        # 第一步
        if $(".ui-progress__bar._step-1").length
            page.step1()

        # 第二步
        if $(".ui-progress__bar._step-2").length
            page.step2(data)


    return  page
