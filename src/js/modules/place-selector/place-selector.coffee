# 配送地
define ['Sp', 'DropDown', './tpl-layout',
        './tpl-item'], (Sp, DropDown, placeSelector_tpl, placeSelector_item)->
    class Destination extends DropDown
        constructor: (@options)->
            that = this
            if typeof @options.noHeader!= "undefined"
                @target_wrap = $(".stock-btn_wrap")
                #初始化
                @target_wrap.find(".stock-btn i").each ->
                    id = $(this).data("id")
                    if id >= 0
                        $(this).closest(".stock-btn").show()
            else
                @target_wrap = $(@options.target)

            # 处理cookie
            region_cookie = {}
            region_cookie.province_id = parseInt $.cookie('region_province_id');
            region_cookie.city_id = parseInt $.cookie('region_city_id');
            region_cookie.district_id = parseInt $.cookie('region_district_id' );
            region_cookie.province_name = $.cookie('region_province_name' );
            region_cookie.city_name = $.cookie('region_city_name');
            region_cookie.district_name = $.cookie('region_district_name' );

            if parseInt(region_cookie.province_id) !=-1
                $("._place_province").data "id",region_cookie.province_id
                $("._place_province").text region_cookie.province_name

                $("._place_city").data "id",region_cookie.city_id
                if parseInt(region_cookie.city_id) !=-1
                    $("._place_city").text region_cookie.city_name
                else
                    $("._place_city").text ""

                $("._place_area").data "id",region_cookie.district_id
                if parseInt(region_cookie.district_id) !=-1
                    $("._place_area").text region_cookie.district_name
                else
                    $("._place_area").text ""


            # 初始化数据
            @areaData = {
                0: {},
                1: {},
                2: {},
                3: {}
            }

            @findData = (id,data,res)=>
                data = data || this.data
                for key,value of data
                    if( parseInt(id) == parseInt(value.id) )
                        res["name"] = value.name
                        res["id"] = value.id
                        res["index"] = key
                    if value.children.length
                        @findData(id,value.children,res)

            @initArea = (callback)=>
                self = this
                $.ajax
                    method: "GET",
                    url: Sp.config.host + "/api/region/region"
                    success: (res)->
                        if(res && res.code==0)
                            self.data = res.data.region
                            self.level = 0
                            self.findData self.target_wrap.find("._place_province").data("id"),self.data,self.areaData["0"]
                            self.findData self.target_wrap.find("._place_city").data("id"),self.data,self.areaData["1"]
                            self.findData self.target_wrap.find("._place_area").data("id") ,self.data,self.areaData["2"]
                            $(".place-arrow-top").css 'left', that.level * 60 + 40
                            callback()

            @options.render = =>
                @getData 0, @level, =>
                    @writeArea()
                    $(document).on "click", ".select-stock-place__hd-txt", ->
                        if($(this).text=="请选择")
                            return false
                        that.level = $(this).index()
                        that.getData that.areaData[that.level].index, that.level, =>
                            that.writeArea()
                            $(".place-arrow-top").css 'left', that.level * 60 + 40
                        return false

            $(@options.target).on "click", ->
                if(that.dropDownBox)
                    if(that.areaData[0].index==-1)
                        that.getData 0, that.level, =>
                            that.writeArea()
                    else
                        that.level = $(this).closest(".stock-btn").index()
                        #console.log($(this),that.level)
                        #console.log that.areaData[that.level].index, that.level
                        that.getData that.areaData[that.level].index, that.level, =>
                            that.writeArea()
                            if(that.options.noHeader)
                                that.show()
                return false

            $(document).on "click", ".select-stock-place__bd li a", ->
                sub = $(this).data("sub")
                if(sub and !that.options.noHeader)
                    that.writeAreaData(that.level,  $(this).data("id"), sub);
                    that.level++
                    that.getData that.areaData[that.level].index, that.level, =>
                        that.writeArea()
                        $(".place-arrow-top").css 'left', that.level * 60 + 40
                else
                    # 打开下一级
                    if(that.options.noHeader and sub)
                        that.writeAreaData(that.level, $(this).data("id"), sub);
                        that.reWriteArea()
                        that.level++
                        that.target_wrap
                            .find(".stock-btn")
                            .eq(that.level)
                            .show()
                            .find(that.options.target)
                            .trigger("click")
                            .find("i")
                            .text("请选择")
                    else
                        that.writeAreaData(that.level, $(this).data("id") );
                        that.reWriteArea()
                        that.competeSelect()
                    #that.competeSelect()
                return false

            $(document).on "click", @options.closeBtn, ->
                that.hide()
                return false

            super
        #
        writeAreaData: (level, id, sub = false)->
            self = this
            self.findData id,self.data,self.areaData[level]
            max = 3
            for num in [max..0]
                if(num > level)
                    self.areaData[num].name = ""
                    self.areaData[num].index = -1
                if(num == level + 1 and sub)
                    self.areaData[num].name = "请选择"

        reWriteArea: ()=>
            @target_wrap.find("._place_province").text(this.areaData[0].name)
            @target_wrap.find("._place_city").text(this.areaData[1].name)
            @target_wrap.find("._place_area").text(this.areaData[2].name)
            @target_wrap.find("._place_town").text(this.areaData[3].name)
            @target_wrap.find("._place_province").data("id",this.areaData[0].id)
            @target_wrap.find("._place_city").data("id",this.areaData[1].id)
            @target_wrap.find("._place_area").data("id",this.areaData[2].id)
            @target_wrap.find("._place_town").data("id",this.areaData[3].id)
            if(@.options.noHeader)
                if(!this.areaData[0].name)
                    @target_wrap.find("._place_province").closest(".stock-btn").hide()
                if(!this.areaData[1].name)
                    @target_wrap.find("._place_city").closest(".stock-btn").hide()
                if(!this.areaData[2].name)
                    @target_wrap.find("._place_area").closest(".stock-btn").hide()
                if(!this.areaData[3].name)
                    @target_wrap.find("._place_town").closest(".stock-btn").hide()
        # 改写省份等
        writeArea: =>
            self = this
            $("#" + @id).find("._place_province").text(this.areaData[0].name)
            $("#" + @id).find("._place_city").text(this.areaData[1].name)
            $("#" + @id).find("._place_area").text(this.areaData[2].name)
            $("#" + @id).find("._place_town").text(this.areaData[3].name)

            $("#" + @id).find ".select-stock-place__hd-txt"
            .eq @.level
            .addClass "_active"
            .siblings ".select-stock-place__hd-txt"
            .removeClass "_active"

            $("#" + @id).find ".select-stock-place__bd li"
            .each ->
                val = $("#" + self.id).find(".select-stock-place__hd-txt").eq(self.level).text()
                if($(this).find("a").text() == val)
                    $(this).addClass("_active")

        # 按级别ID，获取数据
        getData: (index, level, callback = ->)->
            self = this
            if(!self.data)
                self.initArea ()->
                    self.render self.data
                    callback()
            else
                switch level
                    when 0
                        self.render self.data
                    when 1
                        self.render self.data[self.areaData[0].index]["children"]
                    when 2
                        self.render self.data[self.areaData[0].index]['children'][self.areaData[1].index]["children"]
                    when 3
                        self.render self.data[self.areaData[0].index]['children'][self.areaData[1].index]['children'][self.areaData[2].index]["children"]
                callback()

        # show
        show: ()->
            super
        #hide
        hide: ()->
            super

        # 完成选择
        competeSelect: ()->
            this.reWriteArea()
            Sp.setPlaceIdCookie @areaData[0]["id"], @areaData[1]["id"], @areaData[2]["id"]
            Sp.setPlaceNameCookie @areaData[0]["name"], @areaData[1]["name"], @areaData[2]["name"]
            req =
                province:
                    id: if @areaData[0]["name"]!='' then @areaData[0]["id"] else -1
                    name: @areaData[0]["name"]
                city:
                    id: if @areaData[1]["name"]!='' then @areaData[1]["id"] else -1
                    name: @areaData[1]["name"]
                district:
                    id: if @areaData[2]["name"]!='' then @areaData[2]["id"] else -1
                    name: @areaData[2]["name"]
            Sp.setPlaceIdCookie req.province.id, req.city.id, req.district.id
            Sp.setPlaceNameCookie req.province.name, req.city.name, req.district.name
            this.hide()
            if @options.callback?
                @options.callback(req)
            Sp.log "destination success!"
        # 渲染框架
        render: (data)->
            items = placeSelector_item(data)
            items_layout = placeSelector_tpl()
            items_layout = $(items_layout).find(".select-stock-place__bd").html(items).closest(".select-stock-place")
            if(this.options.noHeader)
                items_layout.find(".select-stock-place__hd").hide()
            this.dropDownBox.find(".ui-drop-down-box__inner").html(items_layout)

    return  Destination
