TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

ARCHS = arm64

TOOL_NAME = cydelete

cydelete_FILES = main.m
cydelete_CFLAGS = -fobjc-arc
cydelete_CODESIGN_FLAGS = -Sentitlements.plist
cydelete_INSTALL_PATH = /usr/libexec

include $(THEOS_MAKE_PATH)/tool.mk
