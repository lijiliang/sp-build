# 斯品WEB前台前端项目

===

## 依赖

node 0.12.1
ruby 2.2.2 [下载地址](http://rubyinstaller.org/downloads/)

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
