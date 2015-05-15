# 兑换优惠券
Sp = require 'Sp'
LightModalBox = require 'LightModalBox'
ModalBox = require 'ModalBox'
tpl= require './tpl-coupon'

#API
host = Sp.config.host

Api =
    coupon: 'coupon'

Action =
    baseUrl: host + '/api/'
    path: Api
    fn: (res)->
        console.log res
    activateCoupon: (data)->
        data = {} if !data
        Sp.put @baseUrl + @path.coupon, data, @fn, @fn

class Coupon extends ModalBox
    constructor: (@options)->
        @options.template = tpl({})
        super
        @_init()
        @_bindEvt()

    _init: () ->
        @$btn = $ ('#j-coupon-modal-btn')
        @$ipt = $ ('#j-coupon-modal-input')

    _bindEvt: () ->
        _this =@
        @$btn.on 'click', (e) =>
            value = @$ipt.val()
            # @options.couponCodeCallback.call @, value if typeof @options.couponCodeCallback is 'function' && value isnt ''
            if value && value.length >= 16
                Action.activateCoupon code: value
                .done (res) ->
                    console.log 'code', res
                    if res and res.code is 0
                        _this.close()
                        lightModalBox = new LightModalBox
                            width: 300
                            status: "success"
                            text : "优惠券激活成功!"
                        lightModalBox.show()
                        _this.options.couponCodeCallback.call @, res if typeof _this.options.couponCodeCallback is 'function'
                    else if res.code is 20001
                        lightModalBox20001 = new LightModalBox
                            width: 400
                            status: "error"
                            text : "操作过于频繁, 请稍后再试!"
                        lightModalBox20001.show()
                    else
                        lightModalBox1 = new LightModalBox
                            width: 300
                            status: "error"
                            text : "优惠券无效!"
                        lightModalBox1.show()
            else if value
                lightModalBox2 = new LightModalBox
                    width: 400
                    status: "error"
                    text : "优惠券兑换码必须大于15位!"
                lightModalBox2.show()
            else
                lightModalBox3 = new LightModalBox
                    width: 400
                    status: "error"
                    text : "请输入正确的优惠券兑换码!"
                lightModalBox3.show()





module.exports = Coupon
