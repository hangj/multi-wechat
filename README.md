# multi-wechat


```bash
sudo chown -R $(whoami) /Applications/WeChat.app
codesign --remove-signature /Applications/WeChat.app/Contents/MacOS/WeChat
make install
make uninstall
```

