# 配送地
define ['DropDown', './tpl-ucenter', './tpl-help-center', './tpl-follow-us'], (DropDown, topbar_ucenter, topbar_helpcenter,followus)->

    class topbarDropDown extends DropDown
        constructor: (@options)->
            #this.options.template = options.template || navDropDown_tpl({})
            self = this
            this.leaveTarget = if @options.event == 'mouseenter' then "mouseleave" else "click"
            this.options.render = ->
                tplname = $(self.options.target).data("tplname");
                switch tplname
                    when "topbar_ucenter"
                        html = topbar_ucenter({})
                    when "topbar_helpcenter"
                        html = topbar_helpcenter({})
                    when "followus"
                        html = followus({})
                self.dropDownBox.find(".ui-drop-down-box__inner").html(html)
                $(document).one "click",->
                    self.hide()
            super

        # show
        show: ()->

            super

            if(!this.dropDownBox.is(":hidden"))

                $(this.options.target)
                .addClass("_active")
                #console.log( this.dropDownBox.width(),$(this.options.target).outerWidth() );
                #ml = $(window).width()-this.options.$target.offset().left-this.options.$target.width()
                #console.log (ml)
                left = 0
                if(this.dropDownBox.width()+this.options.$target.offset().left>$(window).width())
                    left = this.dropDownBox.width()-$(this.options.target).outerWidth()
                this.dropDownBox
                .find(".topbar-dropdown-content__top-border")
                .width($(this.options.target).outerWidth())
                .css
                    left: left

        #hide
        hide: ()->

            super

            $(this.options.target)
            .removeClass("_active")

    return  topbarDropDown
