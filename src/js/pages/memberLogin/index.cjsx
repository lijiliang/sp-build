# cart
define ['Sp','modules/components/loginbox'], (Sp,Loginbox)->
    page = ->

    page.init = ->
        Sp.log "init Modules"

        # 初始化登录组件
        React.render <Loginbox />, document.getElementById('loginbox-wrap')

    page.init();

    return  page
