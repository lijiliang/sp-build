# 商品图片预览
define ()->
    curentWidth = 140
    curentIndex = 0
    length = $(".ui-good-photos__lists").find("li").length

    goodSlider = ->

    goodSlider.handleImg = (e)->
        e.stopPropagation()
        e.preventDefault()
        src = $(this).find("img").data("src");

        $(".ui-good-photos__content").find("img").attr
            src: src

        $(this).addClass("_active")
        .siblings("li")
        .removeClass('_active')

    goodSlider.handlePrev = (e)->
        e.stopPropagation()
        e.preventDefault()

        if($(this).hasClass("_disable"))
            return false

        curentIndex = curentIndex - 1
        if(curentIndex == 0)
            $(this).addClass("_disable")

        $(".ui-good-photos__list-inner").animate
            marginLeft: -curentWidth * curentIndex

        if($(".ui-good-photos__next").hasClass("_disable"))
            $(".ui-good-photos__next").removeClass("_disable")

    goodSlider.handleNext = (e)->
        e.stopPropagation()
        e.preventDefault()

        if($(this).hasClass("_disable"))
            return false

        wrapWidth = $(".ui-good-photos__list-wrap").width()
        lastLength = Math.floor(wrapWidth / 140)
        lastWidth = wrapWidth % 140 + 20
        curentIndex = curentIndex + 1
        if(curentIndex == length - lastLength )
            $(this).addClass("_disable")
            $(".ui-good-photos__list-inner").stop().animate
                marginLeft: -(curentWidth * curentIndex + 1) + lastWidth
        else
            $(".ui-good-photos__list-inner").stop().animate
                marginLeft: -curentWidth * curentIndex

        if($(".ui-good-photos__prev").hasClass("_disable"))
            $(".ui-good-photos__prev").removeClass("_disable")


    # 初始化页面
    goodSlider.init = ->
        firstImg = $(".ui-good-photos__list-inner").find("li").eq(0).find("img").data("src");
        $(".ui-good-photos__content").find("img").attr
            src: firstImg

        resize = ()->
            $(".ui-good-photos__list-inner").width(curentWidth * length)
            #console.log $(".ui-good-photos__content").width(),curentWidth * length+100
            if $(".ui-good-photos__content").width()>(curentWidth * length+100)
                #console.log "yes"
                $(".ui-good-photos__next").addClass("_disable")
            else
                $(".ui-good-photos__next").removeClass("_disable")

        $(".ui-good-photos__lists").find("li").on "click", goodSlider.handleImg
        $(".ui-good-photos__prev").on "click", goodSlider.handlePrev
        $(".ui-good-photos__next").on "click", goodSlider.handleNext

        $(window).on "resize", resize

        resize()



    return  goodSlider
