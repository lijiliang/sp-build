define(['Sp'],function(Sp){

    /**
     * 顶部用户状态组件
     */
    var Memberbar = React.createClass({
        getInitialState: function(){
            return {
                member: {
                    id: _SP.member,
                    name: _SP.member_auth?_SP.member_auth.name:""
                }
            };
        },
        componentDidMount:function(){
            var _this = this;
            var member = this.state.member;
            Sp.on("sp-update-member-name",function(e, name){
                member.name = name;
                _this.setState({
                    member: member
                });
            });
        },
        componentWillUnmount: function() {
            Sp.off("sp-update-member-name");
        },
        render: function(){

            var self = this;

            var logout = function(){
                return (
                    <span className="header__loginbar">
                        <a className="j-login u-mr_15" href="/member/login">登录</a><a href="/member/register">注册</a>
                    </span>
                );
            };

            var login = function(){
                return (
                    <span>
                        <a href="/member" className="u-color_gold u-mr_10">{self.state.member.name}</a>
                        <a href="/member/logout">退出</a>
                    </span>
                );
            };

            var loginHTML = logout();
            if(self.state.member.id){
                loginHTML = login();
            }

            return (
                <ul>
                    <li className="header__loginbar">
                        {loginHTML}
                    </li>
                    <li className="header__nav-border-right">
                        <span></span>
                    </li>
                </ul>
            );
        }
    });

    /**
     * 返回参数
     */
    return Memberbar;

});
