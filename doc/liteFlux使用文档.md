# lite-flux
### A small flux library for react app

===

### 创建store与action

```
var liteFlux = require('lite-flux);

// 创建名为store1的store,顺便创建相应操作store的action
var store1 = liteFlux.store("store1",{
	data: {
		name: "tom"
	},
	actions: {
		getName: function(){
			// 获取 store
			console.log(this.getStore());
		},
		setName: function(){
			// 修改 store
			var data = this.getStore();
			data.name = "mary";
			this.setStore(data);
		}
	}
});

// 新增一个action
store1.addAction('changeNameAgain', function(){
	...
});

// 获取store
liteFlux.store("store1").getStore();

// 修改store
liteFlux.store("store1").setStore({
	name: "haha"
});

// 触发action
store1.getAction().getName();
liteFlux.action("store1").getName();
liteFlux.event.emit("store1.getName");

// 你也可以这样创建action
liteFlux.action("store1",{
	getName: function(){
		// 获取 store
		console.log(this.getStore());
	},
	setName: function(){
		// 修改 store
		var data = this.getStore();
		data.name = "mary";
		this.setStore(data);
	}
})


```

### 把组件的state与store绑定

> 一般只对一个较大的组件使用，子组件通过props传递状态

```
var liteFlux = require('lite-flux);
var React = require('react');

var Event = liteFlux.event;

var store8 = liteFlux.store("store8",{
	data: state1,
	actions: {
		realChangeName: function(name){
			var store = this.getStore();
			store.name = name;
			this.setStore(store);
		}
	}
});

var App = React.createClass({
	mixins:[liteFlux.mixins.storeMixin('store8')],
	changeName: function(name){
		Event.emit("store8.realChangeName", "mary");
	},
	render: function() {
		return (
			<div>dddddddd</div>
		);
	}
});

```

### 数据校验

```
var Validator = liteFlux.validator;

var store2 = liteFlux.store("store2",{
	data: {
		form: {
			username: '111111',
			password: '',
			email: ''
		},
		fieldError: {
			form: {
				  username: ['', ''] //最终的错误信息会保存成数组放置在这里
			}
		}
	}
});

var validatorTest = Validator(store2,{
	'form.username':{
		required: true,
		lessThen3: '',
		message: {
			required: "不能为空",
			lessThen3: "不能少于三位" // 对应出错信息提示
		}
	},
	'form.password':{
		required: true,
		message: {
			required: "不能为空"
		}
	}
	},{
		//oneError: true //是否只要错了一次就中断
});

//自定义校验规则，在valid调用之前定义
validatorTest.rule('lessThen3', function(val) {
	return val < 3;
});

// 全部校检一次
validatorTest.valid(); //true || false

// 只校检单条数据
validatorTest.valid('form.username');

```


