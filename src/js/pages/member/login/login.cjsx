# cart
define ['Sp','modules/components/loginbox', 'preLoad'], (Sp,Loginbox)->

    Sp.log "init Modules"

    # 初始化登录组件
    React.render <Loginbox pageType="page" />, document.getElementById('loginbox-wrap')
