# 自动补全
define ['Sp', './autoComplete_layout',
        './autoComplete_item'], (Sp, layout_template, item_template)->
    class AutoComplete
        constructor: (@options) ->
            #this.options = {}
            this.options.$target = $(@options.target)
            this.options.width = @options.width or null
            this.options.$input = this.options.$target.find("input[type='text']")
            this.options.source = @options.source
            this.autocomplete_element = null
            this.options.$input.attr('autocomplete', 'off'); #阻止浏览器自己自动补全
            this._ajaxId = 0;
            this._ajaxNowId = 0;
            return this

        ###
        # 获取数据
        ###
        getData: (callback)=>
            self = this
            val = $.trim this.options.$input.val()
            if(typeof(val)!="string" or val == '')
                return callback.call(this,[],self._ajaxId++)
            _id = self._ajaxId++
            $.ajax
                type: "GET"
                async: true
                url: Sp.config.host+"/api/getSuggestion"
                data:
                    q: val
                success: (res)->
                    if res and res.code == 0
                        data = res.data
                        return callback.call(this,data,_id)
                    else
                        return callback.call(this,[],_id)
        ###
        # KeyUp hander
        ###
        keyUpHander: (event)=>
            #console.log event.keyCode
            switch event.keyCode
                #enter
                when 13
                    this.completeInput()
                    event.stopPropagation()
                #up
                when 38
                    this.moveSelected("up")
                    event.stopPropagation()
                #down
                when 40
                    this.moveSelected("down")
                    event.stopPropagation()
                #esc
                when 27
                    this.listClear()
                    this.stopPropagation()
                else
                    AutoComplete.prototype.listLoad.call this, null
        ###
        # KeyDown hander
        ###
        keyDownHander: (event)=>
            ###switch event.keyCode
                #enter
                when 13
                    Sp.log 13
                #up
                when 38
                    Sp.log 38
                #down
                when 40
                    Sp.log 40
                #esc
                when 27
                    Sp.log 27###
            return this
        ###
        # resize hander
        ###
        resizeHander:(event)=>
            if(this.autocomplete_element)
                this.autocomplete_element.css
                    top: this.options.$target.offset().top + this.options.$target.height()
                    left: this.options.$target.offset().left - 1
        ###
        # Focus hander
        ###
        focusHander: (event)=>
            AutoComplete.prototype.listLoad.call this, null
        ###
        # Blur hander
        ###
        blurHander: (event)=>
            $(document).on 'click', this.listHide
        ###
        # MouseEnter hander
        ###
        mouseenterHander: (event)=>
            item = $(event.delegateTarget)
            this.selectItem(item)
        ###
        # 隐藏列表
        ###
        listHide: (event)=>
            autocomplete_element = $(".autocomplete-box")
            autocomplete_element.hide()
        ###
        # 加载列表
        ###
        listLoad: ->
            self = this
            val = $.trim this.options.$input.val()
            if( !self.autocomplete_element or !self.autocomplete_element.length)
                tpl = layout_template({})
                $("body").append(tpl)
                self.autocomplete_element = $(".autocomplete-box")

                displayVal = "none"
                if(val.length)
                    displayVal = "block"
                self.autocomplete_element.css
                    display: displayVal
                    width: (self.options.width || self.options.$target.width())+2
                    top: self.options.$target.offset().top + self.options.$target.height()
                    left: self.options.$target.offset().left - 2
                # 关闭
                $(document).on "click",'.autocomplete-box .close', ->
                    self.listClear()
                    return false

            self.getData (data,ajax_id)->
                if self._ajaxNowId > ajax_id
                    return self
                else
                    # 保证取到的是最新的请求数据
                    self._ajaxNowId = ajax_id
                    if !data.length
                        self.listClear()
                    else
                        self.autocomplete_element.show()
                        tpl = item_template(data)
                        self.autocomplete_element.find("tbody").html(tpl)
                        self.autocomplete_element.find("tbody tr").first().addClass("_selected")
                        # 鼠标选择
                        self.autocomplete_element.find("tbody tr").off "mouseenter"
                        .on "mouseenter", self.mouseenterHander
                        # 点击选择
                        self.autocomplete_element.find("tbody tr").off "click"
                        .on "click", self.completeInput
            return self
        ###
        # 清除列表
        ###
        listClear: ->
            this.autocomplete_element.find("tbody").html("")
            this.listHide()
        ###
        # 移动选择列表
        ###
        moveSelected: (direction)->
            if(!this.autocomplete_element)
                return false;
            switch direction
                when "up"
                    item = this.autocomplete_element.find("tbody tr._selected").prev()
                    # 循环选择
                    if(item.length <= 0)
                        item = this.autocomplete_element.find("tbody tr").last()
                    this.selectItem(item)
                when "down"
                    item = this.autocomplete_element.find("tbody tr._selected").next()
                    if(item.length <= 0)
                        item = this.autocomplete_element.find("tbody tr").first()
                    this.selectItem(item)
        ###
        # 选中
        ###
        selectItem: (item)->
            this.autocomplete_element.find("tbody tr").removeClass "_selected"
            $(item).addClass "_selected"
            return this
        ###
        # 完成
        ###
        completeInput: (event)=>
            text = this.autocomplete_element.find("tbody tr._selected .text").text()
            this.options.$input.val(text)
            this.listClear()
            $("#header-search-form").submit();
        ###
        # 渲染框架
        ###
        render: ->
            this.options.$input.on "keyup", this.keyUpHander
            this.options.$input.on "keydown", this.keyDownHander
            this.options.$input.on "blur", this.blurHander
            this.options.$input.on "focus", this.focusHander
            $(window).on "resize", this.resizeHander
            return this


    return  AutoComplete
