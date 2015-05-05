# 模态框
define ['./tpl-layout'], (modalBox_layout)->
    class ModalBox
        constructor: (@options)->
            this.options.closedCallback = @options.closedCallback || ->
            this.options.init = @options.init || ->
            this.id = "modal-" + new Date().getTime()
            this.modal = null
            this.render()
        show: ->
            _width = this.options.width or this.modal.find(".ui-modal__content>div").outerWidth()
            _height = this.options.height or this.modal.find(".ui-modal__content>div").outerHeight()

            position =
                top: this.options.top or ($(window).height()-_height)/2
                left: this.options.left or ($(window).width()-_width)/2
            this.modal.find(".ui-modal__dialog").css
                width: _width
                #left: position.left
                top: position.top
            this.modal.show()
        close: ->
            this.modal.hide()
            this.options.closedCallback()

        destroy: ->
            this.modal.remove()

        render: ->
            tpl = modalBox_layout({})
            tpl = $(tpl).find(".ui-modal__content").append(this.options.template).closest('.ui-modal').attr("id", this.id )
            $("body").append(tpl)
            this.modal = $("#"+this.id)
            this.options.init()
            # 关闭按钮
            if(this.options.closeBtn)
                this.modal.find(".ui-modal__content").append('<a href="#" class="ui-modal__close-box iconfont">&#xe617;</a>');
                # 绑定关闭事件
                this.modal.find(".ui-modal__close-box").on "click",=>
                    this.close()
                    return false

            # 通用关闭按钮
            $(document).on "click", ".modal_close_btn", ()=>
                this.close()
                return false
            # 遮罩
            if(this.options.mask)
                this.modal.prepend('<div class="ui-modal__bg"></div>');
                # 绑定关闭事件
                if(!@options.maskClose)
                    this.modal.find(".ui-modal__bg").on "click",=>
                        this.close()
                        return false

    return  ModalBox
