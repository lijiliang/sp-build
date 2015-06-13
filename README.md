# SLIME PACK


## 概述111
>突然想到了怪物史莱姆，丑陋，肮脏，但可爱，这与前端的产出一样，但希望在生产过程中足够可爱与简单。
SLIME PACK是一个简单的前端编译系统，基于nodejs，支持 `script / style / templet` 的打包与分包。

 -  
#### 支持生产(produce)和开发(develop)模式
运行`gulp`，启动开发者模式，支持WATCH，运行`gulp build`，开启生产模式，一般需要的后端（PHP/JSP）对应的MAP文件，CDN需要的hash可以在配置中修改，默认开启

 -  
#### 支持模块化
多人协作开发需要模块化，前端现在都不是一个人在战斗，各种模式混杂，AMD，CMD，~~TMD~~（你懂的，原生无模式）
 都是比较常用的模式， SLIME PACK全部都支持，包括~~TMD~~模式，因为SLIME PACK是对`webpack`的封装, 什么是webpack你可以看一下这里 [链接地址](http://webpack.github.io)

 -  
#### 支持的style
这一部分在弄它的时候踩了些坑，我本来是想全部用`webpack`来封 装的，但后来发现， webpack这个坑货对于sass的打包会出错，
而且`sass-loader`这玩意作者也不是很给力，啃了几天英文还是果断放弃算了，所以这一部分基于gulp（靠谱）来实现的。
那么现在终于可以支持`sass / less / stylus / css`这几个坑货了  


 -  
#### 支持的script
有的同学喜欢coffee，有的喜欢原生javascript，我本人后者，不想在踩坑。原生js也不是那么难看，
而且ES6不是也快来了吗？yield yeah! 支持`coffee / javascript`

 -  
#### 支持react
facebook好像也出了些好东东，这个是其一，人家官方排名都很靠前的一个项目，SLIME PACK支持`jsx / cjsx `的编译输出
[传送门](http://https://facebook.github.io/)

 -  
#### 支持的templet
目前支持`handlesbar / html / php / jsp`，PHP/JSP在解析后会生成保留扩展名，其他的模板的扩展名会转变为`.html`
暂时还不支持'swig'，在gulp-task任务中可以通过nodejs获取数据并传送给模板render

 -  
#### 支持实时生成雪碧图，支持实时DEMO和WATCH
实时WATCH `雪碧图、JS、CSS`并生成最新的DEMO，可以实时看到模板CSS输出效果及js交互效果

## 依赖/安装/运行
>非常简单  

node 0.12.1  
~~ruby 2.2.2 [下载地址](http://rubyinstaller.org/downloads/)~~

```
// 安装
$ cd git
$ git clone https://github.com/webkixi/sp-build.git
$ cd sp-build
$ npm install
$ bower install

// 依赖
$ npm install -g gulp
$ npm install -g bower
$ //gem install sass

// 运行
$ gulp

你的任何修改会实时响应到浏览器(css/js/html)
```

## 生成规则
一般SLIME PACK直接处理目录，如下例所示，但也支持JSON对象和数组形式，请参考函数部分  
> 打包：把目录下所有`css / js`合并成一个文件，文件名为目录名  
分包：按子目录名打包  
子分包：即子目录的子目录，会以'-'来分割  
忽略目录：下划线开头的目录会被忽略打包，是目录：如`_xxx/`，但里面的模块可以被外部使用  

```html
打包示例

├── aaa/
    ├── bbb.js
    ├── ccc/
    ├── ├── ddd.js
    ├── _abc/
    ├── ├── yyy.js
    ├── ├── zzz.js

打包会产出
aaa.js = (bbb.js + ddd.js)
_abc被自动忽略，你可以把测试文件放心的放在忽略目录中  

//函数示例[函数说明](#function)
slime.build('./aaa',true)

```  

```html
分包示例

├── aaa/
    ├── bbb/
    ├── ├── eee.js
    ├── ccc/
    ├── ├── ddd.js

分包会产出
bbb.js = (eee.js)
ccc.js = (ddd.js)  


//函数示例[函数说明](#function)
slime.build('./aaa',false)
```

```html
子分包示例

├── aaa/
    ├── bbb/
    ├── ├── eee.js
    ├── ├── fff.js
    ├── ├── xxx/
    ├── ├── ├── yyy.js
    ├── ├── ├── zzz.js
    ├── ccc/
    ├── ├── ddd.js  

子分包会产出
bbb.js = (eee.js + fff.js)  
bbb-xxx.js = (yyy.js + zzz.js)
ccc.js = (ddd.js)  


//函数示例[函数说明](#function)
slime.build('./aaa',false)
```

 -  

### 目录结构  
> 下面是目录结构表格

主结构  
```html
├── 主结构
    ├── _builder        //【目录】--- 配置文件目录
    ├────├───configs    //【目录】--- 配置文件，自动化核心脚本
    ├────├───gulp-task  //【目录】--- gulp任务分解模块
    ├── src             //【目录】--- 源文件目录
    ├── dist            //【目录】--- 产出目录，基本上不要管
    ├── bower.json      //【文件】--- bower配置文件
    ├── config.js       //【文件】--- 初始化目录配置文件
    ├── gulpfile.coffee //【文件】--- gulp task结构
    ├── package.json    //【文件】--- npm配置文件


```  

JS结构  
```html
你应该关注产出目录pages（分包），其他目录是辅助性质，有助于提升代码的良好结构  
对应 gulp-task 任务模块:
 * concat-common-js.coffee
 * wp.coffee

├── js
    ├── global   // 【TMD】  -- 主动打包common.js -- 自定义框架 -- 支持window全局
    ├── libs     // 【CMD/AMD】--- 被动产出 --- 自定义类库
    ├── mixins   // 【CMD/AMD】--- 被动产出 --- 自定义mixins--- 适用于react
    ├── modules  // 【CMD/AMD】--- 被动产出 --- 自定义组合模块---由widgets组件合并
    ├── pages    // 【CMD/AMD】--- 主动分包 --- 业务 ---与php/jsp同步
    ├── vendor   // 【TMD】  -- 主动打包common.js -- 第三方库，如JQ
    ├── widgets  // 【CMD/AMD】--- 被动产出 --- 细粒化组件 ---适用于react与原生  


```  

CSS结构  
```html
你应该关注产出目录pages（分包），modules是公共部分，除非你要换一个css库  
对应 gulp-task 任务模块:
 * css-common.coffee
 * css-pages.coffee  

├── css
    ├── modules  // 【目录】--- 被动产出 --- css库  
    ├── pages    // 【目录】--- 主动分包 --- 业务

```  

HTML结构
```html
_common是公共部分， xxx为任意文件夹，业务DEMO文件夹，具体以目录为准  
对应 gulp-task 任务模块:
 * html.coffee

├── html
    ├── _common  // 【目录】--- 被动产出 --- 公共头尾部  
    ├── xxx    // 【目录】--- 主动分包 --- demo


```  

-  

### 入口(entry)
<a id='function' />
通过slime.build生成，具体参考gulp-task目录下的模块文件

```
默认类型说明
//style: ['css', 'scss', 'sass', 'less', 'stylus', 'styl']  
//templet: ['hbs', 'swig', 'htm', 'html', 'php', 'jsp']  
//script: ['js', 'jsx', 'coffee', 'cjsx']  


/*
* 静态文件生成函数
* {parm1} {string} // 文件名，完整的文件名称，如绝对路径 d:\xxx\yyy.js
*         {string} // 配置名，config中默认的名称，如 config -> pages  
*         {string} // 目录名，如存在的目录 d:\xxx  
*         {array}  // 组合数组，数组元素为string路径 如 ['d:\xxx\yyy.js','d:\xxx\aaa.js']  
*         {json}   // 组合JSON*
* {parm2} {boolean}// 打包/分包，true=打包、false=分包
* {parm3} {json object}
* return stream 不要理会
*/

var slime = require('./_builder/configs/slime.config.js');
slime.build(entry, [pack], [options])  


//打包、分包都会产出`{key: value}`对象，vlaue为数组，分包是多元素json
options:
 * [rename] 类型：String --- 分包不支持
   //重命名key值
   0、slime.build（'./a', true, {rename: 'xxx',type: 'sass'})    //产出 xxx.css
   1、slime.build(['a.js','b.js'],{rename: 'xxx'})  //产出 xxx.js
   2、slime.build({aaa: ['a.jsx','b.js']},{rename: 'xxx'})  //产出 xxx.js
   3、slime.build('./abc.js',{rename: 'xxx'})  //产出 xxx.js

 * [type] 类型：String --- script不用指定，style/templet，都需要明确指定，如
   //指定文件类型
   1、slime.build('./a',{type: 'sass'})
   2、slime.build('./a',{type: 'hbs'})

 * [prepend] 类型：Array --- 分包不支持
   //value前插文件
   1、slime.build('./a',{prepend: ['./xxx.js']})

 * [apend] 类型：Array --- 分包不支持
   //value后插文件
   1、slime.build('./a',{apend: ['./xxx.js']})

```

```
# css 示例(coffee)

config = require '../configs/config.coffee'
test = config.dirs.src + '/css/pages/website/index.scss'     #string //产出index.css
ary = [                                                      #array  //分别产出文件名css
    config.dirs.src + '/css/pages/website/index.scss',
    config.dirs.src + '/css/pages/website/error-404.scss',
    config.dirs.src + '/css/pages/website/error-500.scss'
]
testcommon1 =  {ggggg: ary}                                  #json  //产出ggggg.css
testcommon2 =  {ggggg: ary,kkkkk: test}                      #json  //产出ggggg.css、kkkkk.css

module.exports = (gulp,$,slime)->
    return () ->
        slime.build(test,false,{type: 'sass'});
        # slime.build(testcommon1,false,{type: 'sass'});
        # slime.build(testcommon2,{type: 'sass'});
```

```
# js 示例(coffee)

config = require '../configs/config.coffee'
test = config.dirs.src + '/js/pages/h5/lazypage/lazypage.jsx'
ary = [
    config.dirs.src + '/js/pages/h5/loadpage/loadpage.jsx'
]
testcommon1 =  {ggggg: ary}
testcommon2 =  {ggggg: ary,kkkkk: test}
module.exports = (gulp,$,slime)->
    return (cb) ->
        slime.build(testcommon2,cb);

```





## 构建命令
>常用构建命令

### gulp
开启本地DEMO调试服务器

### gulp build
编译静态资源至`./dist`目录

## Bower包管理工具
由Bower管理第三方类库

## package.json
由package.json管理npm安装的依赖版本

## config.js
项目版本与基本配置config

### config.dirs
映射开发目录

### config.distName
映射构建目录

### config.hash
js构建是否加入hash值

# RUN
安装完成后在该目录下运行`gulp`，及进入编译及服务模式，具体的其他命令，请查看gulpfile.js文件!
