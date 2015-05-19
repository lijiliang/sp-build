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

/**
 * Client Config
 */
var app = app || {};
(function () {
    'use strict';

    var SERVER_CONFIG = {
        host: 'sipin.eric',
        port: 3014
    };

    var CHAT_WEBSITE = {
        WEBSITE_1:      1,
        WEBSITE_2:      2,
        WEBSITE_3:      3,
        WEBSITE_4:      4,
        TEXT: {
            '1':    'WEB官网',
            '2':    '移动官网',
            '3':    'Android应用',
            '4':    'iOS应用'
        }
    };

    if(!app.hasOwnProperty('SERVER_CONFIG')){
        app['SERVER_CONFIG'] = SERVER_CONFIG;
    }
    if(!app.hasOwnProperty('CHAT_WEBSITE')){
        app['CHAT_WEBSITE'] = CHAT_WEBSITE;
    }
})();