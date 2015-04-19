React = require('vendor/react/react');

SliderItem = React.createClass({
  render: function(){

  }
});

SliderBody = React.createClass({
  render: function(){

  }
});

SliderContainer = React.createClass({
  render: function(){

  }
});

Slider = React.createClass({
  render: function(){
    return <div>Hello {this.props.name}</div>;
  }
});

module.exports = Slider;

//test
React.renderComponent(
  <HelloMessage name="John" />,
  document.getElementById('container')
);
