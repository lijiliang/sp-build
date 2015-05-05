# 商品详情页面逻辑
define ['Swipe', 'Menu', 'Tab', 'preLoad'], (Swipe, Menu, Tab) ->

        # 首页轮播图
    $("#j-banner").find(".swipe-item").each ->
        $(".swipe-points").append("<span></span>")

    points = $(".swipe-points").find("span")
    points.eq(0).addClass("_active")
    bannerSwipe = new Swipe document.getElementById('j-banner'),
        startSlide: 0
        speed: 400
        auto: 3000
        continuous: true
        disableScroll: false
        stopPropagation: false
        callback: (index, elem) ->
            points.eq(index).addClass("_active").siblings("span").removeClass("_active")
            return false

    points.on "click", ->
        index = $(this).index()
        bannerSwipe.slide(index)
        return false;


    tabSwipe = [];
    createSilde = (value) ->
        name = 'j-tab-slider-0' + value
        tabSwipe[value] = new Swipe document.getElementById(name),
            startSlide: 0
            speed: 400
            auto: 0
            continuous: true
            disableScroll: false
            stopPropagation: false
            callback: (index, elem) ->

        $slide = $("#"+name);
        len = $slide.find(".index-tab-swipe__item").length

        if(len <= 1)
            $slide.find(".swipe-actions").hide()

        $("#" + name + " .swipe-actions__prev").on 'click', ->
            tabSwipe[value].prev() ;
            return false;

        $("#" + name + " .swipe-actions__next").on 'click', ->
            tabSwipe[value].next() ;
            return false;

    # 首页TAB
    createSilde(1) ;
