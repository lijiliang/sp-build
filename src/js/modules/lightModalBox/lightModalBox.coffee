# 模态框
define ['./lightModalBox_layout'], (lightModalBox_layout)->
    class LightModalBox
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
                top: 200
                #left: this.options.left or ($(window).width()-_width)/2
            this.modal.show()
            __width = if (!this.options.width and _width < 180) then 180 else _width
            this.modal.find(".ui-modal__dialog").css
                width: __width
                opacity: 0.1
                top: 150
                #left: position.left

            this.modal.find(".ui-modal__dialog").animate
                top: position.top
                opacity: 1
            setTimeout ()=>
                this.close()
            ,2000

        close: ->
            this.modal.remove()
            this.options.closedCallback()

        render: ->
            tpl = lightModalBox_layout({
                success: @options.status == "success"
                error: @options.status == "error"
                text: @options.text
            })
            tpl = $(tpl).find(".ui-modal__content").closest('.ui-modal').attr("id", this.id )
            $("body").append(tpl)
            this.modal = $("#"+this.id)
            this.options.init()




    return LightModalBox
