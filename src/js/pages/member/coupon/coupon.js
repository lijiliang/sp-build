require ('modules/preLoad/preLoad');
var CouponModal = require ('modules/coupon/coupon-modal-box');
var Sp = require('modules/sp/sp');
$(function()
{
    $(".order-list-tab__item").click(function () {
        var index = $(this).index();
        console.log(index);
        $(this).addClass('_active').siblings('.order-list-tab__item').removeClass('_active');
    });
    var couponModal = null;
    $(".handle_coupon").click(function () {
        console.log(couponModal);
        if(!couponModal){
            couponModal = new CouponModal({
                width: '540px',
                top: 60,
                mask: true,
                closeBtn: true,
                couponCodeCallback: function (_res) {
                    window.location.reload();
                }
            });
        }
        couponModal.show();
    });

})
