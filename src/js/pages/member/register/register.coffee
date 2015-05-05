# cart
define ['Sp','Validator','modules/check-password-strength/index','agreementModalBox','LoginModalBox', 'preLoad'], (Sp,Validator,checkPasswordStrength,AgreementModalBox,LoginModalBox)->

    validator = new Validator()
    success_text = '<span class="form-success-tips u-ml_5 iconfont u-color_green">&#xe615;</span>'

    registObj =
        account: ''

    validatored =
        account: false
        code: false
        phonecode: false
        password: false
        repassword: false
        readed: true

    checkOK = ->
        #console.log validatored.account , validatored.code , validatored.phonecode , validatored.password , validatored.repassword, validatored.readed
        if validatored.account and validatored.code and validatored.phonecode and validatored.password and validatored.repassword and validatored.readed
            $(".j-register-btn").removeClass("_disable")
        else
            $(".j-register-btn").addClass("_disable")

    page = ->

    page.init = ->
        # 注册时手机、邮箱判断
        verifycode();

    checkStrong = checkPasswordStrength

    #获取手机验证码
    verifycode = ->
        time = 0
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
                        data.mobile = $(".register-box input[name='account']").val()
                        data.type = 0
                        Sp.post Sp.config.host + "/api/member/sendSms", data, (res)->
                            if res and res.code ==0
                                $("#reg-captcha").hide()
                                $("#phone-code-box").show()
                                $(".text-verifycode").focus()
                                if(!time)
                                    #$("#j-phone-verify-time").text "该手机还有还可获取2次验证码，请尽快完成验证"
                                    $(".form-verifycode .btn").html '<span class="u-color_darkred u-fl">120</span> <span class="u-color_black">秒后重新获取</span>'
                                    $(".form-verifycode .btn").addClass "_disable"
                                    _timerFn()
                                validatored.code = true
                            else
                                $(".is_captcha_error").show().text "请求失败，请重试！"
                            return false
                timeElement = $(".form-verifycode").find(".u-color_darkred")
                timeElement.text --time
            ,1000

        # 快捷登录
        loginBox = null
        $(document).on "click",".j-quick-login", ->
            if !loginBox
                loginBox = new LoginModalBox
                    top: 200
                    mask: true
                    closeBtn: true
                    loginSuccessCallback: ()->
                        window.location.href = "/"
            loginBox.show()
            return false


        # 显示手机验证码
        $("input[name='account']").on "focus keyup",->

            self = this
            account = $(this).val()
            account = $.trim(account)

            if account.length == 0
                $(".is_account_tips").show().text "请输入邮箱或11位手机号"
                $(".is_account_error").hide()
            else
                $(".is_account_tips").hide()

            complete = (that)->
                if !$(that).siblings(".form-success-tips").length
                    $(that).after success_text
                $(".is_account_error").hide().text ""
                validatored.account = true
                if validator.methods.phone(account)
                    if !validatored.code
                        $("#reg-captcha").show()
                        $(".text-captcha").focus()
                else
                    validatored.code = true
                    validatored.phonecode = true
                    $("#reg-captcha").hide()
                    $("#phone-code-box").hide()
                checkOK()

            error = (that)->
                $(that).siblings(".form-success-tips").remove()
                $("#reg-captcha").hide()
                $("#phone-code-box").hide()
                validatored.account = false
                validatored.code = false
                validatored.phonecode = false

            if !(validator.methods.email(account) or validator.methods.phone(account))
                if account.length !=0
                    $(".is_account_error").show().text "请输入正确的邮箱或者手机号"
                error self
            else if validator.methods.phone(account)
                if(registObj.account == account && validatored.phonecode!=true)
                    $("#reg-captcha").hide()
                    $("#phone-code-box").show()
                else if($("#reg-captcha").is(":hidden") && validatored.phonecode!=true)
                    Sp.get Sp.config.host + "/api/member/checkMobile",{
                        mobile: account
                    },(res)->
                        registObj.account = account;
                        if res && res.code == 0
                            if parseInt(res.data.status) == 1
                                $(".is_account_error").show().html "该账号已经存在，请马上<a class='j-quick-login' href='#'>登陆</a>"
                            else
                                $(".is_account_error").show().html "该账号已经存在，尚未激活"
                        else
                            complete self


            checkOK()
            return false

        $("input[name='account']").on "blur",->

            self = this
            account = $(this).val()
            account = $.trim(account)

            complete = (that)->
                if !$(that).siblings(".form-success-tips").length
                    $(that).after success_text
                $(".is_account_error").hide().text ""
                validatored.account = true
                if validator.methods.phone(account)
                    if !validatored.code
                        $("#reg-captcha").show()
                        $(".text-captcha").focus()
                else
                    validatored.code = true
                    validatored.phonecode = true
                    $("#reg-captcha").hide()
                    $("#phone-code-box").hide()
                checkOK()

            error = (that)->
                $(that).siblings(".form-success-tips").remove()
                $("#reg-captcha").hide()
                $("#phone-code-box").hide()
                validatored.account = false
                validatored.code = false
                validatored.phonecode = false

            if !(validator.methods.email(account) or validator.methods.phone(account))
                if account.length !=0
                    $(".is_account_error").show().text "请输入正确的邮箱或者手机号"
                error self
            else if validator.methods.email(account)

                accountArr = account.split("@");
                if(accountArr[0].length>30)
                    $(".is_account_error").show().text "邮箱的字符应在6-30位之间"
                else
                    Sp.get Sp.config.host + "/api/member/checkEmail",{
                        email: account
                    },(res)->
                        if res && res.code == 0
                            if parseInt(res.data.status) == 1
                                $(".is_account_error").show().html "该账号已经存在，请马上<a class='j-quick-login' href='#'>登录</a>"
                            else
                                $(".is_account_error").show().html "该账号已经存在，尚未激活"
                        else
                            complete self

            checkOK()
            return false
        # 输入验证码
        issend = false
        $(".text-captcha").on "keyup blur",->
            val = $.trim($(this).val())
            if validatored.code
                $("#reg-captcha").hide()
                $(".is_captcha_error").hide().text ""
                return
            if !issend and val.length == 5
                data = {}
                data.captcha = $(".register-box input[name='captcha']").val()
                data.mobile = $(".register-box input[name='account']").val()
                data.type = 0
                issend = true
                Sp.post Sp.config.host + "/api/member/sendSms", data, (res)->
                    if res and res.code ==0
                        $("#reg-captcha").hide()
                        $(".text-verifycode").removeAttr("disabled");
                        $("#phone-code-box").show()
                        $(".text-verifycode").focus()
                        if(!time)
                            #$("#j-phone-verify-time").text "该手机还有还可获取2次验证码，请尽快完成验证"
                            $(".form-verifycode .btn").html '<span class="u-color_darkred u-fl">120</span> <span class="u-color_black">秒后重新获取</span>'
                            $(".form-verifycode .btn").addClass "_disable"
                            _timerFn()
                        validatored.code = true
                    else
                        $(".is_captcha_error").show().text "请输入正确的图形验证码"
                        validatored.code = false
            else if val.length > 5
                issend = false
                $(".is_captcha_error").show().text "图形验证码长度不正确"
                validatored.code = false
            else
                issend = false
                $(".is_captcha_error").hide().text ""
                validatored.code = false
            checkOK()

        # 验证手机验证码
        ischeck = false
        $(".text-verifycode").on "keyup blur",->
            that = this
            val = $.trim($(this).val())
            if validatored.phonecode
                return
            if  !ischeck and val.length == 6
                data = {}
                data['sms_code'] = $(".register-box input[name='sms_code']").val()
                data.mobile = $(".register-box input[name='account']").val()
                #$(".register-box input[name='account']").attr("disable")
                data.type = 0
                ischeck = true
                Sp.get Sp.config.host + "/api/member/checkSms", data, (res)->
                    if res and res.code ==0
                        #显示正确标识 todo
                        if !$(that).siblings(".form-success-tips").length
                            $(that).after success_text
                        $(".is_verify_error").hide().text ""
                        $(".form-verifycode").hide()
                        $(".text-verifycode").attr("disabled","disabled");
                        validatored.phonecode = true
                    else
                        $(".is_verify_error").show().text "请输入正确的短信验证码"
                        validatored.phonecode = false
            else if val.length > 6
                ischeck = false
                $(".is_verify_error").show().text "验证码长度不正确"
                validatored.phonecode = false
            else
                ischeck = false
                $(this).siblings(".form-success-tips").remove()
                $(".is_verify_error").hide().text ""
                validatored.phonecode = false
            checkOK()

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

        $("input[name='password']").on "keyup blur",->
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


        readed = ->
            validatored.readed = $(".agree-checked").prop( "checked" )
            checkOK()


        # 查看用户协议
        agreementBox = null
        $("#j-show-protocol").on "click",->
            if(!agreementBox)
                agreementBox = new AgreementModalBox
                    top: 100
                    mask: true
                    closeBtn: true
            agreementBox.show()
            return false

        # 关闭用户协议
        $(document).on "click","#js-agreement",->
            if agreementBox
                agreementBox.modal.hide()
                $(".agree-checked").prop( "checked", true )
                readed()

        # 点击已阅用户协议
        $(".agree-checked").on "click", ->
            readed()
            return

        # 开始注册
        $(".j-register-btn").on "click",->
            if $(this).hasClass("_disable")
                return
            data = {}
            data['account'] = $(".register-box input[name='account']").val()
            data['password'] = $(".register-box input[name='password']").val()
            data['password_confirmation'] = $(".register-box input[name='password_confirmation']").val()
            data['sms_code'] = $(".register-box input[name='sms_code']").val()
            $(this).addClass("_disable")
            $(this).text "正在注册.."
            Sp.post Sp.config.host + "/api/member/register",data,(res)->
                if res && res.code == 0
                    window.location.href = "/"+res.data.url
                else
                    Sp.log res
                $(this).removeClass("_disable")
                $(this).text "注册"
            return false


    page.init()
