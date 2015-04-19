/**
 * alias
 * @wilson
 */

var path = require('path');
var configs = require('./config');

module.exports = {
    'pages': path.join(__dirname, configs.dirs.pages),
    'vendor': path.join(__dirname, configs.dirs.vendor),
    'modules': path.join(__dirname, configs.dirs.modules),
    'widgets': path.join(__dirname, configs.dirs.widgets),

    'cookie': 'modules/cookie/jquery.cookie',
    'WebUploader': 'modules/uploader/webuploader.min',
    'jQValidation': 'vendor/jquery-validation/dist/jquery.validate.min',

    // 组件
    'Swipe': 'modules/swipejs/swipe',
    'Menu': 'modules/menu/menu',
    'Tab': 'modules/tab/tab',
    'goodSlider': 'modules/goodSlider/goodSlider',
    'goodTypeSelect': 'modules/goodTypeSelect/goodTypeSelect',
    'Amount': 'modules/amount/amount',
    'Amount_v2': 'modules/amount/amount_v2',
    'DropDown': 'modules/dropDown/dropDown',
    'AutoComplete': 'modules/autoComplete/autoComplete',
    'Checkbox': 'modules/checkbox/checkbox',
    'CheckAll': 'modules/checkbox/checkAll',
    'SelectBox': 'modules/selectBox/selectBox',
    'ModalBox': 'modules/modalBox/modalBox',
    'LightModalBox': 'modules/lightModalBox/lightModalBox',
    'goodListHover': 'modules/goodListHover/goodListHover',
    'DatePicker': 'modules/datePicker/datePicker_v2',
    'LoginModalBox': 'modules/loginModalBox/loginModalBox',
    'PlaceSelector': 'modules/placeSelector/placeSelector',
    'PlaceSelector_v2': 'modules/placeSelector/placeSelector_v2',
    'NavDropDown': 'modules/navDropDown/navDropDown',
    'TopbarDropDown': 'modules/topbarDropDown/topbarDropDown',
    'AddCartModalBox': 'modules/addCartModalBox/addCartModalBox',
    'EditOrderInfoModalBox': 'modules/editOrderInfoModalBox/editOrderInfoModalBox',
    'PayOrderResultModalBox': 'modules/payOrderResultModalBox/payOrderResultModalBox',
    'VerifyEmailModalBox': 'modules/verifyEmailModalBox/verifyEmailModalBox',
    'VerifyPhoneModalBox': 'modules/verifyPhoneModalBox/verifyPhoneModalBox',
    'Validator': 'modules/validator/validator',

    'validate': 'modules/validation/sp-validate',

    'NewAddress': 'modules/address/newAddress',
    'AddressList': 'modules/address/addressList',
    'NewInvoice': 'modules/invoice/newInvoice',
    'InvoiceList': 'modules/invoice/invoiceList',
    'SetEmailModalBox': 'modules/setEmailModalBox/setEmailModalBox',
    'SetPhoneModalBox': 'modules/setPhoneModalBox/setPhoneModalBox',
    'OrderList': 'modules/order/orderList',
    'SetPassWordModalBox': 'modules/setPassWordModalBox/setPassWordModalBox',
    'FavoriteList': 'modules/favoriteList/favoriteList',
    'Cart': 'modules/cart/cart',
    'Placeholder': 'modules/placeholder/jquery.placeholder',
    'agreementModalBox': 'modules/agreementModalBox/agreementModalBox',
    'uploader': 'modules/uploader/uploader',
    'ConfirmModalBox': 'modules/confirmModalBox/confirmModalBox',
    'liteModalBox': 'modules/liteModalBox/liteModalBox',

    // 模块
    'config': 'modules/config/config',
    'Sp': 'modules/spModel/spModel',
    'goodApi': 'modules/goodApi/goodApi',
    'preLoad': 'modules/preLoad/preLoad'
}
