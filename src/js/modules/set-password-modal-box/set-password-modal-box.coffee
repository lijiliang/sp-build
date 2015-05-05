# 模态框
define ['Sp', 'ModalBox', './tpl-layout'], (Sp, ModalBox, setPassWordModalBox_tpl)->
    class setPassWordModalBox extends ModalBox
        constructor: (@options)->
            self = this
            @options.template = setPassWordModalBox_tpl({})
            @options.success = @options.success || ()->
            @options.init = =>
                self = this
                $id = $("#"+this.id)

                $(document).on "click", "#j-set-password", (e)=>
                    e.stopPropagation()
                    e.preventDefault()

                    oldpassword = $id.find("input[name='oldpassword']").val()
                    newpassword = $id.find("input[name='newpassword']").val()
                    repassword = $id.find("input[name='repassword']").val()

                    if !oldpassword.length or !newpassword.length or !repassword.length
                        $id.find(".tips_error").html("密码不能为空")
                        return
                    else if newpassword != repassword
                        $id.find(".tips_error").html("两次输入密码不一致")
                    else if (newpassword.length<6 || newpassword.length>20)
                        $id.find(".tips_error").html("密码长度应在6-20位之间")
                    else
                        $id.find(".tips_error").html("")
                        # 向服务端发送修改密码请求
                        Sp.post Sp.config.host + '/api/member/changePassword', {
                            member_id: _SP.member,
                            old_password: oldpassword,
                            password: newpassword
                        },(res)->
                            if(res && res.code ==0)
                                self.options.success true
                                self.destroy()
                            else
                                self.options.success false
                                $id.find(".tips_error").html( res.msg  )

                    return false;
            super


    return  setPassWordModalBox
