# 下拉选择框 SelectBox
define ['Sp','LightModalBox','./tpl-new-address','Validator','PlaceSelector_v2','Placeholder'], (Sp, LightModalBox, newAddressTpl, Validator, PlaceSelector_v2, Placeholder)->
    member_id = _SP.member
    name = 'newAddress'
    #API
    host = Sp.config.host
    #host = 'http://admin.sipin.benny:8000'
    #host = 'http://sipin.frontend'

    Api =
        checkDelivery: 'checkDelivery'
        createAddress: 'member/address/create'
        updateAddress: 'member/address/update'

    Action =
        baseUrl: host + '/api/'
        path: Api
        fn: (res)->
            #console.log res

        checkDelivery: (data)->
            Sp.get @baseUrl + @path.checkDelivery, data, @fn, @fn

        createAddress: (data)->
            Sp.post @baseUrl + @path.createAddress, data, @fn, @fn

        updateAddress: (data)->
            Sp.post @baseUrl + @path.updateAddress, data, @fn, @fn

    showMsg = (text, status)->
        modal = new LightModalBox
            #width: 180
            text: text
            status: status
            closedCallback: ()->
                #$('#' + modal.id).remove()
                modal = null
        modal.show()

    class NewAddress
        constructor: (options)->
            if !options.el
                #console.log 'el is null'
                return false
            @data = options.data || {}
            @options = $.extend {}, @defaults, @options, options
            @_init() if !@_newAddress


        defaults:
            el: null
            name: name
            type: 'create' # 'create','update'
            data: {}
            saveSuccessThenDestroy: 1
            successTpl: '<span class="form-success-tips u-ml_5 iconfont u-color_green">&#xe615;</span>'
            callback: (value)->
                #console.log 'defaults.callback ' + 'value: ' + value
            cancelCallback: ()->
                #console.log 'defaults.callback cancel'
            validateFalseCallback: ()->


        _init: ()->
            @_initElements()
            @_initPlaceSelector()
            @_initValue() if @options.type is 'update'
            @_bindEvt()
            @_newAddress = @
            @

        _initElements: ()->
            @$container = $ @options.el
            tpl = newAddressTpl @data
            @$container.append tpl
            @$el = @$container.find '.order-info__form'

            @$save = @$el.find '.j-address-save'
            @$cancel = @$el.find '.j-address-cancel'

            @$name = @$el.find 'input[name=name]'
            @$region = @$el.find 'input[name=region]'
            @$address = @$el.find 'input[name=address]'
            @$mobile = @$el.find 'input[name=mobile]'
            @$second_mobile = @$el.find 'input[name=second_mobile]'
            @$email = @$el.find 'input[name=email]'
            @$formIpts = @$el.find '.form-text'
            @$formIptsRequired = @$el.find '.form-text._required'
            @$formIptsNotRequired = @$el.find('.form-text').not '._required'

            @

        _initValue: ()->
            console.log @options.data
            _this = @

            if @options.data.province_id
                _this.province_id = @options.data.province_id
                _this.province_name = @options.data.province_name
                _this.city_id = @options.data.city_id
                _this.city_name = @options.data.city_name
                _this.district_id = if @options.data.district_id == -1 then "" else @options.data.district_id
                _this.district_name = if @options.data.district_id == -1 then "" else @options.data.district_name
            @


        _rules: ()->
            rules =
                name:[
                    filter: 'required'
                    msg: '不能为空'
                ,
                    filter: 'minLength'
                    msg: '长度必须是2-25个字符'
                    param: 2
                ,
                    filter: 'maxLength'
                    msg: '长度必须是2-25个字符'
                    param: 25
                ]
                region:[
                    filter: 'required'
                    msg: '请选择区域'
                ,
                    filter: 'region'
                    msg: '该地区不支持配送'
                ]
                address:[
                    filter: 'required'
                    msg: '不能为空'
                ]
                mobile:[
                    filter: 'required'
                    msg: '不能为空'
                ,
                    filter: 'phone'
                    msg: '手机号码格式不正确'
                ]
                second_mobile:[
                    filter: 'tel'
                    msg: '备用号码格式不正确'
                ]
                email:[
                    filter: 'email'
                    msg: '邮箱格式不正确'
                ]


        _validate: (val, filters)->
            @validator = new Validator if !@validator
            ret = [true]
            isRequired = false
            if filters && filters.length
                for item in filters
                    isRequired = true if item.filter is 'required'
                    if item.param
                        ret[0] = @validator.methods[item.filter] val, item.param
                    else
                        ret[0] = @validator.methods[item.filter] val
                    if !ret[0]
                        ret[1] = item.msg
                        break
            if !isRequired and val is ''
                ret = [true]
            ret

        _iptValidate: (el, filters)->
            _this = @
            ret = true
            $el = $ el
            value = $el.val()
            $parent = $el.parent()
            $error = $parent.find '.error'
            $success = $parent.find '.form-success-tips'
            if !$error.length
                $parent.append '<span class="error u-color_red u-ml_10"></span>'
                $error = $parent.find '.error'
            validation = @_validate value, filters[$el.attr 'name']
            if !validation[0]
                $success.remove()
                $error.html validation[1]
                ret = false
            else
                $error.remove()
                $parent.append @options.successTpl if !$success.length and value isnt ''
            ret

        _othersValidate: (el, value, filters)->

        _initPlaceSelector : ()->
            _this = @
            if @data.province_id and @data.province_id isnt -1
                _SP.region =
                    province_id: @data.province_id
                    province_name: @data.province_name
                    city_id: @data.city_id
                    city_name: @data.city_name ,
                    district_id: @data.district_id ,
                    district_name: @data.district_name

            @placeSelector = new PlaceSelector_v2
                target: "#j-place-selector"
                mode: 2,
                initCookie: (data)->
                    console.log data
                    region_id = if data.district_id is -1 then data.city_id else data.district_id
                    if region_id and region_id isnt -1
                        Action.checkDelivery
                            region_id: region_id
                        .done (res)->
                            console.log res
                            if res.code == 0 && res.data isnt null
                                _this.$region.val JSON.stringify data
                                #验证信息
                                _this._iptValidate _this.$region, _this._rules()

                                _this.province_id = data.province_id
                                _this.province_name = data.province_name
                                _this.city_id = data.city_id
                                _this.city_name = data.city_name
                                if data.district_id and data.district_id isnt -1
                                    _this.district_id = data.district_id
                                    _this.district_name = data.district_name
                                @
                                #showMsg '该地区可以配送','success'
                            else
                                _this.$region.val 'fail'
                                #验证信息
                                _this._iptValidate _this.$region, _this._rules()

                                _this.province_id = ''
                                _this.province_name = ''
                                _this.city_id = ''
                                _this.city_name = ''
                                _this.district_id = ''
                                _this.district_name = ''
                                showMsg '该地区无法配送','error'

                        .fail (res)->
                callback: (data)->
                    $ '#j-place-selector'
                    .siblings('.error').remove()
                    $ '#j-place-selector'
                    .siblings('.form-success-tips').remove()
                    #console.log data
                    region_id = if data.district.id == -1 then data.city.id else data.district.id
                    Action.checkDelivery
                        region_id: region_id
                    .done (res)->
                        if res.code == 0 && res.data isnt null
                            _this.$region.val JSON.stringify data
                            #验证信息
                            _this._iptValidate _this.$region, _this._rules()

                            _this.province_id = data.province.id
                            _this.province_name = data.province.name
                            _this.city_id = data.city.id
                            _this.city_name = data.city.name
                            _this.district_id = if data.district.id == -1 then "" else data.district.id
                            _this.district_name = if data.district.id == -1 then "" else data.district.name
                            @
                            #showMsg '该地区可以配送','success'
                        else
                            _this.$region.val 'fail'
                            #验证信息
                            _this._iptValidate _this.$region, _this._rules()

                            _this.province_id = ''
                            _this.province_name = ''
                            _this.city_id = ''
                            _this.city_name = ''
                            _this.district_id = ''
                            _this.district_name = ''
                            showMsg '该地区无法配送','error'

                    .fail (res)->






        save: ()->
            _this = @

            success = true
            _this.$formIpts.each (i, item)->
                if !_this._iptValidate item, _this._rules()
                    success = false
                @
            if success
                _this.$save.hide()
                _this.$cancel.hide()
                postData = $.extend _this.options.data,
                    member_id: member_id
                    province_id: _this.province_id
                    province_name: _this.province_name
                    city_id: _this.city_id
                    city_name: _this.city_name
                    district_id: _this.district_id
                    district_name: _this.district_name
                    address: _this.$address.val()
                    consignee: _this.$name.val()
                    mobile: _this.$mobile.val().toString()
                    second_mobile: _this.$second_mobile.val()
                    email: _this.$email.val()
                    is_default: 1
                if _this.options.type is 'create'
                    action = 'createAddress'
                else if _this.options.type is 'update'
                    action = 'updateAddress'
                    postData.id = _this.options.data.id
                else if _this.options.type is 'updateOrder'
                    action = 'updateAddress'
                    postData.id = _this.options.data.id
                    postData.status = 1
                    postData.order_id = _this.options.order_id

                console.log postData
                Action[action](postData)
                .done (res)->
                    if res.code is 0
                        _this._destroy() if _this.options.type isnt 'updateOrder'
                        _this._onCallback res.data
            else
                _this._onCallback null,'validateFalse'

        _bindEvt: ()->
            _this = @

            @$formIpts.placeholder customClass: 'u-placeholder-fix'
            @$formIpts
            .on 'blur', (e)->
                _this._iptValidate @, _this._rules()

            @$save.on 'click', ()=>
                @save()
            #取消
            @$cancel.on 'click', ()=>
                _this._destroy() if _this.options.saveSuccessThenDestroy
                _this._onCallback null,'cancel'


            @

        _offEvt: ()->

            @

        _onCallback: (value, type)->
            switch type
                when 'cancel' then @options.cancelCallback.call(@$container) if typeof @options.cancelCallback is 'function'
                when 'validateFalse' then @options.validateFalseCallback.call(@$container) if typeof @options.validateFalseCallback is 'function'
                else @options.callback.call(@$container, value) if typeof @options.callback is 'function'

        _destroy: ()->
            @$el.empty().remove()
            if @options.el._newAddress
                delete @options.el._newAddress


    #export to JQ
    $.fn.newAddress = (options, options2)->
        ret = @
        @each ()->
            if typeof options is 'string' && @_newAddress
                switch options
                    when 'off' then @_newAddress._offEvt()
            else
                opts = $.extend {},options,{el: @}
                newAddress = @_newAddress
                if !newAddress
                    newAddress = new NewAddress(opts)
                else
                    #@_newAddress.reset(opts)
                @_newAddress = newAddress
        return ret



    Fn = (options)->
        if options.el
            $el = $ options.el
            return $el.each ()->
                opts = $.extend {},options,{el: @}
                newAddress = @_newAddress
                if !newAddress
                    newAddress = new NewAddress(opts)
#                else
#                    @_newAddress.reset(opts)
                @_newAddress = newAddress
        else
            Sp.log 'el is null'
            return false

    Fn
