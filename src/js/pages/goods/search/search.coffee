# 商品详情页面逻辑
define ['goodListHover', 'goodApi', 'preLoad'], (goodListHover,goodApi)->
    goodListHover.init()

    $(document).on "click", ".btn-addcart", ()->
        skuid = $(this).data("skuid")
        title = $(this).data("title")
        price = $(this).data("price")
        goodApi.addcart( skuid, 1, title, price)
        .done (res)->
            if res.code == 0
                $cartBtn = $ '#j-cart-btn'
                $cartBtn.cart 'setShouldUpdate' if $cartBtn.length
        return false

    $(document).on 'click', ".btn-addlike", ()->
        goodid = $(this).data("goodid");
        goodApi.addlike(goodid);
        return false
