# 商品API
define ['Sp','AddCartModalBox','LightModalBox','LoginModalBox'], ( Sp, AddCartModalBox, LightModalBox, LoginModalBox)->
    api = {}

    # 加入购物车
    api.addcart = (skuid,quantity,goodName,price, callback)->

        data =
            "goods_sku_id" : skuid
            "goods_sku_quantity" : parseInt(quantity)

        Sp.post Sp.config.host + "/api/cart/add", data, (res)->
            if(res && res.code ==0)
                if(!addCartBox)
                    addCartBox = new AddCartModalBox
                        top: 200
                        mask: true
                        closeBtn: true,
                        goodName: goodName
                        price: price
                    addCartBox.show()
                    addCartBox.getCartList(res.data.goods)
                    if callback
                        callback(true)
            else
                lightModalBox = new LightModalBox
                    width: 180
                    status: "error"
                    text : "添加失败"
                lightModalBox.show()
                if callback
                    callback(false)

    # 加入收藏夹
    api.addlike = (goodid, callback)->
        if(!_SP.member)
            ###lightModalBox = new LightModalBox
                width: 180
                status: "error"
                text : "请先进行登录"
            lightModalBox.show()###
            if !loginBox
                loginBox = new LoginModalBox
                    width: 440
                    top: 250
                    mask: true
                    closeBtn: true
                    loginSuccessCallback: ()->
                        window.location.reload()
            loginBox.show()
            return false;
        data =
            "member_id" : _SP.member
            "goods_ids" : JSON.stringify([goodid])

        Sp.post Sp.config.host + "/api/member/favorite/add", data, (res)->
            res = res || {};
            successTip = {
                0: '商品收藏成功',
                20004: '该商品已收藏'
            }
            if(res.code == 0 || res.code == 20004)
                lightModalBox = new LightModalBox
                    width: 180
                    status: "success"
                    text : successTip[res.code]
                lightModalBox.show()
                if callback
                    callback(true)
            else
                lightModalBox = new LightModalBox
                    width: 180
                    status: "error"
                    text : "商品收藏失败"
                lightModalBox.show()
                if callback
                    callback(false)

    # 取消收藏
    api.removelike = (ids, callback)->
        Sp.post Sp.config.host + "/api/member/favorite/delete", {
            member_id: _SP.member
            goods_ids: JSON.stringify(ids)
        },(res)->
            if(res && res.code == 0)
                lightModalBox = new LightModalBox
                    width: 180
                    status: "success"
                    text : "取消收藏成功"
                lightModalBox.show()
                if callback
                    callback(true)
            else
                lightModalBox = new LightModalBox
                    width: 180
                    status: "error"
                    text : "取消收藏失败"
                lightModalBox.show()
                if callback
                    callback(false)


    return  api
