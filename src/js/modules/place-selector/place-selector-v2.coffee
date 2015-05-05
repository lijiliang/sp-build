# 配送地
define ['Sp', 'DropDown', './tpl-layout',
        './tpl-item','./place-selector'], (Sp, DropDown, placeSelector_tpl, placeSelector_item)->

    class PlaceSelector extends DropDown
        constructor: (@options)->
            self  = this
            this.target = $(@options.target)
            this.mode = @options.mode || 1
            this.callback = @options.callback || ->
            this.initCookie = @options.initCookie || ->
            this.clickEl = this.target.find("._place_click")
            this.data = null
            this.level = 0
            # 返回数据结构
            this.result = {
                province:{
                    id: -1,
                    name:"请选择"
                },
                city:{
                    id: -1,
                    name:"请选择"
                },
                district:{
                    id: -1,
                    name:"请选择"
                }
            }

            ###_SP.region = {
                province_id: -1,
                province_name: "省份",
                city_id:-1,
                city_name: "市",
                district_id: -1,
                district_name: "区"
            }###

            # 处理cookie
            region_cookie = {}
            if _SP.region != undefined and _SP.region.province_id != -1
                region_cookie.province_id =  parseInt _SP.region.province_id
                region_cookie.city_id = parseInt _SP.region.city_id
                region_cookie.district_id = parseInt _SP.region.district_id
                region_cookie.province_name = _SP.region.province_name
                region_cookie.city_name = _SP.region.city_name
                region_cookie.district_name = _SP.region.district_name
            else
                region_cookie.province_id =  parseInt $.cookie('region_province_id');
                region_cookie.city_id = parseInt $.cookie('region_city_id');
                region_cookie.district_id = parseInt $.cookie('region_district_id' );
                region_cookie.province_name = $.cookie('region_province_name' );
                region_cookie.city_name = $.cookie('region_city_name');
                region_cookie.district_name = $.cookie('region_district_name' );
            console.log region_cookie
            console.log '&&&&&&&'
            console.log self.target
            if parseInt(region_cookie.province_id) !=-1
                $("._place_province").data "id",region_cookie.province_id
                $("._place_province").text region_cookie.province_name
                self.target.find('input.province-value').val region_cookie.province_id

                $("._place_city").data "id",region_cookie.city_id
                self.target.find('input.city-value').val region_cookie.city_id
                if parseInt(region_cookie.city_id) !=-1
                    $("._place_city").text region_cookie.city_name
                else
                    $("._place_city").text "请选择"

                $("._place_district").data "id",region_cookie.district_id
                self.target.find('input.district-value').val region_cookie.district_id
                if parseInt(region_cookie.district_id) !=-1
                    $("._place_district").text region_cookie.district_name
                else
                    $("._place_district").text "请选择"
                this.initCookie region_cookie
            else
                this.initCookie false

            super
            $(@options.target).each ->
                $(this).off "click"


            @options.render = ()=>


            #初始化数据
            _initData = ->
                self.target.find("i").each ->
                    id = $(this).data("id")
                    console.log '********'
                    console.log self.result
                    if id > 0
                        $(this).closest("._place_box").show()
                    # 省
                    if $(this).hasClass "_place_province"
                        if id >0
                            self.result.province.id = id
                            self.result.province.name = $(this).text()
                        else
                            self.result.province.id = -1
                            self.result.province.name = "请选择"
                            $(this).text "请选择"
                    # 市
                    if $(this).hasClass "_place_city"
                        if id >0
                            self.result.city.id = id
                            self.result.city.name = $(this).text()
                        else
                            self.result.city.id = -1
                            self.result.city.name = "请选择"
                            $(this).text "请选择"
                    # 区
                    if $(this).hasClass "_place_district"
                        if id >0
                            self.result.district.id = id
                            self.result.district.name = $(this).text()
                        else
                            self.result.district.id = -1
                            self.result.district.name = "请选择"
                            $(this).text "请选择"

            _writeHtml = ->
                console.log '----------'
                console.log self.result
                self.target.find("._place_province").data "id", self.result.province.id
                self.target.find("._place_province").text self.result.province.name
                self.target.find('input.province-value').val self.result.province.id

                self.target.find("._place_city").data "id", self.result.city.id
                self.target.find("._place_city").text self.result.city.name
                self.target.find('input.city-value').val self.result.city.id

                self.target.find("._place_district").data "id", self.result.district.id
                self.target.find("._place_district").text self.result.district.name
                self.target.find('input.district-value').val self.result.district.id

                if self.result.city.id == -1
                    self.target.find("._place_box").eq(2).hide()
                else
                    self.target.find("._place_box").eq(2).show()

            _findData = (id,data,res)=>
                console.log '000000000'
                data = data || self.data
                console.log data
                for key,value of data
                    if( parseInt(id) == parseInt(value.id) )
                        res["name"] = value.name
                        res["id"] = value.id
                        #res["index"] = key
                    if value.children.length
                        _findData(id,value.children,res)


            _hignLight = (type)=>
                res = self.result[type]
                $(".select-stock-place__bd li a").each ->
                    data = $(this).data()
                    console.log '1111111111'
                    console.log data, res
                    if data.id == res.id
                        $(this).closest("li").addClass "_active"
                    else
                        $(this).closest("li").removeClass "_active"

            _showFrame = (that,callback)->
                self._getData self.level, (res)->
                    if res.length
                        self.options.$target = $("._place_box").eq(self.level).find("._place_click")
                        if !self.dropDownBox
                            self.render_layout()
                        self._render res
                        type = $(that).find("i").data("type")
                        _hignLight(type)
                        self.show()
                        self.dropDownBox.show()
                    else
                        $(that).closest("._place_box").hide()
                        self._competeSelect();
                        self.hide()

            _bindEvent = ->
                # 弹出
                self.clickEl.on "click",->
                    that = this
                    if self.level ==$(this).closest("._place_box").index() and  self.dropDownBox and  !self.dropDownBox.is(":hidden")
                        self.hide()
                    else
                        self.level = $(this).closest("._place_box").index()
                        #id = $(that).find("i").data("id")
                        _showFrame(that)

                #关闭
                $(document).on "click",".close",->
                    self.hide()

                # 选中
                $(document).on "click", ".select-stock-place__bd li a", ->
                    data = $(this).data()
                    console.log '3333333333'
                    console.log self.result
                    console.log data
                    if self.level ==0
                        _findData data.id, self.data, self.result.province
                        self.result.city.id = -1
                        self.result.city.name = "请选择"
                        self.result.district.id = -1
                        self.result.district.name = "请选择"
                    else if self.level ==1
                        _findData data.id, self.data, self.result.city
                        self.result.district.id = -1
                        self.result.district.name = "请选择"
                    else
                        _findData data.id, self.data, self.result.district
                    _writeHtml()
                    # 位置
                    if self.level<2
                        self.level++
                        # 是否有下一级
                        $("._place_box").eq(self.level).show()
                        _showFrame $("._place_box").eq(self.level).find("._place_click")[0]
                    else
                        self.hide()
                        self._competeSelect();

            _init = ->
                _initData()
                _bindEvent()

            _init()



        # 获取数据
        _getData: (level,callback)->
            self = this

            _get = (level)->
                if level ==0
                    return self.data
                if level ==1
                    for item in self.data
                        if item.id == parseInt(self.result.province.id)
                            return item.children
                if level ==2
                    for item in self.data
                        if item.id == parseInt(self.result.province.id)
                            for child in item.children
                                if child.id == parseInt(self.result.city.id)
                                    return child.children

            if(!self.data)
                Sp.get Sp.config.host + "/api/region/region",{

                },(res)->
                    if res && res.code ==0
                        self.data  = res.data.region
                        callback _get level
            else
                callback _get level


        # 渲染弹框
        _render: (data)->
            self = this
            self.render_layout()
            items = placeSelector_item(data)
            layout = placeSelector_tpl()
            layout = $(layout).find(".select-stock-place__bd").html(items).closest(".select-stock-place")
            layout.find(".select-stock-place__hd").hide()
            self.dropDownBox.find(".ui-drop-down-box__inner").html(layout)

        # 完成选择
        _competeSelect: ()->
            if @options.callback?
                @options.callback(this.result)
            Sp.setPlaceIdCookie this.result.province.id, this.result.city.id, this.result.district.id
            Sp.setPlaceNameCookie this.result.province.name, this.result.city.name, this.result.district.name
            Sp.log "place select success!"


    return  PlaceSelector
