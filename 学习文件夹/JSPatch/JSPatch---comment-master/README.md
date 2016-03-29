# JSPatch---comment
JSPatch 是一套牛逼的 Hotfix 框架，可利用 js 脚本修复线上 bug，目前已被微信、美团、微信读书、美丽说、蘑菇街、百度读书等国内一流 App 客户端采用，但是作者 bang 没写注释，对于想快速理解源码的同学造成了一定困扰，本人在阅读源代码后，加上了注释，如有想快速理解源码的同学可以参考。

由于代码设计的很巧妙，很难用简单的注释描述清楚逻辑，所以有些地方解释不清，如有不懂请咨询 bang 或我，我会尽力解答。

另外我上传了一份 ppt，里面有几个流程图，描述的是关于 JSPatch 框架中用到的一些知识点（部分参考 bang 博客画的），希望能对读者有所帮助。对于注解的错误，表达不准确，缺失等问题，欢迎 pull request。

1、打包脚本 bang 已经提供，在 Loader -> tools -> packer.php 目录下，终端命令是 php packer.php main.js other.js -o “文件名”。

2、为了方便大家生成 rsa 密钥对，加了一个生成密钥对的脚本 rsa.php, 终端命令是 php rsa.php。

3、关于 JSPatch 中用到的类型编码，方法签名等，可查阅 Apple 文档，Type Encodings: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
其中方法参数类型编码 types of the method arguments 是一个 const char * 类型字符串，第一位字符为方法返回值的 type encoding, 第二位是 target 对象的 type encoding，第三位是方法的 SEL 的 type encoding。
