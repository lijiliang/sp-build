define(['Sp','Validator','cookie','./tpl-loginbox-modal','./tpl-loginbox-page'],function(Sp, Validator,cookie,tplLoginboxModal,tplLoginbox){

    /**
     * 登录页组件
     */
    var validator = new Validator();
    var classSet = React.addons.classSet;

    // 获取search字串
    var searchVar = location.search.length?location.search:'';
    searchVar = searchVar.substr(1);
    var searchVarArr = searchVar.split('&');
    var searchObj = {};
    for(var i = 0; i< searchVarArr.length; i++){
        var tmp = searchVarArr[i].split("=");
        searchObj[tmp[0]]=tmp[1];
    }

    var timer = null;

    var Loginbox = React.createClass({
        getInitialState: function(){
            return {
                account: {
                    val: $.cookie('sipin_member_name') || '',
                    error: true,
                    info:"",
                    isChecked: false,
                    _val:''
                },
                password: {
                    val: '',
                    error: true,
                    info:"",
                    isChecked: false,
                    _val:''
                },
                submit_active: false,
                remember: false,
                isChecking: false,
                checkTime: 15 // 只进行15次错误尝试
            };
        },
        componentDidMount: function(){

             var self = this;

             if($.cookie('sipin_member_name')){
                 $("#account").val($.cookie('sipin_member_name'));
                 $("#password").val("");
             }

             timer = setInterval(function(){

                var state = self.state;

                var account = $("#account").val().trim() || null;
                var password = $("#password").val() || null;

                if(state.account._val!=account)
                    self.setAccount(account);
                if(state.password._val!=password)
                    self.setPass(password);

                if(!$("#account").is(":focus") && state.account._val!=account && !state.isChecking && state.checkTime>0 ){
                    self.checkExist();
                }

             },500);

         },
         componentWillUnmount: function(){
             clearInterval(timer);
         },
         checkEnter: function(e){
             if(e.keyCode==13){
                 this.login();
             }
         },
         checkExist: function(){
             var self = this;
             var account_val = $("#account").val();
             var state = this.state;

             //console.log( account_val.length>=4 , state.account.isChecked === false);

             if( account_val.length>=4 && state.account.isChecked === false ){

                 state.account.info = "正在检查帐号是否存在...";
                 state.account.error = false;
                 state.isChecking = true;
                 // 正则检查
                 var account = $.trim(state.account.val);
                 if(validator.methods.email(account)){
                     // 检查邮箱
                     Sp.get( Sp.config.host + "/api/member/checkEmail",{
                         email: account
                     },function(res){
                         if(res && res.code !== 0){
                             state.account.info = "帐号不存在";
                             state.account.isChecked = false;
                         }else{
                             state.account.isChecked = true;
                             state.account.info = '';
                         }
                         state.account._val = account;
                         self.setState(state);
                         self.setChecked();
                     },function(err){
                         state.isChecking = false;
                         state.checkTime = state.checkTime-1;
                         state.account.info = '';
                         self.setState(state);
                         self.setChecked();
                     });
                 }else if (validator.methods.phone(account)){
                     // 检查手机
                     Sp.get( Sp.config.host + "/api/member/checkMobile",{
                         mobile: account
                     },function(res){
                         if(res && res.code !== 0){
                             state.account.info = "帐号不存在";
                             state.account.isChecked = false;
                         }else{
                             state.account.info = '';
                             state.account.isChecked = true;
                         }
                         state.account._val = account;
                         self.setState(state);
                         self.setChecked();
                     },function(err){
                         state.isChecking = false;
                         state.checkTime = state.checkTime-1;
                         state.account.info = '';
                         self.setState(state);
                         self.setChecked();
                     });
                 }else {
                     // 检查用户名
                     Sp.get( Sp.config.host + "/api/member/checkName",{
                         name: account
                     },function(res){
                         if(res && res.code !== 0){
                             state.account.info = "帐号不存在";
                             state.account.isChecked = false;
                         }else{
                             state.account.isChecked = true;
                             state.account.info = '';
                         }
                         state.account._val = account;
                         self.setState(state);
                         self.setChecked();
                     },function(err){
                         state.isChecking = false;
                         state.checkTime = state.checkTime-1;
                         state.account.info = '';
                         self.setState(state);
                         self.setChecked();
                     });
                 }
             }
         },
         setChecked: function(){
             var state = this.state;
             var value =  $("#account").val();

            //  if(state.account._val!=="" && state.account._val!==value){
            //      state.account.isChecked = false;
            //  }

             //console.log(!state.account.error , !state.password.error , state.account.isChecked);
             if(!state.account.error && !state.password.error && state.account.isChecked){
                 state.submit_active = true;
             }else{
                 state.submit_active = false;
             }

             this.setState(state);
         },
         setAccount: function(value){
             var self = this;
             var state = this.state;

             if(value){

                 state.account.error = value.length<4;

                 if (!state.account.error)
                    state.account.info = "";
                 else{
                     if(value.length >0 && value.length<4){
                         state.account.info = "请输入正确的帐号";
                     }
                 }

                 state.account.val = value;

             }else{
                 state.account.error = true;
                //  state.account.info = "请输入正确的帐号";
                 state.account.info = "";
                 state.account.val = "";
             }

             state.account.isChecked = false;
             state.checkTime = 15;
             this.setState(state);
             this.setChecked();
         },
        checkAccount: function(e){
            e.preventDefault();
            e.stopPropagation();
            var value = e.target.value;
            this.setAccount(value);
        },
        setPass: function(value){

            var state = this.state;

            if(value){

                state.password.error = value.length<6;

                if(!state.password.error)
                    state.password.info = "";
                else{
                    if(value.length>0 && value.length<6){
                        state.password.info = "请输入正确的密码";
                    }
                }

                state.password.val = value;
                state.password._val = value;

                this.setState(state);

                this.setChecked();
            }else{

                state.password.val = '';
                state.password._val = '';
                state.password.info = "";
                state.password.error = true;
                this.setState(state);

                this.setChecked();
            }
        },
        checkPass: function(e){
            e.preventDefault();
            e.stopPropagation();
            var value = e.target.value;
            this.setPass(value);
        },
        checkRemember: function(isChecked){
            var state = this.state;
            state.remember = isChecked;
            this.setState(state);
        },
        login: function(){
            var self = this;
            var state = this.state;
            var postData = {
                account: state.account.val,
                password: state.password.val,
                remember: state.remember ? 1 : 0
            };

            if(!this.state.submit_active){
                return false;
            }

            if(postData.remember){
                $.cookie('sipin_member_name',postData.account);
            }else{
                $.removeCookie('sipin_member_name');
            }
            Sp.post( Sp.config.host + '/api/member/login',postData,function(res){
                if(res&&res.code===0){
                    if(self.props.pageType == "pop"){
                        self.props.success();
                    }else{
                        // 登录成功跳转到首页
                        if(typeof searchObj.redirect !=="undefined")
                            window.location.href = searchObj.redirect;
                        else
                            window.location.href = "/";
                    }
                }else{
                    if(res&&res.code==1&&res.data.status===0){
                        var _info = function(){
                            return(
                                <span>此帐号尚未激活，请<a target="_blank" href={res.data.url}>马上激活</a></span>
                            );
                        };
                        state.account.info = _info();
                    }else{
                        // 提示错误信息
                        var errors = res.data.errors;
                        if(errors.account)
                            state.account.info = errors.account[0];
                        if(errors.password)
                            state.password.info = errors.password[0];
                    }
                }
                self.setState(state);
            });
        },
        showAccountTips: function(){
            var state = this.state;
            if( state.account.val.length >0 && state.account.val.length<4 ) {
                state.account.info = "请输入正确的帐号";
                this.setState(state);
            }
        },
        showPassTips: function(){
            var state = this.state;
            if( state.account.val.length>0 && state.account.val.length<6 ){
                state.password.info = "请输入正确的密码";
                this.setState(state);
            }
        },
        getLoginBtnClass: function(){
            return classSet({
                'j-login-submit': true,
                'formbtn': true,
                'btn-primary': true,
                '_disable': !this.state.submit_active
            });
        },
        render: function(){

            //console.log(this.state);
            if(this.props.pageType == "pop"){
                return tplLoginboxModal.apply(this);
            }else{
                return tplLoginbox.apply(this);
            }

        }
    });

    /**
     * 返回参数
     */
    return Loginbox;

});
