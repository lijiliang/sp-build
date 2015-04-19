# tofishes
# 售后服务相关页面功能
define ['Sp','Checkbox', 'SelectBox', 'Amount', 'PlaceSelector_v2', 'LoginModalBox', 'liteModalBox', 'uploader', 'validate'], (Sp, Checkbox, SelectBox, Amount, Places, loginModal, LiteModalBox)->
    # 获取七牛图片的缩略图
    # http://developer.qiniu.com/docs/v6/kb/speed_up_staticfile.html
    getQiniuThumb = (img_url)->
        img_url + '?imageView/1/w/80/h/80/q/80'

    #  @tofishes
    #  var params = $('form').paramMap();  就可以获得整个表单的所有参数
    `
    $.fn.paramMap = function (opts) {
        opts = $.extend({
            'separator': ',' //同名参数的分隔符，多用于checkbox的值
        })

        var params = this.serializeArray()
        ,   paramMap = {}

        ,   i = 0
        ,   l = params.length
        ,   param;

        for (; i < l; i++) {
            param = params[i];

            if (paramMap[param.name]) {
                paramMap[param.name] += opts.separator + param.value;
            } else {
                paramMap[param.name] = param.value;
            }
        };

        return paramMap;
    };

    /**
    * @author ToFishes
    * @date 2011.4.29
    * 3个简单的帮助方法，$().isLocked(), $().lock(), $().unLock().
    * 比如用于链接的ajax载入，通过这3个方法防止重复点击。
    * ... ...
    * var $btn = $('input:submit');
    * if ($btn.isLoced()) {
    *         return;
    * }
    * $btn.lock();
    * $.ajax(url, params, function (data) {
    *         $btn.unLock();
    *     ... ...
    * })
    *
    */
    $.fn.extend({
         'isLocked': function() {
              return $(this).data('jquery-fn-locked');
         },
         'lock': function() {
              return $(this).data('jquery-fn-locked', true);
         },
         'unLock': function() {
              return $(this).data('jquery-fn-locked', false);
         }
    });
    `
    page = ->

    #/melo/platform/public

    URI =
        'captcha': '' + '/api/captcha' || '../web-frontend-static/src/images/img/img114_40.jpg',
        'feedback': '/api/feedback/createFeedback' || Sp.config.host + '/api/feedback/createFeedback'

    # 初始化页面
    page.init = ->
        initRadios $ '#cs-order-apply-form, #cs-feedback-form'
        initGoodsCount()
        wordCountCheck()
        initSelect()

        new Places
            target: ".placeSelect"
            mode: 2
            callback: (res)->
                console.log res

        $('body').on 'click', '#captcha-wrap', ()->
            $img = $(@).find 'img'
            url = URI.captcha + '?' + new Date().getTime()
            $img.attr('src', url)
        $('#captcha-wrap').click();

        $('#cs-order-apply-form').validate();

        messages =
            'title': '输入内容不符合要求，请输入4~30个字'
            'email': '您输入的Email格式有误，请再次输入'
            'captcha': '请输入正确的验证码'
            'content': '请输入内容，至少10个字'

        $feedBackForm = $('#cs-feedback-form')
        $feedBackForm.validate
            messages: messages


        successTip = ['<h4 class="u-text-center">感谢您的反馈，您的反馈信息已成功提交</h4>',
            '<p class="u-text-center u-mt_10 u-mb_10">您提交的问题将会在<em class="number">48</em>小时内得到<br>处理，我们将会通过邮件通知到您。</p>',
            '<p class="u-text-center">
                <a class="modal_close_btn btn">知道了</a>
            </p>'
        ]
        $('#feedback-form-commit').on 'click', ->
            $this = $(@)
            console.log '##', $this.isLocked()
            if $this.isLocked()
                return

            $this.lock()

            params = $feedBackForm.paramMap()

            if !$feedBackForm.valid()
                return
            $.post URI.feedback, params, (data) ->
                $this.unLock()
                console.log $this.isLocked()
                #验证码错误
                if data.code == Sp.ajaxStatus.ERROR_INVALID_CAPTCHA
                    $captcha = $('#captcha-input')
                    $captcha.attr('placeholder', $captcha.val())
                    $captcha.val('')
                    $feedBackForm.valid()
                    return
                #成功后
                if data.code == Sp.ajaxStatus.SUCCESS
                    successTipBox = new LiteModalBox
                        top: 250
                        mask: true
                        contents: successTip.join('')
                        closeBtn: true
                        maskClose: true
                        closedCallback: ()->
                            window.location.reload()
                    successTipBox.show()
                    return
                #未登录
                if data.code == Sp.ajaxStatus.ERROR_AUTH_FAILED
                    loginBox = new loginModal
                        top: 250
                        mask: true
                        closeBtn: true
                        loginSuccessCallback: ()->
                            window.location.reload()
                    loginBox.show()


        isUploading = false
        picCountMax = 5
        host = if Sp.isProduct then Sp.config.host else 'http://www.sipin.melo'
        upload_url =  host + '/api/attachment/upload'
        $preview = $ '#upload-preview'
        $('#upload-picker').uploader
            'server': upload_url
            'formData':
                'entity': 'aftersales'
                'entity_id': 0
                'type_id': 4
            'callbacks':
                'uploadProgress':  ->
                    isUploading = true
                'beforeFileQueued': (file) ->
                    imgCount = $('#upload-preview').children().length

                    if imgCount >= picCountMax
                        alert '最多只能上传' + picCountMax + '张图片'

                    return !isUploading && imgCount < picCountMax
                'uploadSuccess': (file, resp) ->
                    if resp.code != 0
                        alert '上传失败请重试！'
                        return
                    data = resp.data[0]
                    img = data.full_path
                    id = data.id
                    thumb = getQiniuThumb(img)
                    $preview.append $ '<img data-id="'+id+'" src="' + thumb + '">'
                    # 获取所有图片id，组成值串
                    imageIds = []
                    $preview.children().each ()->
                        imageIds.push $(@).data 'id'
                    $('#uploader-images-id').val imageIds.join(',')
                'uploadFinished': () ->
                    isUploading = false

    initRadios = ($form)->
        $radioWrap = $form.find('.form-radios')
        $radioWrap.each ()->
            $this = $(@)
            $input = $form.find ('input[name=' + $this.data('name') + ']')

            $radios = $(this).find '.ui-radio'
            $radios.checkbox(
                callback: (checked, $el)->
                    $radios.checkbox 'off',true
                    $el.checkbox 'on',true
                    $input.val $el.data 'value'
                    $('#needorderid').toggle(!!$el.data('needorderid'))
            )

    initSelect = ()->
        $('.ui-select-box').selectBox()

    initGoodsCount = ->
        amount = new Amount
            target: ".amount-box"
            callback: (res)->
                # 快速
                #
                # 购买配置
                # $("#j-buy-now-form").find("input[name='goods_sku_quantity']").val res

    wordCountCheck = ->
        $wrap = $ '.word-count-checker'
        $wrap.each ()->
            $input = $(@).find 'input, textarea'
            $num = $(@).find '.word-counter'
            limit = +$num.html() || 200

            $input.on 'input paste cut', ()->
                val = $(@).val()
                $num.html limit - val.length
                if val.length > limit
                    $(@).val val.slice 0,limit
                    $num.html 0

    page.init();

    return  page
