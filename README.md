# SLIME PACK

--------------------------------------------------------------------------------

## 概述
突然想到了怪物史莱姆，丑陋，肮脏，但可爱，这与前端的产出一样，但希望在生产过程中足够可爱与简单。
SLIME PACK是一个 简单的前端编译系统，支持 `script / style / templet` 的打包与分包。

 -  
#### 支持模块化
多人协作开发需要模块化，前端现在都不是一个人在战斗，各种模式混杂，AMD，CMD，~~TMD~~（你懂的）
 都是比较常用的模式， SLIME PACK全部都支持，包括~~TMD~~模式，因为SLIME PACK是对`webpack`的封装, 什么是webpack你可以看一下这里 [链接地址](http://webpack.github.io)

 -  
#### 支持的style
还在敲css，太low了吧（我很low），这一部分在弄它的时候踩了些坑，我本来是想全部用`webpack`来封 装的，
但后来发现， webpack这个坑货对于sass的打包会出错，而且`sass-loader`这玩意作者也不是很给力，
啃了几天英文还是果断放弃算了 所以这一部分基于gulp（靠谱）来实现的。那么现在终于可
以支持`sass / less / stylus / css`这几个坑货了  

 -  
#### 支持的script
有的同学喜欢coffee，有的喜欢原生javascript，我本人后者，不想在踩坑。原生js也不是那么难看，
而且ES6不是也 快来了吗？yield yeah!

 -  
#### 支持react
facebook好像也出了些好东东，这个是其一，人家官方排名都很靠前的一个项目，SLIME PACK支持`jsx / cjsx `的编译输出
[传送门](http://https://facebook.github.io/)

 -  
#### 支持的templet
目前支持`handlesbar / html / php / jsp`，PHP/JSP在解析后会生成保留扩展名，其他的模板的扩展名会转变为`.html`
暂时还不支持'swig'，在gulp-task任务中可以通过nodejs获取数据并传送给模板render

 -  
#### 支持实时生成DEMO和WATCH
实时WATCH `雪碧图、JS、CSS`并生成最新的DEMO，可以实时看到模板CSS输出效果及js交互效果

## 依赖
node 0.12.1 ruby 2.2.2 [下载地址](http://rubyinstaller.org/downloads/)

```
$ npm install -g gulp
$ npm install -g bower
$ gem install sass
```

## 构建命令
### gulp
开启本地DEMO调试服务器

### gulp build
编译静态资源至`./dist`目录

### gulp doc
基于jsdoc规范生成开发文档至`./doc`目录

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
