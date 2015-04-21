# 全局模块
define ['config','cookie'], (config, $cookie)->
    Sp = ->
    Sp.init = ->

    # 服务器
    Sp.config =
        host : config.host

    # @tofishes 生产环境标志
    Sp.isProduct = location.hostname.indexOf('sipin.com') != -1
    Sp.isDev = !Sp.isProduct


    # 事件中心，待完善
    Sp.jq = $({})
    Sp.on = ->
        Sp.jq.on.apply Sp.jq, arguments

    Sp.off = ->
        Sp.jq.off.apply Sp.jq, arguments

    Sp.trigger = ->
        Sp.jq.trigger.apply Sp.jq, arguments

    # 调试信息输出
    Sp.log = (info)->
        if !window.console then window.console = log: ()->
        if console and console.log
            console.log '%c'+info,'color:#d3af94;'

    # 字符串处理
    Sp.trim = (val)->
        val.replace /^\s+|\s+$/gm,''

    # Date对象的一些操作
    Sp.date =
        # 获取传入的Date对象的前后的n天m个月的Date对象
        ahead: (date, days, months)->
            return new Date(
                date.getFullYear()
                date.getMonth() + months
                date.getDate() + days
            )
        # 将日期字符串(如:"2015-01-01")转换为Date对象
        parse: (s)->
            if m = s.match /^(\d{4,4})-(\d{2,2})-(\d{2,2})$/
                return new Date m[1], m[2] - 1, m[3]
            else
                return null
        # 将Date对象转换为日期字符串(如:"2015-01-01")
        format: (date)->
            month = (date.getMonth() + 1).toString()
            dom = date.getDate().toString()
            if month.length is 1
                month = '0' + month
            if dom.length is 1
                dom = '0' + dom
            return date.getFullYear() + '-' + month + "-" + dom

    # ajax事件
    Sp.postSuccess = ()->

    Sp.postError = ()->

    Sp.ajax = (type, url, data, success, error)->
        promise = $.ajax
            url: url
            type: type
            dataType: "json"
            data: data
            beforeSend: (xhr)->
                console.log xhr
                xhr.setRequestHeader("X-CSRF-Token", _SP.token)

        promise.done success || Sp.postSuccess
        promise.fail error || Sp.postError

        promise;

    Sp.ajaxStatus =
        SUCCESS                 : 0 # 成功
        FAIL                    : 1 # 失败
        ERROR_OPERATION_FAILED  : 10001 # 操作失败
        ERROR_MISSING_PARAM     : 20001 # 缺少参数
        ERROR_INVALID_PARAM     : 20002 # 不合法参数
        ERROR_INVALID_CAPTCHA   : 20003 # 验证码错误
        ERROR_AUTH_FAILED       : 40001 # 未登陆操作
        ERROR_PERMISSION_DENIED : 40003 # 权限错误

    Sp.post = (url, data, success, error)->
        Sp.query "POST", url, data, success, error

    Sp.get = (url, data, success, error)->
        Sp.query "GET", url , data, success, error

    Sp.query = (type, url, data, success, error)->
        Sp.ajax type, url, data, success, error

    # 设置用户位置cookie
    Sp.setPlaceIdCookie = (provinceId,cityId,districtId)->
        $.cookie('region_province_id', provinceId || -1, { path: '/' } );
        $.cookie('region_city_id', cityId || -1, { path: '/' } );
        $.cookie('region_district_id', districtId || -1, { path: '/' } );

    Sp.setPlaceNameCookie = (provinceName,cityName,districtName)->
        $.cookie('region_province_name', provinceName || -1, { path: '/' } );
        $.cookie('region_city_name', cityName || -1, { path: '/' } );
        $.cookie('region_district_name', districtName || -1, { path: '/' } );

    # @tofishes
    # 提供本地存储方法，用以替代cookie存储
    # 减小cookie大小对网站请求速度有很大提升
    # 非必要勿使用cookie存储，而是使用本地存储
    storeTimeName = 'storage-time'
    setStorage = (name, value) ->
        localStorage.setItem(name, JSON.stringify(value))
    getStorage = (name) ->
        return JSON.parse(localStorage.getItem(name))

    Sp.store = (name, value, version) ->
        if value
            # 记忆存储时间，方便以后根据时间清除
            Time = localStorage.getItem(storeTimeName) || {}
            Time[name] = version || new Date().getTime()
            setStorage storeTimeName, Time
            return setStorage name, value

        if value == null
            return localStorage.removeItem(name);

        return getStorage name;

    Sp.storeTime = (name) ->
        return getStorage(storeTime).name
    Sp.removeStoreTime = (name) ->
        Time = getStorage(storeTimeName) || {}
        delete Time.name
        setStorage storeTimeName, Time

    return  Sp
