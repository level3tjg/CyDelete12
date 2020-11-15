TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = SpringBoard

THEOS_DEVICE_IP = 192.168.1.116

ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CyDelete12

CyDelete12_FILES = Tweak.x
CyDelete12_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += cydelete
include $(THEOS_MAKE_PATH)/aggregate.mk
