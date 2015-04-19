# 商品详情页面逻辑
define ['LoginModalBox', 'AutoComplete', 'NavDropDown',
        'TopbarDropDown', 'Cart','Placeholder','modules/components/memberbar'], (LoginModalBox, AutoComplete, NavDropDown, TopbarDropDown, Cart,Placeholder,Memberbar)->
    page = ->

        # 初始化页面
    page.init = ->

        #console.log $
        #console.log Placeholder

        # placeholder fixed
        #$('.j-placeholder').placeholder();

        # 顶部用户状态组件
        if($("#j-header-memberbar").length)
            React.render <Memberbar />, document.getElementById('j-header-memberbar')

        # 自动补全
        ac = new AutoComplete
            target: "#ac"
            source:
                data: []
        ac.render()

        # 登录框
        ###loginBox = null
        $(".j-login").on "click", (e)->
            e.preventDefault()
            if(!loginBox)
                loginBox = new LoginModalBox
                    top: 250
                    mask: true
                    closeBtn: true
                    loginSuccessCallback: ()->
                        window.location.reload()
            loginBox.show()
            return false###

        # 路径导航下拉
        navDropDown = new NavDropDown
            target: ".nav-dropdown"

        # 个人中心下拉
        topbarDropDown = new TopbarDropDown
            target: ".j-dropdown-menu1"
            event: "mouseenter"

        topbarDropDown2 = new TopbarDropDown
            target: ".j-dropdown-menu2"
            event: "mouseenter"


        # $(".header-menu__ul li").on "mouseenter",()->
        #     $(this).find(".header-menu-popbox").show()
        #     return false
        #
        # $(".header-menu__ul li").on "mouseleave",()->
        #     $(this).find(".header-menu-popbox").hide()
        #
        # $(".header-menu-smaill__inner").on "mouseenter",()->
        #     $(this).find(".header-menu-small-popbox").show()
        #     return false
        #
        # $(".header-menu-smaill__inner").on "mouseleave",()->
        #     $(this).find(".header-menu-small-popbox").hide()

        menu_ishover = false;
        menu_item_ishover = false;
        menulist = $(".header-menu-v2__menulist")
        menulist_item = $(".header-menu-v2__menu li")
        menulist_item_wrap = ".header-menu-v2__menulist-item-wrap"

        hideMenu = ()->
            t1 = setTimeout(()->
                if(!menu_item_ishover && !menu_ishover)
                    menulist_item.removeClass("_active")

                    menulist
                    .stop()
                    .animate({
                        height:0,
                        opactiy:0
                    },250,()->
                        menulist.hide().find(menulist_item_wrap).removeClass("_active")
                    )

                clearTimeout(t1);
            ,500)

        showMenu  = (index)->

            menulist
            .show()
            .stop()
            .animate({
                height:150,
                opactiy:1
            },250,()->
                menulist
                .find(menulist_item_wrap)
                .eq(index)
                .addClass("_active")
                .siblings()
                .removeClass("_active")
            )

        menulist_item.on "click",->
            return false

        menulist_item.on "mouseenter",()->
            menu_ishover = true
            index = $(this).index()

            $(this)
            .addClass("_active")
            .siblings()
            .removeClass("_active");

            showMenu(index);



        menulist_item.on "mouseleave",()->
            menu_ishover = false
            hideMenu()

        $(menulist_item_wrap).on "mouseenter",->
            menu_item_ishover = true;

        $(menulist_item_wrap).on "mouseleave",->
            menu_item_ishover = false;
            hideMenu()



        #购物车按钮
        $cartBtn = $ '#j-cart-btn'
        $cartBtn.cart() if $cartBtn.length
        #通知更新购物车数据
        #$cartBtn.cart 'setShouldUpdate'

    page.init();

    return  page
