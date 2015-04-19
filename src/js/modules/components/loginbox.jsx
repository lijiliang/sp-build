define(['Sp','Validator','widgets/reactCheckbox/reactCheckbox','cookie'],function(Sp, Validator,ReactCheckbox,cookie){

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

    var Loginbox = React.createClass({
        getInitialState: function(){
            return {
                account: {
                    val: $.cookie('sipin_member_name') || '',
                    error: true,
                    info:"",
                    isChecked: false
                },
                password: {
                    val: '',
                    error: true,
                    info:"",
                    isChecked: false
                },
                submit_active: false,
                remember: false
            }
        },
        componentDidMount: function(){
             var self = this;
             setInterval(function(){
                var account = document.getElementById('account').value.trim() || null;
                var password = document.getElementById('password').value.trim() || null;

                self.setAccount(account);
                self.setPass(password);
             },500);
         },
         checkEnter: function(e){
             if(e.keyCode==13){
                 this.submitLogin(e);
             }
         },
         setAccount: function(value){
             if(value){
                 var state = this.state;

                 state.account.error = !(value.length>=4);
                 if(!state.account.error)
                    state.account.info = "";
                 else{
                     if(value.length>1 && value.length<4){
                         state.account.info = "请输入正确的帐号";
                     }
                 }

                 state.account.val = value;
                 this.setState(state);
             }
         },
        checkAccount: function(e){
            e.preventDefault();
            e.stopPropagation();
            var value = e.target.value;
            this.setAccount(value);
        },
        setPass: function(value){
            if(value){
                var state = this.state;

                state.password.error = !(value.length>=6);
                if(!state.password.error)
                    state.password.info = "";
                else{
                    if(value.length>1 && value.length<6){
                        state.password.info = "请输入正确的密码";
                    }
                }

                state.password.val = value;
                this.setState(state);
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
        submitLogin: function(e){
            e.preventDefault();
            e.stopPropagation();
            var self = this;
            var state = this.state;

            if(!state.account.val.length && !state.password.val.length){
                return;
            }

            if( !state.account.val.length ){
                state.account.error=true;
                state.account.info = "请输入帐号";
            }
            if( !state.password.val.length ){
                state.password.error=true;
                state.password.info = "请输入密码";
            }

            // 如果长度正确
            if( !state.account.error && !state.password.error){
                // 正则检查
                var account = $.trim(state.account.val);
                if(validator.methods.email(account)){
                    // 检查邮箱
                    Sp.get( Sp.config.host + "/api/member/checkEmail",{
                        email: account
                    },function(res){
                        if(res && res.code != 0){
                            state.account.info = "帐号不存在";
                            state.account.isChecked = false;
                            self.setState(state);
                        }else{
                            state.account.isChecked = true;
                            self.setState(state);
                            self.login();
                        }
                    });
                }else if (validator.methods.phone(account)){
                    // 检查手机
                    Sp.get( Sp.config.host + "/api/member/checkMobile",{
                        mobile: account
                    },function(res){
                        if(res && res.code != 0){
                            state.account.info = "帐号不存在";
                            state.account.isChecked = false;
                            self.setState(state);
                        }else{
                            state.account.isChecked = true;
                            self.setState(state);
                            self.login();
                        }
                    });
                }else {
                    // 检查用户名
                    Sp.get( Sp.config.host + "/api/member/checkName",{
                        name: account
                    },function(res){
                        if(res && res.code != 0){
                            state.account.info = "帐号不存在";
                            state.account.isChecked = false;
                            self.setState(state);
                        }else{
                            state.account.isChecked = true;
                            self.setState(state);
                            self.login();
                        }
                    });
                }

            }else{
                if(state.account.val!="" && state.account.error){
                    state.account.info = "帐号格式不正确";
                }
                if(state.password.val!="" && state.password.error){
                    state.password.info = "密码格式不正确";
                }
            }

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
            Sp.post( Sp.config.host + '/api/member/login',postData,function(res){
                if(res&&res.code==0){
                    if(typeof searchObj['redirect'] !="undefined")
                        window.location.href = searchObj['redirect'];
                    else
                        window.location.href = "/";
                }else{
                    if(res&&res.code==1&&res.data.status==0){
                        var _info = function(){
                            return(
                                <span>此帐号尚未激活，请<a target="_blank" href={res.data.url}>马上激活</a></span>
                            )
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
            })
        },
        showAccountTips: function(){
            var state = this.state;
            if( !state.account.val.length ) {
                state.account.info = "请输入正确的帐号";
                this.setState(state);
            }
        },
        showPassTips: function(){
            var state = this.state;
            if( !state.account.val.length ){
                state.password.info = "请输入正确的密码";
                this.setState(state);
            }
        },
        render: function(){

            var loginBtnClass = classSet({
                'formbtn': true,
                'btn-primary': true,
                '_disable': this.state.submit_active || (this.state.account.error || this.state.password.error)
            });

            return (
                <form method="post" action="#" className="form">
                    <div className="form-item">
                        <div className="form-field">
                            <input id="account" onKeyUp={this.checkEnter} onFocus={this.showAccountTips} onChange={this.checkAccount} type="text" className="form-text" name="username" placeholder="手机号/邮箱/用户名" />
                        </div>
                        <p className="u-color_white is_account_error u-mt_10 _tips_p" style={{display: "block"}}>{this.state.account.info}</p>
                    </div>
                    <div className="form-item u-mt_30">
                        <div className="form-field">
                            <input id="password" onKeyUp={this.checkEnter} onFocus={this.showPassTips} onChange={this.checkPass} type="password" className="form-text" name="password" placeholder="密码" />
                        </div>
                        <p className="u-color_white is_password_error u-mt_10 _tips_p" style={{display: "block"}}>{this.state.password.info}</p>
                    </div>
                    <div className="form-item u-mt_15">
                        <div className="form-field form-field-rc u-clearfix">
                            <label className="u-fl">
                                <ReactCheckbox checked={this.state.remember} onChange={this.checkRemember} label='自动登录' />
                            </label>
                            <a className="forget-link u-fr u-color_white" href="/member/forgotPass">忘记密码？</a>
                        </div>
                    </div>
                    <div className="form-action action-left u-mt_30">
                        <a onClick={this.submitLogin} className={loginBtnClass} href="javascript:void(0);">登录</a>
                    </div>
                    <div className="form-action action-left u-mt_20">
                        还不是斯品用户？<a className="btn-right" href="/member/register">马上注册》</a>
                    </div>
                </form>
            )
        }
    });

    /**
     * 返回参数
     */
    return Loginbox;

});
