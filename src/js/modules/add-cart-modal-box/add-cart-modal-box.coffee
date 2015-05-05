# 加入购物车
define ['Sp','ModalBox','./tpl-layout', './tpl-item'], (Sp, ModalBox, addCartModalBox_tpl, addCartModelBox_item)->
    class AddCartModalBox extends ModalBox
        constructor: (@options)->
            self = this
            @options.template = addCartModalBox_tpl({
                goodName: @options.goodName
                price: @options.price
            })
            super
        getCartList: (gooddata)->
            self = this

            # 购物车列表
            cartlist = (goods)->
                tpl = addCartModelBox_item(goods)
                self.modal.find(".ui-good-photos__list-wrap ul").html tpl

                # 图片浏览
                index = 0;
                len = self.modal.find(".ui-good-photos__list-wrap li").length
                if(len<4)
                    self.modal.find(".cart-shop-slider__prev").addClass("_disable")
                    self.modal.find(".cart-shop-slider__next").addClass("_disable")

                # 往前
                self.modal.find(".cart-shop-slider__prev").on "click",()->
                    if($(this).hasClass("_disable"))
                        return false;
                    if index >=1
                        index--
                        self.modal.find(".ui-good-photos__list-inner").stop().animate
                            marginLeft: -index*147
                        self.modal.find(".cart-shop-slider__next").removeClass("_disable")
                    else
                        $(this).addClass "_disable"
                    return false;

                # 往后
                self.modal.find(".cart-shop-slider__next").on "click",()->
                    if($(this).hasClass("_disable"))
                        return false;
                    if index <= len-5
                        index++
                        self.modal.find(".ui-good-photos__list-inner").stop().animate
                            marginLeft: -index*147
                        self.modal.find(".cart-shop-slider__prev").removeClass("_disable")
                    else
                        $(this).removeClass "_disable"
                    return false;

            if(!gooddata)
                Sp.get Sp.config.host + "/api/cart",{}, (res)->
                    if(res && res.code == 0)
                        goods = res.data.goods
                        cartlist goods
            else
                cartlist gooddata

    return  AddCartModalBox
