# 商品详情页面逻辑
define ['Sp',
        'Tab',
        'Amount',
        'goodTypeSelect',
        'PlaceSelector',
        'LightModalBox',
        'goodApi',
        'Swipe',
        'LoginModalBox'
        'modules/sliderList/sliderList'
        'goodSlider', 'preLoad'], ( Sp, Tab, Amount, GoodTypeSelect, PlaceSelector, LightModalBox, goodApi, Swipe, LoginModalBox, SliderList, goodSlider)->
    page = ->

        # 初始化页面
    page.init = ->

        # 选顶卡
        tab = new Tab
            target: ".good-detail-extend"
            callback: (index)->
                $('.good-detail-tab__text').eq index
                .addClass '_active'
                .closest ".ui-tab__item"
                .siblings ".ui-tab__item"
                .find ".good-detail-tab__text"
                .removeClass '_active'

        # 图片切换
        # goodSlider.init();
        # 图片切换 V2
        initSliderList = ()->

            $slierList = $ '#j-slider-list'
            goodsPhotos = _SP.goodsPhotos
            imgParam = '?imageView2/1/h/80/w/80'
            speed = 100
            if $slierList.length
                $win = $ window
                winWidth = $win.width()

                $wrapper = $ '.goods-photos'

                if winWidth > 1200
                    $wrapper.removeClass '_small'
                    React.render(
                        React.createElement(SliderList, {
                            layout: 'vertical'
                            imgs: goodsPhotos
                            imgParam: imgParam
                            speed: speed
                            callback: initSliderListCallback
                        }),
                        $slierList[0]
                    );

                else
                    $wrapper.addClass '_small'
                    React.render(
                        React.createElement(SliderList, {
                            layout: 'horizontal'
                            imgs: goodsPhotos
                            imgParam: imgParam
                            speed: speed
                            callback: initSliderListCallback
                        }),
                        $slierList[0]
                    );
        initSliderListCallback = (index, imgs)->
            $img = $ '#j-goods-photos__preview'
            $img[0].src = imgs[index]+'?imageView2/1/w/800'
            # console.log index, imgs[index]

        initSliderList()
        sliderResizeTimer = null
        $(window).on 'resize.initSliderList', ()->
            clearTimeout sliderResizeTimer if sliderResizeTimer isnt null
            setTimeout initSliderList, 480


        # SKU选择
        skuSelect = GoodTypeSelect()

        # 数量选择
        amount = new Amount
            target: ".amount-box"
            callback: (res)->
                # 快速购买配置
                $("#j-buy-now-form").find("input[name='goods_sku_quantity']").val res


        # 查询物流费
        getDelivery = (id,callback)->
            Sp.get Sp.config.host + "/api/price/getDelivery",{
                goods_sku_id: _SP.skuid,
                region_id: id
            },(dilivery)->
                if callback
                    callback(dilivery)


        # 默认物流费
        _regionId = parseInt $("._place_area").data("id") || parseInt $("._place_city").data("id")

        # 处理cookie
        if $.cookie('region_district_id' )!=-1
            _regionCookieId = parseInt $.cookie('region_district_id' )
        else
            _regionCookieId = parseInt $.cookie('region_city_id')

        if _regionCookieId
            _regionId = _regionCookieId;

        if _regionId
            getDelivery _regionId,(dilivery)->
                if dilivery and dilivery.code ==0
                    dilivery = dilivery.data
                    if(dilivery == -1)
                        console.log("此地区暂时不支持配送")
                    else
                        $("#j-delivery").text(dilivery+".00")
                else
                    Sp.log("没有获取到配送信息")

        # 地区选择
        placeSelect = new PlaceSelector
            target: "#stock-btn .btn"
            closeBtn: ".close"
            callback: (res)->
                regionId = if parseInt(res.district.id)!=-1 then res.district.id else if parseInt(res.city.id) !=-1 then res.city.id
                if regionId
                    #查询物流费
                    getDelivery regionId,(dilivery)->
                        if dilivery and dilivery.code ==0
                            dilivery = dilivery.data
                            if(dilivery == -1)
                                alert("此地区暂时不支持配送")
                            else
                                $("#j-delivery").text(dilivery+".00")
                        else
                            Sp.log("没有获取到配送信息")

                    # 快速购买配置
                    $("#j-buy-now-form").find("input[name='region']").val regionId
                else
                    Sp.log "获取地区信息失败"

        ###$(".help-link").on "mouseenter", ->
            tooltip_tpl = '<div class="tooltip-box">' +
                    '<i class="tip-arrow-top"></i>' +
                    '<div class="tip-content">' +
                    '</div>' +
                    '</div>';

            if(!$(".tooltip-box").length)
                $("body").append(tooltip_tpl)

            top = $(this).offset().top
            left = $(this).offset().left

            $(".tooltip-box").find(".tip-content").html("<p>假舆马者，非利足也，而致千里；假舟楫者，非能水也，而绝江河。君子生非异也，善假于物也。</p>");

            $(".tooltip-box").css
                position: "absolute"
                left: left - 10
                top: top + 30
            .show()

        $(".help-link").on "mouseleave", ->
            $(".tooltip-box").remove()###

        # 模板图片切换
        $tplSwipe = $('#j-tpl-swipe')
        $tplSwipePrev = $tplSwipe.find ".swipe-actions__prev"
        $tplSwipeNext = $tplSwipe.find ".swipe-actions__next"
        if $tplSwipe.find('.swipe-item').length > 1
            tplSwipe = new Swipe $tplSwipe[0],
                startSlide: 0
                speed: 400
                auto: 0
                continuous: true
                disableScroll: false
                stopPropagation: false
                callback: (index, elem)->

            $tplSwipePrev.on 'click', ->
                tplSwipe.prev();
                return false;

            $tplSwipeNext.on 'click', ->
                tplSwipe.next();
                return false;
        else
            $tplSwipePrev.hide()
            $tplSwipeNext.hide()

        ###
        # 加入购物车
        ###
        addCartBox = null
        $("#j-add-to-cart").on "click",()->
            if $(this).hasClass("_disable")
                return false
            count = $("#count").val();
            price = $.trim($("#price").text().replace(/\¥/g, ''));
            total_price = Sp.Calc.Mul(count, price);

            goodApi.addcart(_SP.skuid, count, $("#goodTitle").text(), total_price)
            .done (res)->
                if res.code == 0
                    $cartBtn = $ '#j-cart-btn'
                    $cartBtn.cart 'setShouldUpdate' if $cartBtn.length
            return false

        ###
        # 立即购买
        ###
        loginBox = null
        $("#j-buy-now").on "click",()->
            if _SP.member
                $("#j-buy-now-form").submit()
            else
                # 登录框
                if !loginBox
                    loginBox = new LoginModalBox
                        width: 440
                        top: 250
                        mask: true
                        closeBtn: true
                        loginSuccessCallback: ()->
                            $("#j-buy-now-form").submit()
                loginBox.show()
            return false

        ###
        # 收藏商品
        ###
        $("#j-add-to-likelist").on "click",()->
            goodApi.addlike _SP.goodid, (res)->
                if res
                    $("#j-add-to-likelist").hide()
                    $("#j-remove-to-likelist").show()
            return false

        ###
        # 取消收藏商品
        ###
        $("#j-remove-to-likelist").on "click",()->
            goodApi.removelike _SP.goodid, (res)->
                if res
                    $("#j-add-to-likelist").show()
                    $("#j-remove-to-likelist").hide()
            return false

        ###
        # 商品详情跳转
        ###
        _jumpSaleBlack = (tab,hash)->
            $('.good-detail-tab__text').eq tab
                .addClass '_active'
                .closest ".ui-tab__item"
                .siblings ".ui-tab__item"
                .find ".good-detail-tab__text"
                .removeClass '_active'

            $(".good-detail-extend__content")
                .find(".ui-tab-container__item")
                .eq(tab)
                .show()
                .siblings()
                .hide()

            location.hash = hash;

        $(document).on "click", "#j-detail-keep", ()->
            _jumpSaleBlack(2,'upkeep')

        $(document).on "click", "#j-detail-install", ()->
            _jumpSaleBlack(2,"installation")

        $(document).on "click", "#j-detail-delivery", ()->
            _jumpSaleBlack(2,"delivery")

        $(document).on "click", "#j-detail-buy-flow", ()->
            _jumpSaleBlack(2,"shoping-flow")
        `
        var tabsClass = {
            'container': '.tabs',
            'title': '.tabs_title',
            'content': '.tabs_content',
            'active': 'this--active'
        };
        $('body').on('click', tabsClass.title, function() {
            var $this = $(this);

            if ($this.hasClass(tabsClass.active)) return;

            var $container = $this.closest(tabsClass.container)
            ,   $titles = $container.find(tabsClass.title)
            ,   $contents = $container.find(tabsClass.content)
            ,   index = $titles.index($this);

            $titles.removeClass(tabsClass.active);
            $this.addClass(tabsClass.active);
            $contents.hide().eq(index).show();
        });
        `

        ###
        # 售前售后详情
        ###
        saleHelpArticle = ()->
            $.ajax
                url: Sp.config.host + '/api/getGoodsNotice',
                method: 'GET',
                success: (res)->
                    if res and res.code == 0
                        $("#sale-help-article").html res.data.content

        saleHelpArticle()

    page.init()
    return  page
