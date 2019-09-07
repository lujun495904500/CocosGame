# CocosGame
基于cocos2dx-lua的游戏框架。除了cocos2dx自带的功能外，还提供了如下功能:

* 对游戏进行分包处理，根据需求把游戏分解为子包，有效控制初始游戏包容量。
* 提供游戏资源包打包功能，可以把游戏资源打包为单个文件，简化游戏包版本管理流程。
* 提供打包优化功能，可以在资源打包过程中对资源进行可选的压缩、加密或编译等以提高游戏安全性及性能。
* 提供游戏对象预加载、加载及卸载精确控制模型，帮助你模块化管理游戏对象的生命周期以优化内存使用。
* 提供部分游戏自动化工具，主要运用于原始资源到游戏资源的转化、打包游戏资源、安装游戏资源、上传游戏资源到服务器和发布程序等一系列自动化工具链。

项目以复刻FC游戏![](https://raw.githubusercontent.com/lujun495904500/CocosGame/master/game/boot/res/boot/graphics/images/gameicon.png)《吞食天地2》为模板，向初入cocos2dx的开发者展示了如何设计游戏框架结构，以便于在学习完cocos2dx后，能更合理、更高效的开发游戏。`publish/`目录有编译好的发布Demo游戏。

## 上手指南
项目主要以lua语言为主，因为cocos2dx的跨平台特性，所以还会涉及到C/C++、安卓java和object-c。游戏工具链主要使用的是python3.x（NOT python2.x）。所以你最好是会cocos2dx的，并且比较熟悉lua语言，最好了解python语言。由于框架比较复杂，下面将给出具体安装步骤，框架说明文档会另外给出。

## 安装步骤

### 1.安装cocos2dx相关开发工具
* Windows 7+, VS 2015
* NDK r16+ is required to build Android games
* Android Studio 3.0.0+ to build Android games(tested with 3.0.0)

### 2.安装python3.6+脚本工具
游戏开发脚本使用的是**python3**，不是python2,安装完python后你需要安装如下库
* **xlrd** (Excel表格读取库，可以使用命令 `pip install xlrd` 安装)
* **Pillow** (强大PIL图像处理库，可以使用命令 `pip install Pillow` 安装)
* **HDiffPatch** (开源补丁程序，可以直接双击 `scripts/toolkits/PyHDiffPatch/setup.py` 安装)
  
### 3.使用VS2015编译cocos2dx程序
    1.进入目录 frameworks/runtime-src/proj.win32/
    2.双击 CocosGame.sln, 使用VS2015打开工程
    3.在VS22015菜单栏中点击 生成 - 生成解决方案
    4.等到exe程序生成完成

### 3.使用脚本工具链更新、打包及安装资源
    1.进入目录 scripts/
    2.双击 updateAll.py 以更新游戏所有资源，等待完成
    2.双击 packRes.py 以打包游戏资源，等待完成
    3.双击 installRes.py 以安装游戏资源，等待完成

### 4.测试游戏运行
双击根目录中 `run.bat` ,如果出现游戏窗口，则游戏运行成功
