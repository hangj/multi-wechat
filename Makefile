
CC = clang

CFLAGS = -O2 -Wall -framework AppKit -framework Foundation -dynamiclib

WECHAT_DIR = /Applications/WeChat.app/Contents/MacOS/WeChat
WECHAT_BAK = /Applications/WeChat.app/Contents/MacOS/WeChat.bak
WECHAT_FRAMEWORKS = /Applications/WeChat.app/Contents/Frameworks


dylib-insert: dylib-insert.c
	$(CC) $< -o $@

libmulti-wechat.dylib: hook.m
	$(CC) $(CFLAGS) -o $@ $^


install: libmulti-wechat.dylib dylib-insert
	if [ ! -f $(WECHAT_BAK) ]; then cp -n $(WECHAT_DIR) $(WECHAT_BAK); fi
	cp libmulti-wechat.dylib $(WECHAT_FRAMEWORKS)
	./dylib-insert $(WECHAT_DIR) $(WECHAT_FRAMEWORKS)/libmulti-wechat.dylib

uninstall: $(WECHAT_BAK)
	cp $(WECHAT_BAK) $(WECHAT_DIR)
