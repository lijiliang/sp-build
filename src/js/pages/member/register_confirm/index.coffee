# 验证邮箱页面逻辑
define ['Sp', 'LightModalBox', 'preLoad'], (Sp, LightModalBox)->
    # 获取邮箱验证码
    $(document).on "click",".j-resend-mail",->
        Sp.post Sp.config.host + '/api/member/sendMail', {
            email: _SP.pageData.email,
            type: 0
        },(res)->
            if(res && res.code == 0)
                lightModalBox = new LightModalBox
                    width: 250
                    status: "success"
                    text : "验证邮件发送成功"
                lightModalBox.show()
            else
                Sp.log "邮箱发送验证码失败"
                lightModalBox = new LightModalBox
                    width: 250
                    status: "error"
                    text : "邮箱发送验证码失败"
                lightModalBox.show()

        return false
