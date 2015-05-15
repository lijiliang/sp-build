require('preLoad');
require('Checkbox');

var liteModalBox = require('liteModalBox')
,   Sp = require('Sp')
,   content_tmpl = require('./comment-service');

var commentModal = new liteModalBox({
    top: 250,
    width: 800,
    mask: true,
    title: '您对本次服务的评价',
    contents: '<div id="comment-service-tmpl"></div>',
    closeBtn: true,
    maskClose: true
});

$('#comment-service-tmpl').html(content_tmpl({}));

var $radios = $('#commment-service-radio .ui-radio')
,   $input = $('#comment-service-type');

$radios.checkbox({
    callback: function (checked, $el) {
        $radios.checkbox('off', true);
        $el.checkbox('on',true);
        $input.val($el.data('value'));
    }
});

$('#comment-trigger').on('click', function () {
    commentModal.show();
});