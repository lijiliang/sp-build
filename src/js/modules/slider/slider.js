
define(function (){
/**
 * 基本图片滚动脚本
 */

    $.fn.sy_slider = function(options){
        var self = this;
        self.options = $.extend({
            auto: true,
            loop: true,
            width: 500,
            interval: 3000
        },options);

        $(this).each(function(){
            var prev_btn = $(this).find(".prev-btn"),
                next_btn = $(this).find(".next-btn"),
                li = $(this).find("li"),
                point = $(this).find(".slide-bullet a"),
                len = li.length,
                inner_wrap = $(this).find(".slide-view ul"),
                time = null;

            var index = 0;

            // 向右
            next_btn.on("click", function(){
                if(index>=len-1) {
                    if(self.options.loop){
                        index = -1;
                    }else{
                        return;
                    }
                }
                clearInterval(time);
                index++;
                inner_wrap.stop().animate({
                    marginLeft: -self.options.width*index + "px"
                });
                changeText(index);
                changePoint(index);
                setTime();
                return false;
            });

            // 向左
            prev_btn.on("click", function(){
                if(index<=0) {
                    if(self.options.loop){
                        index = len;
                    }else{
                        return;
                    }
                }
                clearInterval(time);
                index--;
                inner_wrap.stop().animate({
                    marginLeft: -self.options.width*index + "px"
                });
                changeText(index);
                changePoint(index);
                setTime();
                return false;
            });

            // 点换
            point.on("click", function(){
                clearInterval(time);
                index = $(this).index();
                inner_wrap.stop().animate({
                    marginLeft: -self.options.width*index + "px"
                });
                changeText(index);
                changePoint(index);
                setTime();
                return false;
            });

            // 更换文字
            function changeText(index){
                var text = li.eq(index).find("a").attr("title")
                $(".slide-title").html(text);
            }

            // 更新圆点
            function changePoint(index){
                point.eq(index).addClass("active").siblings("a").removeClass("active");
            }

            // 定时
            function setTime(){
                if(self.options.auto){
                    time = setInterval(function(){
                        if(index<len-1){
                            next_btn.click();
                        }else{
                            index = -1;
                        }
                    },self.options.interval);
                }
            }
            setTime();

        });
    };

    //$("#imgslide_page").sy_slider();

    return {
        init: function(){
        }
    };

});
