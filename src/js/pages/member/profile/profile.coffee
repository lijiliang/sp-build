# 商品详情页面逻辑
define ['Sp', 'SetEmailModalBox', 'SetPhoneModalBox', 'VerifyEmailModalBox', 'VerifyPhoneModalBox', 'SetPassWordModalBox','AddressList','LightModalBox','Validator', 'preLoad'], (Sp, SetEmailModalBox, SetPhoneModalBox,VerifyEmailModalBox,VerifyPhoneModalBox, SetPassWordModalBox, AddressList, LightModalBox,Validator)->

    validator = new Validator()

    page = ->

    # 初始化页面
    page.init = ->
        # 设置邮箱
        setEmail()

        # 设置手机
        setPhone()

        # 修改用户名
        modifyUserName()

        # 修改密码
        changePassword()

        new AddressList
            el:'#j-order-info-address'
            checkboxClick: false,
            member_id: _SP.member
            callback: (value)->


    # 修改用户名
    modifyUserName = ()->

        $userNameBox = $ '#j-user-name-box'
        username = _SP.pageData.username.val

        # 取消操作
        usernameActionTpl = '<a href="javascript:;" id="j-submit-modify-user-name">修改</a><span class="u-color_gold u-ml_10 u-mr_10">|</span><a href="javascript:;" id="j-cancel-modify-user-name">取消</a>'

        editActionTpl = '<a href="javascript:;" id="j-modify-user-name">修改</a>'

        usernameFirst = '<span class="u-mr_20">'+username+'</span><span><i class="iconfont icon-tanhaotishi u-f14"></i>可以设置个性用户名作为账号登陆斯品平台(<span class="u-color_red">只允许修改一次</span>)</span>'

        usernameSecond = '<span class="u-mr_20" id="j-show-username">'+username+'</span>'

        inputTpl = '<input id="j-user-name-ipt" type="text" placeholder="" class="form-text" value="'+username+'" name=""><p class="u-color_red is_name_error u-mt_5 _tips_p"></p>'


        $account_action_box = $ ".account_action_box"
        # 点击修改用户名
        $(document).on 'click','#j-modify-user-name',()->
            $account_action_box.html usernameActionTpl
            $userNameBox.html inputTpl
            $("#j-user-name-ipt").focus()
            return false

        # 取消修改
        $(document).on "click","#j-cancel-modify-user-name",->
            $account_action_box.html editActionTpl
            $userNameBox.html usernameFirst
            return false

        # 提交修改
        $(document).on "click","#j-submit-modify-user-name",->
            value = $.trim($("#j-user-name-ipt").val())
            $(".is_name_error").hide()

            if(value.length>=6 && value.length<16)
                # 用户名是否存在
                Sp.get Sp.config.host + "/api/member/checkName",{
                    name:value
                },(res)->
                    if res and res.code ==0
                        $(".is_name_error").text("用户名已存在").show()
                    else
                        ## 调用修改用户名API
                        Sp.post Sp.config.host + "/api/member/changeName", {
                            member_id: _SP.member,
                            name: value
                        },(res)->
                            if(res && res.code ==0)
                                $userNameBox.html usernameSecond
                                _SP.pageData.username.val = res.data.name
                                _SP.pageData.username.init = false
                                $("#j-show-username").text res.data.name
                                $account_action_box.html ''
                                Sp.trigger("sp-update-member-name", res.data.name);
                                Sp.log "用户名修改成功"
                                lightModalBox = new LightModalBox
                                    width: 250
                                    status: "success"
                                    text : "用户名修改成功"
                                lightModalBox.show()
                            else
                                Sp.log "用户名修改失败"
                                lightModalBox = new LightModalBox
                                    width: 250
                                    status: "error"
                                    text : "用户名修改失败"
                                lightModalBox.show()
            else
                $(".is_name_error").show().html("用户名长度应在6-16位")

            return false

    # 发送邮件验证码
    _sendMail = (email,callback) ->
        Sp.post Sp.config.host + "/api/member/changeEmail", {
            email: email
            member_id: _SP.member
        },(res)->
            if(res && res.code == 0)
                # 出现可发送验证码按钮
                verifyEmailModalBox = null
                if !verifyEmailModalBox
                    verifyEmailModalBox = new VerifyEmailModalBox
                        top: 250
                        mask: true
                        maskClose: true
                        closeBtn: true
                        email: email
                verifyEmailModalBox.show()
                callback true
                Sp.log "发送验证邮件成功"
            else
                lightModalBox = new LightModalBox
                    width: 250
                    status: "error"
                    text : "发送验证邮件失败"
                lightModalBox.show()
                callback false
                Sp.log "发送验证邮件失败"

    # 设置邮箱
    setEmail = () ->

        actionType = 0;

        $emailBox = $ '#j-email-box'
        email = _SP.pageData.email.val

        # 取消操作
        actionTpl = '<a href="javascript:;" id="j-submit-modify-email">保存</a><span class="u-color_gold u-ml_10 u-mr_10">|</span><a href="javascript:;" id="j-cancel-modify-email">取消</a>'

        # 验证
        verifyAndChangeTpl = '</span><a href="javascript:;" id="j-changeEmail-btn">更换</a>'

        #<a href="javascript:;" id="j-sendEmail-btn">去验证邮箱</a>

        editActionTpl = '<a href="javascript:;" id="j-modify-email">设置</a>'

        # 更换邮箱
        changeEmailTpl = '<a href="javascript:;" id="j-changeEmail-btn">更换</a>'

        emailBox = '<span class="u-mr_20" id="j-show-email">'+(if email then email else "尚未设置邮箱")+'</span>'

        inputTpl = '<input id="j-user-email-ipt" type="text" placeholder="" class="form-text" value="'+email+'" name=""><p class="u-color_red is_email_error u-mt_5 _tips_p"></p>'


        $email_action_box = $ ".email_action_box"
        # 设置
        $(document).on "click","#j-modify-email", ->
            $email_action_box.html actionTpl
            $emailBox.html inputTpl
            $("#j-user-email-ipt").focus()
            actionType = 0
            return false

        # 更换
        $(document).on "click",'#j-changeEmail-btn',->
            $email_action_box.html actionTpl
            $emailBox.html inputTpl
            $("#j-user-email-ipt").focus()
            actionType = 1
            return false

        # 取消修改
        $(document).on "click","#j-cancel-modify-email",->
            $email_action_box.html if actionType then changeEmailTpl  else editActionTpl
            $emailBox.html emailBox
            return false

        # 提交修改
        $(document).on "click","#j-submit-modify-email",->
            value = $("#j-user-email-ipt").val()
            if validator.methods.email(value) and value != email
                $(".is_email_error").hide()
                # 保存新的邮箱
                Sp.get Sp.config.host + "/api/member/checkEmail", {
                    email: value
                },(res)->
                    if res and res.code ==0
                        $(".is_email_error").text('邮箱地址已存在').show()
                    else
                        _SP.pageData.email.val = value
                        # 默认发送验证码
                        _sendMail  _SP.pageData.email.val,(res)->
                            if res
                                $email_action_box.html verifyAndChangeTpl
                                $emailBox.html emailBox
                                $("#j-show-email").html value
                            else
                                $(".is_email_error").text('发送邮箱验证码失败，请重试!').show()
            else
                $(".is_email_error").text('请输入正确的邮箱').show()
            return false


    # 更改邮箱
    changeEmail = () ->
        # 更改邮箱
        verifyEmailModalBox = null
        $("#j-changeEmail-btn").on "click", ->
            if !verifyEmailModalBox
                verifyEmailModalBox = new VerifyEmailModalBox
                    top: 250
                    mask: true
                    maskClose: false
                    closeBtn: true
                    email: $("#user_email").text()
            verifyEmailModalBox.show()

            Sp.post Sp.config.host + "/api/member/sendMail", {
                email: $("#user_email").text(),
                type: 2
            },(res)->
                if(res && res.code == 0)
                    Sp.log "发送验证邮件成功"
                else
                    Sp.log "发送验证邮件失败"
            return false

    # 设置手机
    setPhone = ()->

        $phoneBox = $ '#j-phone-box'
        phone = _SP.pageData.phone.val

        # 取消操作
        actionTpl = '<a href="javascript:;" id="j-submit-modify-phone">修改</a><span class="u-color_gold u-ml_10 u-mr_10">|</span><a href="javascript:;" id="j-cancel-modify-phone">取消</a>'

        editActionTpl = '<a href="javascript:;" id="j-modify-phone">'+(if phone then "修改" else "设置")+'</a>'

        phoneNum = '<span class="u-mr_20" id="j-show-phone">'+(if phone then phone else "尚未设置手机")+'</span>'

        inputTpl = '<input id="j-user-phone-ipt" type="text" placeholder="" class="form-text" value="'+phone+'" name=""><p class="u-color_red is_phone_error u-mt_5 _tips_p"></p>'


        $phone_action_box = $ ".phone_action_box"

        _setVal = ->
            if _SP.pageData.phone.val
                $("#j-show-phone").text _SP.pageData.phone.val
            else
                $("#j-show-phone").text "尚未设置手机"

        # 设置
        $(document).on "click","#j-modify-phone", ->
            $phone_action_box.html actionTpl
            $phoneBox.html inputTpl
            $("#j-user-phone-ipt").focus()
            $("#j-user-phone-ipt").val _SP.pageData.phone.val
            return false

        # 取消修改
        $(document).on "click","#j-cancel-modify-phone",->
            $phone_action_box.html editActionTpl
            $phoneBox.html phoneNum
            _setVal()
            return false

        $(document).on "keyup","#j-user-phone-ipt",->
            value = $(this).val()
            console.log value.length ==11 , !validator.methods.phone(value)
            if value.length ==11 and !validator.methods.phone(value)
                $(".is_phone_error").text("请输入正确的手机号").show()
            else if value.length > 11
                $(".is_phone_error").text("请输入正确的手机号").show()
            else
                $(".is_phone_error").hide()

        # 提交修改
        $(document).on "click","#j-submit-modify-phone",->
            value = $("#j-user-phone-ipt").val()
            if validator.methods.phone(value)

                # 手机是否存在
                Sp.get Sp.config.host + '/api/member/checkMobile',{
                    mobile: _SP.pageData.phone.val
                },(res)->
                    if res and res.code == 0
                        $(".is_phone_error").text("手机号已被注册").show()
                    else
                        if !verifyPhoneModalBox
                            verifyPhoneModalBox = new VerifyPhoneModalBox
                                top: 250
                                mask: true
                                maskClose: true
                                closeBtn: true
                                phone: _SP.pageData.phone.val
                                success: ()->
                                    _SP.pageData.phone.val = value
                                    $phone_action_box.html editActionTpl
                                    $phoneBox.html phoneNum
                                    $("#j-modify-phone").text "修改"
                                    $(".j-phone-tips").show()
                                    _setVal()
                        verifyPhoneModalBox.show()
            else
                $(".is_phone_error").text("请输入正确的手机号").show()
            ## 调用修改用户名API
            return false

    # 修改密码
    changePassword = ()->
        changePasswordModalBox = null
        $("#j-change-pw").on "click",->
            if !changePasswordModalBox
                changePasswordModalBox = new SetPassWordModalBox
                    top: 250
                    mask: true
                    maskClose: false
                    closeBtn: true
                    success: (res)->
                        if res
                            lightModalBox = new LightModalBox
                                width: 250
                                status: "success"
                                text : "修改密码成功"
                            lightModalBox.show()
            changePasswordModalBox.show()
            return false

    page.init()
