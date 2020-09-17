THEOS_PACKAGE_DIR_NAME = debs

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = EmeraldTools

EmeraldTools_FILES = Tweak.xm
SYSROOT = $(THEOS)/sdks/iPhoneOS11.2.sdk/
EmeraldTools_CFLAGS = -fobjc-arc
EmeraldTools_CCFLAGS = -std=c++14 -stdlib=libc++ -fno-rtti -fno-exceptions

ARCHS = arm64

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS)/makefiles/aggregate.mk

after-install::
	install.exec "killall -9 '-'"