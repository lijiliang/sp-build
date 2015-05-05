/**
 * alias
 * @wilson
 */

var path = require('path');
var configs = require('./config');

module.exports = {
    'pages': path.join(__dirname, '../../', configs.dirs.pages),
    'vendor': path.join(__dirname, '../../', configs.dirs.vendor),
    'modules': path.join(__dirname, '../../', configs.dirs.modules),
    'widgets': path.join(__dirname, '../../', configs.dirs.widgets),

    'cookie': 'modules/cookie/jquery.cookie',
    'WebUploader': 'modules/uploader/webuploader.min',
    'jQValidation': 'vendor/jquery-validation/dist/jquery.validate.min',

    // 组件
    'Swipe': 'modules/swipejs/swipe',
    'Menu': 'modules/menu/menu',
    'Tab': 'modules/tab/tab',
    'goodSlider': 'modules/good-slider/good-slider',
    'goodTypeSelect': 'modules/good-type-select/good-type-select',
    'Amount': 'modules/amount/amount',
    'Amount_v2': 'modules/amount/amount-v2',
    'DropDown': 'modules/dropDown/dropDown',
    'AutoComplete': 'modules/auto-complete/auto-complete',
    'Checkbox': 'modules/checkbox/checkbox',
    'CheckAll': 'modules/checkbox/checkAll',
    'SelectBox': 'modules/select-box/select-box',
    'ModalBox': 'modules/modal-box/modal-box',
    'LightModalBox': 'modules/light-modal-box/light-modal-box',
    'goodListHover': 'modules/good-list-hover/good-list-hover',
    'DatePicker': 'modules/date-picker/date-picker-v2',
    'LoginModalBox': 'modules/login-modal-box/login-modal-box',
    'PlaceSelector': 'modules/place-selector/place-selector',
    'PlaceSelector_v2': 'modules/place-selector/place-selector-v2',
    'NavDropDown': 'modules/nav-drop-down/nav-drop-down',
    'TopbarDropDown': 'modules/topbar-drop-down/topbar-drop-down',
    'AddCartModalBox': 'modules/add-cart-modal-box/add-cart-modal-box',
    'EditOrderInfoModalBox': 'modules/edit-order-info-modal-box/edit-order-info-modal-box',
    'PayOrderResultModalBox': 'modules/pay-order-result-modal-box/pay-order-result-modal-box',
    'VerifyEmailModalBox': 'modules/verify-email-modal-box/verify-email-modal-box',
    'VerifyPhoneModalBox': 'modules/verify-phone-modal-box/verify-phone-modal-box',
    'Validator': 'modules/validator/validator',

    'validate': 'modules/validation/sp-validate',

    'NewAddress': 'modules/address/new-address',
    'AddressList': 'modules/address/address-list',
    'NewInvoice': 'modules/invoice/new-invoice',
    'InvoiceList': 'modules/invoice/invoice-list',
    'SetEmailModalBox': 'modules/set-email-modal-box/set-email-modal-box',
    'SetPhoneModalBox': 'modules/set-phone-modal-box/set-phone-modal-box',
    'OrderList': 'modules/order/order-list',
    'SetPassWordModalBox': 'modules/set-password-modal-box/set-password-modal-box',
    'FavoriteList': 'modules/favorite-list/favorite-list',
    'Cart': 'modules/cart/cart',
    'Placeholder': 'modules/placeholder/jquery.placeholder',
    'agreementModalBox': 'modules/agreement-modal-box/agreement-modal-box',
    'uploader': 'modules/uploader/uploader',
    'ConfirmModalBox': 'modules/confirm-modal-box/confirm-modal-box',
    'liteModalBox': 'modules/lite-modal-box/lite-modal-box',

    // 模块
    'config': 'modules/config/config',
    'Sp': 'modules/sp/sp',
    'goodApi': 'modules/good-api/good-api',
    'preLoad': 'modules/preLoad/preLoad'
};
