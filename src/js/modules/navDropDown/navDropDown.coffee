# 配送地
define ['Sp', 'DropDown', './navDropDown_layout'], (Sp, DropDown, navDropDown_tpl)->
    class Destination extends DropDown
        constructor: (@options)->
            #this.options.template = options.template || navDropDown_tpl({})
            self = this
            this.options.render = ->
                $.ajax
                    method: "GET",
                    url: "/public/js/widgets/navDropDown/data.json"
                    success: (return_data)->
                        html = navDropDown_tpl(return_data)
                        self.dropDownBox.find(".ui-drop-down-box__inner").html(html)

                $(document).on "click",->
                    self.hide()
            super

        # show
        show: ()->
            if(this.dropDownBox.is(":hidden"))
                $(this.options.target).addClass("_active");
            super
        #hide
        hide: ()->
            $(this.options.target).removeClass("_active");
            super

    return  Destination
