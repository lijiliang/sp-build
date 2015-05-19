# 配送地
define ['Sp'], (Sp)->
    class Validator
        constructor: (options)->
            Sp.log "- widget [validator] loaded -"
            @options = $.extend({},options);
            @checked = true
            if @options.targetFrom
                @targetFrom = $(@options.targetFrom)
                @targetFrom.on "submit", @handleSubmit

        methods:
            name: (val)->
                /^[\u4e00-\u9fa5]{1,10}[·.]{0,1}[\u4e00-\u9fa5]{1,10}$/.test val
            username: (val)->
                /^[a-zA-Z][\w+]{4,16}$/.test val
            password: (val)->
                /^[\@A-Za-z0-9\!\#\$\%\^\&\*\.\~]{6,22}$/.test val
            phone: (val)->
                /^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$/.test val
            tel: (val)->
                /^\d{3}-\d{7,8}|\d{4}-\d{7,8}|(0|86|17951)?(13[0-9]|15[012356789]|17[0678]|18[0-9]|14[57])[0-9]{8}$/.test val
            # matches yyyy-MM-dd
            date: (val) ->
                /^[1-2][0-9][0-9][0-9]-[0-1]{0,1}[0-9]-[0-3]{0,1}[0-9]$/.test val

            email: (val) ->
                /^(?:\w+\-?\.?\+?)*\w+@(?:\w+\.)+\w+$/.test val

            minLength: (val, length) ->
                val.length >= length

            maxLength: (val, length) ->
                val.length <= length

            equal: (val1, val2) ->
                val1 is val2

            required: (val)->
                val.length > 0

            region: (val)->
                val isnt 'fail'

            # 正则检测
            regex: (val,reg) ->
                re = new RegExp reg
                re.test val
        #验证
        verify: (method, val...)->
            this.methods[method].apply this, val

        #显示结果
        resultShow: (result)->
            ##console.log(result)
            this.targetFrom.addClass "j-validator_success"

        # 提交表单
        handleSubmit: (event)=>
            self = this
            fields = this.options.fields
            for el of fields
                self.checked = this.processField.call self, el, fields[el]
                Sp.log self.checked
                if !self.checked
                    break
            self.checked

        # 验证字段
        processField: (el, filters)->
            self = this
            val = $(el).val()
            success = true
            for filter in filters.filters
                args = []
                if( filter.args? and $.isArray(filter.args) )
                    args = filter.args.split(",")
                args.unshift(val)
                args.unshift(filter.filter)
                success = this.verify.apply self, args
                if !success
                    break
            success


    return  Validator
