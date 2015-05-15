# 商品详情页面逻辑
# @tofishes modify

require('preLoad')
goodApi = require('goodApi')
goodListHover = require('goodListHover')
PlaceSelector = require('PlaceSelector')

$doc = $(document)

goodListHover.init()

# 地区选择
new PlaceSelector
    target: "#stock-btn"
    closeBtn: ".close"
    callback: (data) ->
        console.log arguments

$doc.on "click", ".btn-addcart", ()->
    skuid = $(this).data("skuid")
    title = $(this).data("title")
    price = $(this).data("price")
    goodApi.addcart( skuid, 1, title, price)
    .done (res)->
        if res.code == 0
            $cartBtn = $ '#j-cart-btn'
            $cartBtn.cart 'setShouldUpdate' if $cartBtn.length
    return false

$doc.on 'click', ".btn-addlike", ()->
    goodid = $(this).data("goodid");
    goodApi.addlike(goodid);
    return false

#跳转页面
$("#j-page-jump").on "click", (e)->
    e.stopPropagation()
    e.preventDefault()
    jump_page_form = $("#jump-page-form")
    jump_page = jump_page_form.find("[name='page']").val();
    max_page = jump_page_form.find("#max-page").val();
    if $.trim(jump_page) and parseInt($.trim(jump_page))<=parseInt($.trim(max_page))
        jump_page_form.submit();
