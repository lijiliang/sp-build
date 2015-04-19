# 模态框
define ['Sp', 'ModalBox', './setPhoneModalBox_tpl','./setPhoneModalBox_code','./setPhoneModalBox_phone',
        'VerifyPhoneModalBox'], (Sp, ModalBox, setPhoneModalBox_tpl, setPhoneModalBox_code, setPhoneModalBox_phone,VerifyPhoneModalBox)->
    class setPhoneModalBox extends ModalBox
        constructor: (@options)->
            self = this
            @options.template = setPhoneModalBox_tpl({})
            @options.init = =>
                setPhoneModalBox_codeHtml = setPhoneModalBox_code({})
                setPhoneModalBox_phoneHtml = setPhoneModalBox_phone({})
                $id = $("#"+this.id)
                $id.find(".common-modal-box__content").append(setPhoneModalBox_codeHtml)
                tipsElement = $("#"+@id).find(".tips")
                defaultHtml = '请填写你收到的手机验证码'

                tipsElement.html defaultHtml

                #验证原来的手机
                $(document).on "click","#j-getPhoneCode",=>
                    that = this
                    code_val = $id.find("input[name='code']").val()

                    if(code_val.length)
                        # 验证原来的手机
                        Sp.post Sp.config.host + "/api/sendSms",{
                            member_id:_SP.member,
                            code: code_val
                        },(res)->
                            if res and res.code ==0
                                $id.find(".common-modal-box__content").html(setPhoneModalBox_phoneHtml)
                                tipsElement.html "请输入你新的手机号码，接收验证码"
                            else
                                $id.find(".tips_error").html("发送验证码不成功，请重试")
                    else
                        $id.find(".tips_error").html("请输入验证码")
                    return false;

                # 向新的手机发送手机验证码
                $(document).on "click", "#j-getNewPhone",=>
                    phone_val = $id.find("input[name='phone']").val()
                    if(self.phone(phone_val))
                        Sp.post Sp.config.host + "/api/sendSms",{
                            member_id: _SP.member,
                            phone: phone_val
                        },(res)->
                            if(res and res.code ==0 )
                                self.destroy()
                                verifyPhoneModalBox = new VerifyPhoneModalBox
                                    top: 250
                                    mask: true
                                    maskClose: false
                                    closeBtn: true
                                    phone: phone_val
                                verifyPhoneModalBox.show()
                            else
                                $id.find(".tips_error").html("验证码发送不成功，请重试!")
                    else
                        $id.find(".tips_error").html("请输入正确的手机号码")
                    return false
            super

        phone: (val)->
            /^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$/.test val


    return  setPhoneModalBox
