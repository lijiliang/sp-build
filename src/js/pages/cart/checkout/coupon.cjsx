# Coupon

Sp = require 'Sp'
CouponModal = require 'modules/coupon/coupon-modal-box'
LightModalBox = require 'LightModalBox'

#API
host = Sp.config.host

Api =
    coupon: 'coupon'
    getTotalPrice: 'price/getSettlement'

Action =
    baseUrl: host + '/api/'
    path: Api
    fn: (res)->
        console.log res
    list: (data)->
        data = {} if !data
        Sp.get @baseUrl + @path.coupon, data, @fn, @fn
    activateCoupon: (data)->
        data = {} if !data
        Sp.put @baseUrl + @path.coupon, data, @fn, @fn
    getTotalPrice: (data)->
        data = {} if !data
        data.region_id = _SP.region_id if !data.region_id
        if !data.region_id
            lightModalBox = new LightModalBox
                width: 400
                status: "error"
                text : "请先选择收货地址!"
            lightModalBox.show()
        Sp.get @baseUrl + @path.getTotalPrice, data, @fn, @fn

cx = React.addons.classSet

###
# CouponList.
# @author remiel.
# @module CouponList
# @example CouponList
#
#   jsx:
#   <CouponList extClass></CouponList>
#
# @param options {Object} the options
# @option extClass {String} add a class to the wrapper for style
#
###
CouponList = React.createClass
    onClick: (thisItem, i, e) ->
        return null if thisItem._activeState is 1 || @props.type isnt 'usable'
        callback = @props.callback;
        callback.call @, thisItem, i if typeof callback is 'function'

    list: () ->
        items = @props.data.map (item, i) =>
            task = item.task
            classes  = cx
                '_disable': @props.type isnt 'usable'
                '_active': item._activeState
                'ui-lg-checkbox': true
            text = ''
            switch task.requirement
                when 0
                    text = '无条件'
                when 1
                    text = '满' + task.threshold + '元'
            <div className={classes} key={i} onClick={@onClick.bind null, item, i}>
                <table className="order-coupon__table u-color_gray">
                    <tr>
                        <td className="order-coupon__td _td-1">￥{task.value}</td>
                        <td className="order-coupon__td _td-2">{text}</td>
                        <td className="order-coupon__td _td-3">{item.valid_time_start_at.split(' ')[0]} ~ {item.valid_time_end_at.split(' ')[0]}</td>
                    </tr>
                </table>
            </div>


    render: ->
        <div className="order-coupon__list">
            <div className="order-coupon__list-hd">
                <table className="order-coupon__table u-color_gray">
                    <tr>
                        <td className="order-coupon__td _td-1">金额</td>
                        <td className="order-coupon__td _td-2">使用条件</td>
                        <td className="order-coupon__td _td-3">有效期</td>
                    </tr>
                </table>
            </div>
            <div className="order-coupon__list-bd">
                {@list()}
            </div>
        </div>


###
# Coupon.
# @author remiel.
# @module Coupon
# @example Coupon
#
#   jsx:
#   <Coupon extClass></Coupon>
#
# @param options {Object} the options
# @option extClass {String} add a class to the wrapper for style
#
###
Coupon = React.createClass
    getInitialState: ->
        keyMap: ['usable', 'unusable', 'outdated']
        active: 0
        data:
            outdated: []
            unusable: []
            usable: []

    getDefaultProps: ->
        id: 0

    componentDidMount: ->
        _this = @

        el = @refs.showCouponBtn.getDOMNode()
        $el = $ el

        couponList = @refs.couponList.getDOMNode();
        $couponList = $ couponList

        $el.checkbox
            callback: (value)->
                if value
                    $couponList.show()
                    #请求优惠券列表
                    # _this.setState data: tmpData
                    Action.list({total_price: _SP.total_price}).done (res) ->
                        console.log 'get list :: ',res
                        _this.setState data: res.data if res.code is 0
                else
                    $couponList.hide()
                    _this.cancelCoupon()

    handleTabClick: (index, e) ->
        @setState active: index

    handleSelect: (thisItem, index) ->
        datas = @state.data
        data = @getActiveData()
        data.map (item, i) ->
            if item.id is thisItem.id
                item._activeState = 1
            else
                item._activeState = 0
        @setState
            data: datas
        #请求使用优惠券
        Action.getTotalPrice coupon_ids: thisItem.id
        .done (res)=>
            @setPrice res
            _this.couponCallback thisItem.id

    # 设置价格
    setPrice: (res) ->
        if res.code is 0 and res.data and res.data isnt -1
            $('#j-total-price').html res.data.total_price
            $('#j-total-delivery').html res.data.total_delivery
            $('#j-total-installation').html res.data.total_installation
            $('#j-total-coupon').html res.data.coupon_abatement
            $('#j-total-delivery-installation-abatement').html res.data.delivery_abatement + res.data.installation_abatement
            $('#j-total-amount').html res.data.total_amount
            $('#j-total').html res.data.total

    # 取消优惠券
    cancelCoupon: () ->
        _this = @
        _this.couponCallback ''
        #请求取消使用优惠券
        Action.getTotalPrice()
        .done (res)->
            _this.setPrice res





    getActiveType: () ->
        @state.keyMap[@state.active]
    getActiveData: () ->
        @state.data[@getActiveType()]

    setTabClass: (index) ->
        cx
            'ui-tab__item':true
            '_active': index is @state.active

    #handleExchange
    handleExchange: () ->
        _this = @
        if !@couponModal
            @couponModal = new CouponModal
                width: '540px'
                top: 60
                mask: true
                closeBtn: true
                couponCodeCallback: (_res) ->
                    # 取消优惠券
                    _this.cancelCoupon()
                    # 刷新列表
                    Action.list({total_price: _SP.total_price}).done (res) ->
                        _this.setState data: res.data if res.code is 0
        @couponModal.show()

    couponCallback: (ids) ->
        callback = @props.callback
        callback.call @, ids if typeof callback is 'function'


    render: ->
        console.log @props.id, 'id.....'
        type = @getActiveType()
        data = @getActiveData()
        <div id="j-coupon">
            <div className="order-cart-table__options-hd form form-horizontal">
                <span className="ui-checkbox" _name="show_coupon" _checked="false" id="j-show-coupon" ref='showCouponBtn'> 使用优惠券</span>
            </div>
            <div className="order-coupon" id="j-order-coupon-box" ref='couponList' style={{display: 'none'}}>
                <div className="order-coupon__hd">
                    <div className="ui-tab u-clearfix">
                        <a className={@setTabClass(0)} href="javascript:;" onClick={@handleTabClick.bind null, 0}>可用优惠券 ( <span className="u-color_red">{@state.data[@state.keyMap[0]].length}</span> )</a>
                        <a className={@setTabClass(1)} href="javascript:;" onClick={@handleTabClick.bind null, 1}>不可用优惠券 ( <span className="u-color_red">{@state.data[@state.keyMap[1]].length}</span> )</a>
                    </div>
                </div>
                <div className="order-coupon__bd" id="j-coupon-list">
                    <CouponList data={data} type={type} callback={@handleSelect}></CouponList>
                </div>
                <div className="order-coupon__ft">
                    有优惠劵兑换码？
                    <a href="javascript:;" className="u-ml_20" onClick={@handleExchange}>现在兑换》</a>
                </div>
            </div>
        </div>





module.exports = Coupon
