# 商品详情页面逻辑
define ['PayOrderResultModalBox', 'preLoad'], (PayOrderResultModalBox)->

    payOrderResultModalBox= null
    $("#j-pay-btn").on "click", ->
        if !payOrderResultModalBox
            payOrderResultModalBox = new PayOrderResultModalBox
                top: 250
                mask: true
                maskClose: true
                closeBtn: true
        payOrderResultModalBox.show()
