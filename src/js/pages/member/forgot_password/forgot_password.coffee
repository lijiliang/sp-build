# 商品详情页面逻辑
define ['Sp', 'SelectBox','./phone_tpl','./email_tpl','./email_complete_tpl','Validator', 'modules/check-password-strength/index', 'preLoad'], ( Sp, SelectBox, phone_tpl, email_tpl, email_complete_tpl, Validator, checkPasswordStrength )->

    validator = new Validator()
    success_text = '<span class="form-success-tips u-ml_5 iconfont u-color_green">&#xe615;</span>'

    page = ->

    page.step1 = () ->

        validatored = {}
        validatored.account = false
        validatored.code = false
        _account = '';

        $(".formbtn").on "click",->
            if $(this).hasClass("_disable")
                return

        checkSetp1 = ->
            #console.log validatored.account, validatored.code
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

        $("input[name='account']").on "keyup",->
            self = this
            account = $(this).val()
            account = $.trim(account)

            if(_account!=account)
                validatored.account = false
                validatored.code = false
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
                        _account = account
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
                        _account = account
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
                        _account = account
                    else if res && res.code == 1
                        account_error()
                    else
                        account_error()

            if(_account!=account)
                document.getElementById('captcha').src = '/api/captcha?' + Math.random();
                $(".text-captcha").val("");
                $(".is_captcha_error").show().html "请输入正确的图形验证码"



        # 输入验证码
        issend = false
        $(".text-captcha").on "keyup blur",->
            if validatored.code
                $("#reg-captcha").hide()
                $(".is_captcha_error").hide().text ""

            if $(this).val().length < 5
                $(".is_captcha_error").show().text "图形验证码长度不对"
                validatored.code = false
            else if issend
                $(".is_captcha_error").show().text "正在验证中..."
            else if !issend and $(this).val().length == 5
                data = {}
                data.captcha = $(".register-box input[name='captcha']").val()
                issend = true
                Sp.get Sp.config.host + "/api/member/checkCaptcha", data, (res)->
                    if res and res.code ==0
                        code_success()
                    else
                        code_error()
                    issend = false
                    checkSetp1()
            else if $(this).val().length > 5
                issend = false
                code_error()
            else
                issend = false
                $(".is_captcha_error").hide().text ""
                validatored.code = false
            checkSetp1()


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
                    $(".form-verifycode .btn").one "click",->
                        data = {}
                        data.captcha = $(".register-box input[name='captcha']").val()
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
                                $(".is_captcha_error").show().text "请求失败，请重试！"
                        return false
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
            return false


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


    page.step3 = (data) ->


        checkStrong = checkPasswordStrength

        validatored =
            password: false
            repassword: false


        $submit = $("#j-submit");
        $submit.on 'click', (e) ->
            e.preventDefault()
            e.stopPropagation()
            if $submit.hasClass '_disable' or !validatored.password or !validatored.repassword
                console.log 'no submit'
                return false
            else
                console.log 'go submit'
                $('form').submit();



        checkOK = ->
            if validatored.password and validatored.repassword
                $submit.removeClass("_disable")
            else
                $submit.addClass("_disable")


        strongStr = ["弱", "弱", "弱", "中", "强", "非常好"]
        # 密码验证
        $("input[name='password']").on "keyup focus",->
            password = $(this).val()
            password = $.trim(password)

            if password.length == 0
                $(".is_password_tips").show().text "6-20位字符，建议使用字母加数字或者符号组合"
                $(".is_password_error").hide()
            else
                $(".is_password_tips").hide()

        $("input[name='password']").on "keyup blur",->
            value = $(this).val()
            value = $.trim value
            strong = checkStrong value
            $(".ui-strength")
            .removeClass("_level-00")
            .removeClass("_level-01")
            .removeClass("_level-02")
            .removeClass("_level-03")
            .removeClass("_level-04")
            .removeClass("_level-05")
            .addClass("ui-strength")
            .addClass("_level-0"+strong)

            $("#pass_strong").text "强度:"+ strongStr[strong]

            if value.length >0
                $(".ui-pass-strong").show()
            else
                $(".ui-pass-strong").hide()

            if value.length > 5 and value.length <= 20
                $(".is_password_error").hide()
                validatored.password = true
            else
                $(this).siblings(".form-success-tips").remove()
                if value.length !=0
                    $(".is_password_error").show().text "密码长度应是6-20位字符"
                validatored.password = false

            checkOK()

        $("input[name='password']").on "blur",->
            #确认密码状态
            if ($("input[name='password_confirmation']").val()).length==0 and validatored.password == true
                $(".is_repassword_error").show().text "请确认密码"

        # 密码再次验证
        $("input[name='password_confirmation']").on "keyup focus",->
            repassword = $(this).val()
            repassword = $.trim(repassword)

            if repassword.length == 0
                $(".is_repassword_tips").show().text "请再次输入密码，确保两次输入一致"
                $(".is_repassword_error").hide()
            else
                $(".is_repassword_tips").hide()


        $("input[name='password_confirmation']").on "focus keyup blur",->
            if $(this).val().length > 5 and $(this).val().length <= 20
                if $(this).val() == $("input[name='password']").val()
                    #显示正确标识
                    if !$(this).siblings(".form-success-tips").length
                        $(this).after success_text
                    $(".is_repassword_error").hide()
                    validatored.repassword = true
                else
                    $(this).siblings(".form-success-tips").remove()
                    $(".is_repassword_error").show().text "两次输入密码不一致"
                    validatored.repassword = false
            else if $(this).val().length == 0
                $(this).siblings(".form-success-tips").remove()
                $(".is_repassword_error").hide()
                validatored.repassword = false
            else
                $(this).siblings(".form-success-tips").remove()
                $(".is_repassword_error").show().text "密码长度应是6-20位字符"
                validatored.repassword = false
            checkOK()






    # 初始化页面
    page.init = ->
        data = _SP.memberdata;

        # 第一步
        if $(".ui-progress__bar._step-1").length
            page.step1()

        # 第二步
        if $(".ui-progress__bar._step-2").length
            page.step2(data)

        # 第3步
        if $(".ui-progress__bar._step-3").length
            page.step3()
            console.log '第3步'


    page.init()
