# 商品详情页面逻辑
define ['PayOrderResultModalBox'], (PayOrderResultModalBox)->
    page = ->

        # 初始化页面
    page.init = ->
        payOrderResultModalBox= null
        $("#j-pay-btn").on "click", ->
            if !payOrderResultModalBox
                payOrderResultModalBox = new PayOrderResultModalBox
                    top: 250
                    mask: true
                    maskClose: true
                    closeBtn: true
            payOrderResultModalBox.show()
#            return false

    return  page
