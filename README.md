XCCodeSign
===

修改iOS工程文件codesign的XCode插件，也会改一些drawf等，加快编译速度。为了自动构建安全，只修改了Debug Build。

使用方法
---
	1. 修改代码XCCodeSign.m中的MyCodeSign，替换你本机的证书
	2. Build & Run
	3. 菜单Edit会多出一个CodeSign xxx，点击即可修改当前工程文件