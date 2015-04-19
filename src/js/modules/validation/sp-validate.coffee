# @tofishes
# 封装定制后的validation
# 官方地址： http://jqueryvalidation.org/
define ['Sp', 'jQValidation'], (Sp)->

    # 中文语言包
    $.extend($.validator.messages, {
        required: "必须填写",
        remote: "请修正此栏位",
        email: "请输入有效的电子邮件",
        url: "请输入有效的网址",
        date: "请输入有效的日期",
        dateISO: "请输入有效的日期 (YYYY-MM-DD)",
        number: "请输入正确的数字",
        digits: "只可输入数字",
        creditcard: "请输入有效的信用卡号码",
        equalTo: "你的输入不相同",
        extension: "请输入有效的后缀",
        maxlength: $.validator.format("最多 {0} 个字"),
        minlength: $.validator.format("最少 {0} 个字"),
        rangelength: $.validator.format("请输入长度为 {0} 至 {1} 之間的字串"),
        range: $.validator.format("请输入 {0} 至 {1} 之间的数值"),
        max: $.validator.format("请输入不大于 {0} 的数值"),
        min: $.validator.format("请输入不小于 {0} 的数值")
    })


    $.validator.addMethod "mobilephone", (value, element) ->
        return this.optional(element) || /^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$/.test(value)
    , "请填写正确的手机号码"

    $.validator.addMethod "realname", (value, element) ->
        return this.optional(element) || /^[\u4e00-\u9fa5]{1,10}[·.]{0,1}[\u4e00-\u9fa5]{1,10}$/.test(value)
    , "请填写中文姓名"

    # 另外一个email正则： /[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/
    # http://stackoverflow.com/a/1373724
    $.validator.addMethod "email", (value, element) ->
        return this.optional(element) || /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/.test(value)
    , "请输入有效的电子邮件"

    $.validator.addMethod "username", (value, element) ->
        return this.optional(element) || /^[a-zA-Z][\w+]{4,16}$/.test(value)
    , "用户名只能是4-16位数字和字母组成的"

    $.validator.addMethod "password", (value, element) ->
        return this.optional(element) || /^[\@A-Za-z0-9\!\#\$\%\^\&\*\.\~]{6,22}$/.test(value)
    , "6-20位字符，建议使用字母加数字或者符号组合"

    $.validator.addClassRules
        'valid-mobile':
            'mobilephone': true

    $.validator.setDefaults
        'ignore': '.ignore', # 忽略验证selector
        'errorElement': 'p',
