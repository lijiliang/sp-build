define(function(){

    /**
     * checkBox组件
     */
    var reactCheckBox = React.createClass({
        onClick : function (event) {
            this.setState({ checked: !this.state.checked });

            if (this.props.onChange) {
                this.props.onChange(!this.state.checked);
            }
        },
        getInitialState: function () {
            return { checked: !!this.props.checked };
        },
        componentWillReceiveProps: function (props) {
            this.setState({ checked: props.checked });
        },
        render: function () {
            return (
                <i className={'react-checkbox ' + (this.state.checked ? 'is-checked' : '')} onClick={this.onClick}>{this.props.label}</i>
            );
        }
    });

    /**
     * 返回参数
     */
    return reactCheckBox;

});
