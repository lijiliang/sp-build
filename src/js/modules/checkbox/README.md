## `checkbox`使用说明

dom: `<span class="ui-checkbox" _name="checkbox_all" _checked="true">全选</span>`

`_name`会自动添加到隐藏的input的name

`_checked`为初始化的状态

### 用法1:
`var checkbox = new Checkbox(opts)`

`opts`对象:

```
{
    el: 默认为null, 传入dom, 只能传入一个dom
    callback: 选中和取消后的回调
}
```

选择和取消: 点击该dom 或者 `checkbox.on();checkbox.off();`


### 用法2:

```
$(xxx).checkbox(opts);
```

初始化时传入`opts`对象:

```
{
    callback: 选中和取消后的回调
}
```

选择和取消: 点击该dom 或者 `$(xxx).checkbox('on');$(xxx).checkbox('off');`

选择和取消禁止回调:

`$(xxx).checkbox(action, withoutCallback);`

`action`: `on`或`off`, `withoutCallback`为Boolean值

`$(xxx).checkbox('on', true);$(xxx).checkbox('off', true);`



## `checkAll`使用说明
```
<div class='wrapper' id="checkbox-check-all-demo">
    <span class="ui-checkbox j-checkbox-check-all" _name="checkbox_all">全选</span><br>
    <span class="ui-checkbox j-checkbox-check-self" _name="checkbox_01" _checked="false">b</span>
    <span class="ui-checkbox j-checkbox-check-self" _name="checkbox_all" _checked=true>a</span>
    <span class="ui-checkbox j-checkbox-check-self" _name="checkbox_01" _checked=false>t</span>
</div> j-checkbox-check-self
```
```
$('.wrapper').checkAll({
    checkboxClass: '.j-checkbox-check-self' //单选的checkbox的class
    checkAllClass: '.j-checkbox-check-all'  //全选的checkbox的class
    callback: (checked, $el)->  //所有checkbox选中和取消的回调,checked为Boolean值,$el为当前dom jq对象
})
```