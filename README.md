# multi-wechat

通过 hook OC 代码来达到多开的目的

# 注意
不支持微信 4.0 以上版本  
下载微信历史版本: https://github.com/zsbai/wechat-versions/releases


```bash
sudo chown -R $(whoami) /Applications/WeChat.app
# codesign --remove-signature /Applications/WeChat.app/Contents/MacOS/WeChat
make install
make uninstall
```

# 可能遇到的问题

1. `open -n /Applications/WeChat.app` 报错

> The application cannot be opened for an unexpected reason, error=Error Domain=RBSRequestErrorDomain Code=5 "Launch failed." UserInfo={NSLocalizedFailureReason=Launch failed., NSUnderlyingError=0x600003a4c390 {Error Domain=NSPOSIXErrorDomain Code=162 "Unknown error: 162" UserInfo={NSLocalizedDescription=Launchd job spawn failed}}}

解决方案:

```bash
codesign --force --deep --sign - /Applications/WeChat.app
xattr -cr /Applications/WeChat.app
```

2. 第二个微信一直跳出 “想访问其他App的数据”

参考 https://github.com/sunnyyoung/WeChatTweak-macOS/issues/733



解决方案:


开启微信完全磁盘访问权限可以解决

