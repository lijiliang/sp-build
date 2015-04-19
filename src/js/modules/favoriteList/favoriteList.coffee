# 收藏夹
define ['Sp',  'CheckAll',  'LightModalBox', './item'], ( Sp, CheckAll, LightModalBox, itemTemplate )->
    class favoriteList
        constructor: (@options)->
            this.page = 1
            this.lastPage = 1
            this.data = []

        # 初始化
        init: ()->
            self = this
            # 加载首页
            self.getData 1,()->
                self.render()

            #上一页
            $(document).on "click", "#j-prev-favorite",()->
                self.prevPage()
                return false
            #下一页
            $(document).on "click", "#j-next-favorite",()->
                self.nextPage()
                return false

            # 取消收藏
            $(document).on "click","#j-cancel-favorite",()->
                self.handleDeleteFavorite()
                return false
            # 取消单条收藏
            $(document).on "click",".j-cancel-one-favorite", ()->
                indexs = [$(this).closest(".cart-table__item").data("key")]
                ids = [$(this).data("id")];
                self.deleteFavorite(ids, indexs);
                return false

        # 重新加载数据
        reGetData: ()->
            location.reload()

        # 获取数据
        getData: (page,callback)->
            self = this

            Sp.get Sp.config.host + "/api/member/favorite",{
                member_id:  _SP.member,
                page: page || self.page
            },(res)->
                if(res && res.code == 0)
                    self.page = res.data["current_page"]
                    self.lastPage = res.data["last_page"]
                    self.data = res.data.data
                    #更新页码按钮状态
                    if(self.page ==self.lastPage)
                        $("#j-next-favorite").addClass("_disable")
                    else
                        $("#j-next-favorite").removeClass("_disable")

                    if(self.page == 1)
                        $("#j-prev-favorite").addClass("_disable")
                    else
                        $("#j-prev-favorite").removeClass("_disable")
                    callback()

                else
                    Sp.log ("收藏数据获取出错")

        # 渲染页面
        render: ()->
            self = this
            if(self.data.length)
                template = itemTemplate(self.data)
                $("#j-favorite-body").html(template)
                initCheckbox = ($el)->
                    $el.checkAll(
                        checkboxClass: '.ui-checkbox'
                        callback: (checked, $el)->
                    )
                initCheckbox $ '.cart-table'
            else
                #$("#j-favorite-body").html('<div class="cart-table__item u-text-center u-clearfix">暂时没有任何收藏</div>')

                $empty = [
                        '<div class="cart-table__empty">'
                        '<div class="cart-table__empty-info">'
                        '<div class="u-f18">收藏夹暂时没有商品！</div>'
                        '<div class="u-f14">'
                        '您可以 '
                        '<a href="/">返回首页</a>'
                        ' 挑选喜欢的商品'
                        '</div>'
                        '</div>'
                        '</div>'
                    ].join ''
                $ '.main-layout-container'
                .html $empty


        # 点击取消收藏
        handleDeleteFavorite: ()->
            self = this
            ids = []
            indexs = []
            checkFavs = $(".cart-table__inner .check-fav")
            checkFavs.each ()->
                if $(this).attr("_checked")=="true"
                    indexs.push $(this).closest(".cart-table__item").data("key")
                    ids.push $(this).data("id")
            if(ids.length)
                self.deleteFavorite(ids, indexs)
            return false

        # 取消收藏
        deleteFavorite: (ids, indexs)->
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
                    self.reGetData()  # 重载数据
                else
                    lightModalBox = new LightModalBox
                        width: 180
                        status: "error"
                        text : "取消收藏失败"
                    lightModalBox.show()

        #上一页
        prevPage: ()->
            self = this
            page = self.page-1 >= 1 ? self.page-1 : 1;
            if(page == self.page)
                return
            self.getData page,()->
                self.render()
            return false

        #下一页
        nextPage: ()->
            self = this
            page = self.page+1 <= self.lastPage ? self.page+1 : self.lastPage;
            if(page == self.lastPage)
                return
            self.getData page,()->
                self.render()
            return false

    return  favoriteList
